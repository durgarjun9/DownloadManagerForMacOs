import SwiftUI

@main
struct DownloadManagerApp: App {
    var body: some Scene {
        WindowGroup {
            MainLayout()
                .onAppear {
                    // Seed some dummy data for demonstration
                    seedDummyData()
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
    
    func seedDummyData() {
        let manager = DownloadManager.shared
        manager.addDownload(url: URL(string: "https://example.com/largefile.zip")!, type: .http)
        manager.addDownload(url: URL(string: "magnet:?xt=urn:btih:example")!, type: .torrent)
        
        // Update first one to downloading status
        if !manager.downloads.isEmpty {
            manager.downloads[0].status = .downloading(progress: 0.45, speed: 1024 * 1024 * 5.5)
            manager.downloads[0].totalSize = 1024 * 1024 * 1024
            manager.downloads[0].downloadedSize = Int64(Double(manager.downloads[0].totalSize) * 0.45)
        }
    }
}
