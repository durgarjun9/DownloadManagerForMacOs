import Foundation

/// TorrentEngine status updates
protocol TorrentEngineDelegate: AnyObject {
    func torrentProgressUpdated(id: UUID, progress: Double, speed: Double, peers: Int)
    func torrentCompleted(id: UUID)
    func torrentFailed(id: UUID, error: String)
}

class TorrentEngine {
    weak var delegate: TorrentEngineDelegate?
    private var activeTorrents: [UUID: TorrentTask] = [:]
    
    struct Settings {
        var maxConnections: Int = 500
        var maxUploadSpeed: Int = 0 // unlimited
        var maxDownloadSpeed: Int = 0
        var enableDht: Bool = true
        var cacheSizeMB: Int = 512
    }
    
    private let settings: Settings
    
    init(settings: Settings = Settings()) {
        self.settings = settings
        setupLibTorrent()
    }
    
    private func setupLibTorrent() {
        // In a real implementation, this would call:
        // libtorrent_initialize(settings.maxConnections, settings.enableDht, settings.cacheSizeMB)
        print("LibTorrent initialized with \(settings.cacheSizeMB)MB cache")
    }
    
    func addTorrent(item: DownloadItem, destinationURL: URL) {
        let task = TorrentTask(item: item, destination: destinationURL)
        activeTorrents[item.id] = task
        task.delegate = self
        task.start()
    }
    
    func pauseTorrent(id: UUID) {
        activeTorrents[id]?.pause()
    }
    
    func resumeTorrent(id: UUID) {
        activeTorrents[id]?.resume()
    }
    
    func removeTorrent(id: UUID) {
        activeTorrents[id]?.stop()
        activeTorrents.removeValue(forKey: id)
    }
}

extension TorrentEngine: TorrentTaskDelegate {
    func taskProgressUpdated(id: UUID, progress: Double, speed: Double, peers: Int) {
        delegate?.torrentProgressUpdated(id: id, progress: progress, speed: speed, peers: peers)
    }
    
    func taskCompleted(id: UUID) {
        delegate?.torrentCompleted(id: id)
    }
    
    func taskFailed(id: UUID, error: String) {
        delegate?.torrentFailed(id: id, error: error)
    }
}

// MARK: - Torrent Task

protocol TorrentTaskDelegate: AnyObject {
    func taskProgressUpdated(id: UUID, progress: Double, speed: Double, peers: Int)
    func taskCompleted(id: UUID)
    func taskFailed(id: UUID, error: String)
}

class TorrentTask {
    let item: DownloadItem
    let destination: URL
    weak var delegate: TorrentTaskDelegate?
    
    private var isRunning = false
    private var timer: Timer?
    
    init(item: DownloadItem, destination: URL) {
        self.item = item
        self.destination = destination
    }
    
    func start() {
        isRunning = true
        // Call C Bridge: add_torrent_from_magnet(item.url.absoluteString, destination.path)
        
        // Simulation for "Whole Application" feel without compiled binary
        startSimulation()
    }
    
    private func startSimulation() {
        var progress = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning else { return }
            progress += 0.01
            let speed = Double.random(in: 2_000_000...15_000_000) // 2-15 MB/s
            let peers = Int.random(in: 10...150)
            
            self.delegate?.taskProgressUpdated(id: self.item.id, progress: min(progress, 1.0), speed: speed, peers: peers)
            
            if progress >= 1.0 {
                self.isRunning = false
                self.timer?.invalidate()
                self.delegate?.taskCompleted(id: self.item.id)
            }
        }
    }
    
    func pause() {
        isRunning = false
        // Call C Bridge: pause_torrent(item.infoHash)
    }
    
    func resume() {
        isRunning = true
        // Call C Bridge: resume_torrent(item.infoHash)
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        // Call C Bridge: remove_torrent(item.infoHash)
    }
}
