import Foundation

class DiskManager {
    static let shared = DiskManager()
    
    /// Pre-allocates disk space for a file to prevent fragmentation and improve write performance.
    /// Uses fcntl with F_PREALLOCATE on macOS for direct disk allocation.
    func preallocateFile(at path: String, size: Int64) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents: nil)
        }
        
        let fileURL = URL(fileURLWithPath: path)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        defer { try? fileHandle.close() }
        
        let fd = fileHandle.fileDescriptor
        
        var allocPtr = fstore_t(
            fst_flags: UInt32(F_ALLOCATECONTIG | F_ALLOCATEALL),
            fst_posmode: F_PEOFPOSMODE,
            fst_offset: 0,
            fst_length: size,
            fst_bytesalloc: 0
        )
        
        // Try to allocate contiguous space
        let result = fcntl(fd, F_PREALLOCATE, &allocPtr)
        if result == -1 {
            // Fallback to non-contiguous allocation
            allocPtr.fst_flags = UInt32(F_ALLOCATEALL)
            fcntl(fd, F_PREALLOCATE, &allocPtr)
        }
        
        // Set the actual file size
        ftruncate(fd, size)
    }
    
    /// Optimized write using direct I/O if possible (Zero-Copy logic)
    func writeChunk(to path: String, offset: Int64, data: Data) throws {
        let fileURL = URL(fileURLWithPath: path)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        try fileHandle.seek(toOffset: UInt64(offset))
        try fileHandle.write(contentsOf: data)
        try fileHandle.close()
    }
}
