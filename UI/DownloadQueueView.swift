import SwiftUI

struct DownloadQueueView: View {
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Download Queue")
                .font(.title2).bold()
                .padding(.bottom, 20)
            
            List {
                if manager.downloads.isEmpty {
                    Text("Queue is empty")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(manager.downloads) { item in
                        DownloadRow(item: item)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding(30)
    }
}

struct DownloadRow: View {
    let item: DownloadItem
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.type == .torrent ? "square.stack.3d.up.fill" : "globe")
                .font(.system(size: 24))
                .foregroundColor(item.status == .completed ? .green : .blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                HStack {
                    ProgressView(value: getProgress(for: item.status))
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    Text("\(Int(getProgress(for: item.status) * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 40)
                }
                
                HStack {
                    Text(getStatusText(for: item.status))
                        .foregroundColor(getStatusColor(for: item.status))
                    Text("•")
                    Text(getSizeText(item: item))
                    Spacer()
                    if case .downloading(_, let speed) = item.status {
                        Text(formatSpeed(speed))
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 10) {
                if item.status == .paused {
                    Button(action: { manager.resumeDownload(id: item.id) }) {
                        Image(systemName: "play.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if case .downloading = item.status {
                    Button(action: { manager.pauseDownload(id: item.id) }) {
                        Image(systemName: "pause.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: { manager.removeDownload(id: item.id) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func getProgress(for status: DownloadStatus) -> Double {
        if case .downloading(let progress, _) = status { return progress }
        if status == .completed { return 1.0 }
        return 0.0
    }
    
    private func getStatusText(for status: DownloadStatus) -> String {
        switch status {
        case .pending: return "Pending"
        case .downloading: return "Downloading"
        case .paused: return "Paused"
        case .verifying: return "Verifying"
        case .completed: return "Completed"
        case .failed(let error): return "Error: \(error)"
        }
    }
    
    private func getStatusColor(for status: DownloadStatus) -> Color {
        switch status {
        case .completed: return .green
        case .failed: return .red
        case .downloading: return .blue
        default: return .secondary
        }
    }
    
    private func getSizeText(item: DownloadItem) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        let current = formatter.string(fromByteCount: item.downloadedSize)
        let total = formatter.string(fromByteCount: item.totalSize)
        return item.totalSize > 0 ? "\(current) of \(total)" : "Calculating..."
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        if speed < 1024 { return String(format: "%.0f B/s", speed) }
        if speed < 1024 * 1024 { return String(format: "%.1f KB/s", speed / 1024) }
        return String(format: "%.1f MB/s", speed / 1024 / 1024)
    }
}
