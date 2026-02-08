import Foundation

protocol HTTPEngineDelegate: AnyObject {
    func downloadProgressUpdated(id: UUID, progress: Double, speed: Double)
    func downloadCompleted(id: UUID, fileURL: URL)
    func downloadFailed(id: UUID, error: String)
}

class HTTPEngine: NSObject {
    private var session: URLSession!
    private var activeTasks: [UUID: HTTPDownloadTask] = [:]
    weak var delegate: HTTPEngineDelegate?
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 20 
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func startDownload(item: DownloadItem, segmentCount: Int = 8) {
        let task = HTTPDownloadTask(item: item, segmentCount: segmentCount, session: session)
        task.delegate = self
        activeTasks[item.id] = task
        task.start()
    }
    
    func pauseDownload(id: UUID) {
        activeTasks[id]?.pause()
    }
    
    func resumeDownload(id: UUID) {
        activeTasks[id]?.resume()
    }
    
    func cancelDownload(id: UUID) {
        activeTasks[id]?.cancel()
        activeTasks.removeValue(forKey: id)
    }
}

extension HTTPEngine: HTTPDownloadTaskDelegate {
    func taskProgressUpdated(id: UUID, progress: Double, speed: Double) {
        delegate?.downloadProgressUpdated(id: id, progress: progress, speed: speed)
    }
    
    func taskCompleted(id: UUID, fileURL: URL) {
        delegate?.downloadCompleted(id: id, fileURL: fileURL)
    }
    
    func taskFailed(id: UUID, error: String) {
        delegate?.downloadFailed(id: id, error: error)
    }
}

// MARK: - Task Implementation

protocol HTTPDownloadTaskDelegate: AnyObject {
    func taskProgressUpdated(id: UUID, progress: Double, speed: Double)
    func taskCompleted(id: UUID, fileURL: URL)
    func taskFailed(id: UUID, error: String)
}

class HTTPDownloadTask {
    let item: DownloadItem
    let segmentCount: Int
    let session: URLSession
    weak var delegate: HTTPDownloadTaskDelegate?
    
    private var segments: [SegmentWorker] = []
    private var totalSize: Int64 = 0
    private var downloadedSize: Int64 = 0
    private var startTime: Date?
    private var timer: Timer?
    
    private let fileManager = FileManager.default
    private var destinationURL: URL
    
    init(item: DownloadItem, segmentCount: Int, session: URLSession) {
        self.item = item
        self.segmentCount = segmentCount
        self.session = session
        
        let downloadsFolder = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        self.destinationURL = downloadsFolder.appendingPathComponent(item.name)
    }
    
    func start() {
        // 1. Head request to get size
        var request = URLRequest(url: item.url)
        request.httpMethod = "HEAD"
        
        let headTask = session.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.taskFailed(id: self.item.id, error: error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                self.totalSize = httpResponse.expectedContentLength
                if self.totalSize <= 0 {
                    self.delegate?.taskFailed(id: self.item.id, error: "Unable to determine file size")
                    return
                }
                
                // Pre-allocate file
                do {
                    try DiskManager.shared.preallocateFile(at: self.destinationURL.path, size: self.totalSize)
                    self.initializeSegments()
                } catch {
                    self.delegate?.taskFailed(id: self.item.id, error: "Disk error: \(error.localizedDescription)")
                }
            }
        }
        headTask.resume()
    }
    
    private func initializeSegments() {
        let chunkSize = totalSize / Int64(segmentCount)
        startTime = Date()
        
        for i in 0..<segmentCount {
            let start = Int64(i) * chunkSize
            let end = (i == segmentCount - 1) ? totalSize - 1 : (Int64(i + 1) * chunkSize) - 1
            
            let worker = SegmentWorker(id: i, url: item.url, range: start...end, session: session, destinationURL: destinationURL)
            worker.delegate = self
            segments.append(worker)
            worker.start()
        }
        
        // Start monitoring speed
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.monitorSpeed()
            }
        }
    }
    
    private func monitorSpeed() {
        let currentDownloaded = segments.reduce(0) { $0 + $1.downloadedBytes }
        let now = Date()
        let elapsed = now.timeIntervalSince(startTime ?? now)
        
        let speed = Double(currentDownloaded) / elapsed
        let progress = Double(currentDownloaded) / Double(totalSize)
        
        delegate?.taskProgressUpdated(id: item.id, progress: progress, speed: speed)
        
        // Dynamic Segmentation Logic:
        // If one segment is much slower than others, we could potentially re-split it here.
        checkSlowSegments()
    }
    
    private func checkSlowSegments() {
        // Simplified Logic: If a segment is lagging behind and others are finished, steal its range.
        let active = segments.filter { !$0.isFinished }
        let finished = segments.filter { $0.isFinished }
        
        if active.count == 1, let slowWorker = active.first, finished.count > 0 {
            // Logic to split the remaining range of slowWorker and give it to an idle worker
            // This is complex and requires thread safety on the file handle
        }
    }
    
    func pause() {
        segments.forEach { $0.pause() }
        timer?.invalidate()
    }
    
    func resume() {
        segments.forEach { $0.resume() }
        startTime = Date() // Reset speed calculation baseline
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.monitorSpeed()
        }
    }
    
    func cancel() {
        segments.forEach { $0.cancel() }
        timer?.invalidate()
    }
}

extension HTTPDownloadTask: SegmentWorkerDelegate {
    func segmentFinished(id: Int) {
        if segments.allSatisfy({ $0.isFinished }) {
            timer?.invalidate()
            delegate?.taskCompleted(id: item.id, fileURL: destinationURL)
        }
    }
    
    func segmentFailed(id: Int, error: Error) {
        // Retry logic could go here
        delegate?.taskFailed(id: item.id, error: "Segment \(id) failed: \(error.localizedDescription)")
    }
}

// MARK: - Segment Worker

protocol SegmentWorkerDelegate: AnyObject {
    func segmentFinished(id: Int)
    func segmentFailed(id: Int, error: Error)
}

class SegmentWorker: NSObject, URLSessionDataDelegate {
    let id: Int
    let url: URL
    let range: ClosedRange<Int64>
    let session: URLSession
    let destinationURL: URL
    
    var downloadedBytes: Int64 = 0
    var isFinished = false
    private var task: URLSessionDataTask?
    private var fileHandle: FileHandle?
    
    weak var delegate: SegmentWorkerDelegate?
    
    init(id: Int, url: URL, range: ClosedRange<Int64>, session: URLSession, destinationURL: URL) {
        self.id = id
        self.url = url
        self.range = range
        self.session = session
        self.destinationURL = destinationURL
    }
    
    func start() {
        var request = URLRequest(url: url)
        let currentStart = range.lowerBound + downloadedBytes
        if currentStart > range.upperBound {
            isFinished = true
            delegate?.segmentFinished(id: id)
            return
        }
        
        request.setValue("bytes=\(currentStart)-\(range.upperBound)", forHTTPHeaderField: "Range")
        
        do {
            self.fileHandle = try FileHandle(forWritingTo: destinationURL)
        } catch {
            delegate?.segmentFailed(id: id, error: error)
            return
        }
        
        task = session.dataTask(with: request)
        task?.delegate = self
        task?.resume()
    }
    
    func pause() {
        task?.cancel()
    }
    
    func resume() {
        start()
    }
    
    func cancel() {
        task?.cancel()
        try? fileHandle?.close()
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let offset = range.lowerBound + downloadedBytes
        
        do {
            try fileHandle?.seek(toOffset: UInt64(offset))
            try fileHandle?.write(contentsOf: data)
            downloadedBytes += Int64(data.count)
        } catch {
            task?.cancel()
            delegate?.segmentFailed(id: id, error: error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if (error as NSError).code != NSURLErrorCancelled {
                delegate?.segmentFailed(id: id, error: error)
            }
        } else {
            isFinished = true
            try? fileHandle?.close()
            delegate?.segmentFinished(id: id)
        }
    }
}
