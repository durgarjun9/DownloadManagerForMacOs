import Foundation
import LibTorrentWrapper

public class DownloadManager: ObservableObject {
    @Published public var activeDownloads: [DownloadItem] = []
    @Published public var completedDownloads: [DownloadItem] = []
    
    private let torrentManager = TorrentManager()
    
    public static let shared = DownloadManager()
    
    private init() {}
    
    public func addDownload(url: URL) {
        let item = DownloadItem(url: url)
        activeDownloads.append(item)
        
        if url.absoluteString.hasPrefix("magnet:") || url.pathExtension == "torrent" {
            startTorrentDownload(item)
        } else {
            startHTTPDownload(item)
        }
    }
    
    private func startHTTPDownload(_ item: DownloadItem) {
        let downloader = HTTPDownloader(item: item)
        downloader.start()
        // Further implementation needed for tracking
    }
    
    private func startTorrentDownload(_ item: DownloadItem) {
        let savePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path
        torrentManager?.addTorrent(withMagnet: item.url.absoluteString, withSavePath: savePath)
        
        // Track progress in a timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let urlString = item.url.absoluteString
            let progress = self.torrentManager?.downloadProgress(forMagnet: urlString) ?? 0.0
            let speed = self.torrentManager?.downloadSpeed(forMagnet: urlString) ?? 0.0
            let name = self.torrentManager?.name(forMagnet: urlString) ?? ""
            let size = self.torrentManager?.totalSize(forMagnet: urlString) ?? 0
            
            if let index = self.activeDownloads.firstIndex(where: { $0.id == item.id }) {
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
