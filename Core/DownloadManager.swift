import Foundation
import Combine

class DownloadManager: ObservableObject {
    @Published var downloads: [DownloadItem] = []
    @Published var totalSpeed: Double = 0.0
    
    private let httpEngine = HTTPEngine()
    private let torrentEngine = TorrentEngine()
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = DownloadManager()
    
    private let storageURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        .appendingPathComponent("downloads.json")
    
    init() {
        httpEngine.delegate = self
        torrentEngine.delegate = self
        loadDownloads()
        
        // Auto-save whenever downloads change
        $downloads
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveDownloads() }
            .store(in: &cancellables)
            
        // Update global speed
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.calculateTotalSpeed()
            }
            .store(in: &cancellables)
    }
    
    func addDownload(url: URL, type: DownloadEngineType) {
        let name = url.lastPathComponent.isEmpty ? "download-\(UUID().uuidString.prefix(6))" : url.lastPathComponent
        let newItem = DownloadItem(
            id: UUID(),
            name: name,
            url: url,
            type: type,
            status: .pending,
            totalSize: 0,
            downloadedSize: 0
        )
        
        DispatchQueue.main.async {
            self.downloads.append(newItem)
            self.startDownload(id: newItem.id)
        }
    }
    
    func startDownload(id: UUID) {
        guard let index = downloads.firstIndex(where: { $0.id == id }) else { return }
        let item = downloads[index]
        
        switch item.type {
        case .http:
            httpEngine.startDownload(item: item)
        case .torrent:
            let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            torrentEngine.addTorrent(item: item, destinationURL: downloadsDir)
        }
    }
    
    func pauseDownload(id: UUID) {
        guard let index = downloads.firstIndex(where: { $0.id == id }) else { return }
        let item = downloads[index]
        
        switch item.type {
        case .http: httpEngine.pauseDownload(id: id)
        case .torrent: torrentEngine.pauseTorrent(id: id)
        }
        
        downloads[index].status = .paused
    }
    
    func resumeDownload(id: UUID) {
        guard let index = downloads.firstIndex(where: { $0.id == id }) else { return }
        let item = downloads[index]
        
        switch item.type {
        case .http: httpEngine.resumeDownload(id: id)
        case .torrent: torrentEngine.resumeTorrent(id: id)
        }
    }
    
    func removeDownload(id: UUID, deleteFile: Bool = false) {
        guard let index = downloads.firstIndex(where: { $0.id == id }) else { return }
        let item = downloads[index]
        
        switch item.type {
        case .http: httpEngine.cancelDownload(id: id)
        case .torrent: torrentEngine.removeTorrent(id: id)
        }
        
        if deleteFile {
            let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let fileURL = downloadsDir.appendingPathComponent(item.name)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        downloads.remove(at: index)
    }
    
    private func calculateTotalSpeed() {
        var total: Double = 0
        for item in downloads {
            if case .downloading(_, let speed) = item.status {
                total += speed
            }
        }
        self.totalSpeed = total
    }
    
    // MARK: - Persistence
    
    private func saveDownloads() {
        // Implementation for JSON encoding and saving to storageURL
    }
    
    private func loadDownloads() {
        // Implementation for JSON decoding from storageURL
    }
}

// MARK: - Engine Delegates

extension DownloadManager: HTTPEngineDelegate, TorrentEngineDelegate {
    
    func downloadProgressUpdated(id: UUID, progress: Double, speed: Double) {
        updateItem(id: id) { item in
            item.status = .downloading(progress: progress, speed: speed)
            item.downloadedSize = Int64(Double(item.totalSize) * progress)
        }
    }
    
    func downloadCompleted(id: UUID, fileURL: URL) {
        updateItem(id: id) { item in
            item.status = .completed
            item.downloadedSize = item.totalSize
        }
    }
    
    func downloadFailed(id: UUID, error: String) {
        updateItem(id: id) { item in
            item.status = .failed(error: error)
        }
    }
    
    func torrentProgressUpdated(id: UUID, progress: Double, speed: Double, peers: Int) {
        updateItem(id: id) { item in
            item.status = .downloading(progress: progress, speed: speed)
            // Torrent size logic usually comes from the info dictionary
        }
    }
    
    func torrentCompleted(id: UUID) {
        downloadCompleted(id: id, fileURL: URL(fileURLWithPath: ""))
    }
    
    func torrentFailed(id: UUID, error: String) {
        downloadFailed(id: id, error: error)
    }
    
    private func updateItem(id: UUID, action: @escaping (inout DownloadItem) -> Void) {
        DispatchQueue.main.async {
            if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                action(&self.downloads[index])
            }
        }
    }
}
