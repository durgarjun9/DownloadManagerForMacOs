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
                LabeledContent("Size", value: "\(item.totalSize / 1024 / 1024) MB")
            }
            Section("Status") {
                LabeledContent("Status", value: item.status.rawValue.capitalized)
                LabeledContent("Progress", value: "\(Int(item.progress * 100))%")
                LabeledContent("Download Path", value: "~/Downloads/\(item.fileName)")
            }
        }
        .navigationTitle("Details: \(item.fileName)")
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
            
            List(manager.activeDownloads) { item in
                NavigationLink(destination: DownloadDetailsView(item: item)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.fileName)
                                .font(.headline)
                            Spacer()
                            Text("\(Int(item.progress * 100))%")
                        }
                        ProgressView(value: item.progress)
                        HStack {
                            Text(item.status.rawValue.capitalized)
                            Spacer()
                            Text("Speed: 0 KB/s") // Placeholder
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct HistoryView: View {
    @ObservedObject var manager = DownloadManager.shared
    var body: some View {
        List(manager.completedDownloads) { item in
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(item.fileName)
                Spacer()
                Text("Completed")
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: .constant(false))
                TextField("Download Path", text: .constant("~/Downloads"))
            }
            Section("Network") {
                Slider(value: .constant(0), in: 0...1000) {
                    Text("Global Speed Limit (KB/s)")
                }
            }
        }
        .padding()
    }
}
