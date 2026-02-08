import SwiftUI
import AppKit

struct HistoryView: View {
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Download History")
                .font(.title2).bold()
                .padding(.bottom, 20)
            
            List {
                let completed = manager.downloads.filter { $0.status == .completed }
                if completed.isEmpty {
                    Text("No completed downloads yet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(completed) { item in
                        HistoryRow(item: item)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding(30)
    }
}

struct HistoryRow: View {
    let item: DownloadItem
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("Completed on \(item.createdAt.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Open") {
                let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                let fileURL = downloadsDir.appendingPathComponent(item.name)
                NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: downloadsDir.path)
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct SearchView: View {
    @State private var query = ""
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Search Downloads")
                .font(.title2).bold()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search by name or URL...", text: $query)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .padding(.vertical, 20)
            
            List {
                let filtered = manager.downloads.filter { 
                    query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) || $0.url.absoluteString.localizedCaseInsensitiveContains(query)
                }
                
                ForEach(filtered) { item in
                    DownloadRow(item: item)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding(30)
    }
}
