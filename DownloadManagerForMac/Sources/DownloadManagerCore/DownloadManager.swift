import Foundation
import LibTorrentWrapper

public class DownloadManager: ObservableObject {
    @Published public var activeDownloads: [DownloadItem] = []
    @Published public var completedDownloads: [DownloadItem] = []
    
    private let torrentManager = TorrentManager()
    
    public static let shared = DownloadManager()
    
    @Published public var downloadPath: String = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path {
        didSet {
            UserDefaults.standard.set(downloadPath, forKey: "DownloadPath")
        }
    }
    
    @Published public var speedLimitKBps: Int = 0 {
        didSet {
            UserDefaults.standard.set(speedLimitKBps, forKey: "SpeedLimitKBps")
            applySpeedLimit()
        }
    }
    
    private init() {
        if let savedPath = UserDefaults.standard.string(forKey: "DownloadPath") {
            self.downloadPath = savedPath
        }
        self.speedLimitKBps = UserDefaults.standard.integer(forKey: "SpeedLimitKBps")
        applySpeedLimit()
    }
    
    private func applySpeedLimit() {
        // speedLimitKBps 0 means unlimited
        let limit = speedLimitKBps > 0 ? Int32(speedLimitKBps * 1024) : 0
        torrentManager?.setDownloadLimit(limit)
    }
    
    public func addDownload(url: URL) {
        let item = DownloadItem(url: url)
        activeDownloads.append(item)
        
        if url.absoluteString.hasPrefix("magnet:") || url.pathExtension == "torrent" {
            startTorrentDownload(item)
        } else {
            startHTTPDownload(item)
        }
    }
    
    public func pauseDownload(id: UUID) {
        if let index = activeDownloads.firstIndex(where: { $0.id == id }) {
            let item = activeDownloads[index]
            if item.url.absoluteString.hasPrefix("magnet:") || item.url.pathExtension == "torrent" {
                torrentManager?.pauseTorrent(forMagnet: item.url.absoluteString)
            }
            activeDownloads[index].status = .paused
        }
    }
    
    public func resumeDownload(id: UUID) {
        if let index = activeDownloads.firstIndex(where: { $0.id == id }) {
            let item = activeDownloads[index]
            if item.url.absoluteString.hasPrefix("magnet:") || item.url.pathExtension == "torrent" {
                torrentManager?.resumeTorrent(forMagnet: item.url.absoluteString)
            }
            activeDownloads[index].status = .downloading
        }
    }
    
    public func removeDownload(id: UUID) {
        if let index = activeDownloads.firstIndex(where: { $0.id == id }) {
            let item = activeDownloads[index]
            if item.url.absoluteString.hasPrefix("magnet:") || item.url.pathExtension == "torrent" {
                torrentManager?.removeTorrent(forMagnet: item.url.absoluteString)
            }
            activeDownloads.remove(at: index)
        } else if let index = completedDownloads.firstIndex(where: { $0.id == id }) {
            let item = completedDownloads[index]
            if item.url.absoluteString.hasPrefix("magnet:") || item.url.pathExtension == "torrent" {
                torrentManager?.removeTorrent(forMagnet: item.url.absoluteString)
            }
            completedDownloads.remove(at: index)
        }
    }
    
    private func startHTTPDownload(_ item: DownloadItem) {
        let downloader = HTTPDownloader(item: item)
        downloader.start()
        // Further implementation needed for tracking
    }
    
    private func startTorrentDownload(_ item: DownloadItem) {
        torrentManager?.addTorrent(withMagnet: item.url.absoluteString, withSavePath: downloadPath)
        
        // Track progress in a timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let urlString = item.url.absoluteString
            let progress = self.torrentManager?.downloadProgress(forMagnet: urlString) ?? 0.0
            let speed = self.torrentManager?.downloadSpeed(forMagnet: urlString) ?? 0.0
            let name = self.torrentManager?.name(forMagnet: urlString) ?? ""
            let size = self.torrentManager?.totalSize(forMagnet: urlString) ?? 0
            
            if let index = self.activeDownloads.firstIndex(where: { $0.id == item.id }) {
                guard self.activeDownloads[index].status != .paused else { return }
                
                self.activeDownloads[index].progress = Double(progress)
                self.activeDownloads[index].speed = speed
                self.activeDownloads[index].status = .downloading
                
                if !name.isEmpty && self.activeDownloads[index].fileName == "Initializing..." {
                    self.activeDownloads[index].fileName = name
                }
                
                if size > 0 {
                    self.activeDownloads[index].totalSize = size
                }
                
                if progress >= 1.0 {
                    var completed = self.activeDownloads.remove(at: index)
                    completed.status = .completed
                    self.completedDownloads.append(completed)
                    timer.invalidate()
                }
            }
        }
    }
}
