import SwiftUI

struct DownloadDetailView: View {
    let item: DownloadItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: item.type == .torrent ? "square.stack.3d.up.fill" : "globe")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.title).bold()
                    Text(item.url.absoluteString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Divider()
            
            Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 15) {
                GridRow {
                    DetailItem(label: "Status", value: "\(item.status)")
                    DetailItem(label: "Priority", value: "\(item.priority)")
                }
                GridRow {
                    DetailItem(label: "Type", value: item.type == .torrent ? "BitTorrent" : "HTTP/S")
                    DetailItem(label: "Added", value: item.createdAt.formatted())
                }
                GridRow {
                    DetailItem(label: "Total Size", value: ByteCountFormatter.string(fromByteCount: item.totalSize, countStyle: .file))
                    DetailItem(label: "Downloaded", value: ByteCountFormatter.string(fromByteCount: item.downloadedSize, countStyle: .file))
                }
            }
            
            if item.type == .torrent {
                Text("Peers & Swarm")
                    .font(.headline)
                    .padding(.top)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 150)
                    .overlay(Text("Peer Map Placeholder").foregroundColor(.secondary))
            }
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body).medium()
        }
    }
}
extension Text {
    func medium() -> Text {
        self.fontWeight(.medium)
    }
}
