import SwiftUI
import DownloadManagerCore

@main
struct DownloadManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct ContentView: View {
    @State private var selectedTab: String? = "Dashboard"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: "Dashboard") {
                    Label("Dashboard", systemImage: "gauge")
                }
                NavigationLink(value: "Search") {
                    Label("Search", systemImage: "magnifyingglass")
                }
                NavigationLink(value: "History") {
                    Label("History", systemImage: "clock")
                }
                NavigationLink(value: "Settings") {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("DownloadManager")
        } detail: {
            NavigationStack {
                if let tab = selectedTab {
                    switch tab {
                    case "Dashboard":
                        DashboardView()
                    case "Search":
                        SearchView()
                    case "History":
                        HistoryView()
                    case "Settings":
                        SettingsView()
                    default:
                        Text("Select a view")
                    }
                } else {
                    DashboardView()
                }
            }
        }
        .onOpenURL { url in
            if url.scheme == "magnet" {
                DownloadManager.shared.addDownload(url: url)
                selectedTab = "Dashboard"
            }
        }
    }
}

struct SearchView: View {
    @State private var query: String = ""
    var body: some View {
        VStack {
            TextField("Search for files...", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
            Text("Search results will appear here")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct DownloadDetailsView: View {
    let item: DownloadItem
    var body: some View {
        Form {
            Section("File Information") {
                LabeledContent("Name", value: item.fileName)
                LabeledContent("URL", value: item.url.absoluteString)
                LabeledContent("Size", value: formatBytes(item.totalSize))
            }
            Section("Status") {
                LabeledContent("Status", value: item.status.rawValue.capitalized)
                LabeledContent("Progress", value: "\(Int(item.progress * 100))%")
                LabeledContent("Speed", value: formatSpeed(item.speed))
                LabeledContent("Download Path", value: "\(DownloadManager.shared.downloadPath)/\(item.fileName)")
            }
            Section("Actions") {
                if item.status == .paused {
                    Button(action: { DownloadManager.shared.resumeDownload(id: item.id) }) {
                        Label("Resume", systemImage: "play.fill")
                    }
                } else if item.status == .downloading || item.status == .pending {
                    Button(action: { DownloadManager.shared.pauseDownload(id: item.id) }) {
                        Label("Pause", systemImage: "pause.fill")
                    }
                }
                
                Button(role: .destructive, action: { 
                    DownloadManager.shared.removeDownload(id: item.id)
                }) {
                    Label("Remove Download", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Details")
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.1f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        }
    }
}

struct DashboardView: View {
    @ObservedObject var manager = DownloadManager.shared
    @State private var newURL: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter Download URL or Magnet Link", text: $newURL)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    if let url = URL(string: newURL) {
                        manager.addDownload(url: url)
                        newURL = ""
                    }
                }
                .keyboardShortcut(.return)
            }
            .padding()
            
            List {
                ForEach(manager.activeDownloads) { item in
                    NavigationLink(destination: DownloadDetailsView(item: item)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.fileName)
                                    .font(.headline)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(Int(item.progress * 100))%")
                            }
                            ProgressView(value: item.progress)
                            HStack {
                                Text(item.status.rawValue.capitalized)
                                Spacer()
                                HStack(spacing: 12) {
                                    Button(action: {
                                        if item.status == .paused {
                                            DownloadManager.shared.resumeDownload(id: item.id)
                                        } else {
                                            DownloadManager.shared.pauseDownload(id: item.id)
                                        }
                                    }) {
                                        Image(systemName: item.status == .paused ? "play.circle" : "pause.circle")
                                            .font(.title3)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Text(formatSpeed(item.speed))
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .contextMenu {
                        Button("Pause/Resume") {
                            if item.status == .paused {
                                DownloadManager.shared.resumeDownload(id: item.id)
                            } else {
                                DownloadManager.shared.pauseDownload(id: item.id)
                            }
                        }
                        Button("Remove", role: .destructive) {
                            DownloadManager.shared.removeDownload(id: item.id)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        DownloadManager.shared.removeDownload(id: manager.activeDownloads[index].id)
                    }
                }
            }
        }
        .navigationTitle("Dashboard")
    }
    
    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.1f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        }
    }
}

struct HistoryView: View {
    @ObservedObject var manager = DownloadManager.shared
    var body: some View {
        List {
            ForEach(manager.completedDownloads) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item.fileName)
                    Spacer()
                    Text("Completed")
                }
                .contextMenu {
                    Button("Remove", role: .destructive) {
                        DownloadManager.shared.removeDownload(id: item.id)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    DownloadManager.shared.removeDownload(id: manager.completedDownloads[index].id)
                }
            }
        }
        .navigationTitle("History")
    }
}

struct SettingsView: View {
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: .constant(false))
                HStack {
                    Text("Download Path")
                    Spacer()
                    Text(manager.downloadPath)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Button("Change...") {
                        selectDirectory()
                    }
                }
            }
            Section("Network") {
                VStack(alignment: .leading) {
                    Text("Global Speed Limit: \(manager.speedLimitKBps == 0 ? "Unlimited" : "\(manager.speedLimitKBps) KB/s")")
                    Slider(value: Binding(
                        get: { Double(manager.speedLimitKBps) },
                        set: { manager.speedLimitKBps = Int($0) }
                    ), in: 0...10240, step: 128)
                }
            }
        }
        .padding()
    }
    
    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                manager.downloadPath = url.path
            }
        }
    }
}
