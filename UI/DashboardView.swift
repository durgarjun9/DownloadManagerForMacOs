import SwiftUI

struct DashboardView: View {
    @ObservedObject var manager = DownloadManager.shared
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Main Dashboard")
                        .font(.system(size: 28, weight: .bold))
                    Text("Manage your high-speed transfers")
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: { showingAddSheet = true }) {
                    Label("New Download", systemImage: "plus")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack(spacing: 20) {
                StatCard(title: "Active", value: "\(manager.downloads.filter { if case .downloading = $0.status { return true }; return false }.count)", icon: "arrow.down.circle.fill", color: .blue)
                StatCard(title: "Speed", value: formatSpeed(manager.totalSpeed), icon: "bolt.fill", color: .orange)
                StatCard(title: "Pending", value: "\(manager.downloads.filter { $0.status == .pending }.count)", icon: "timer", color: .secondary)
            }
            
            Text("Active Transfers")
                .font(.headline)
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    let active = manager.downloads.filter { 
                        if case .downloading = $0.status { return true }
                        if $0.status == .pending { return true }
                        return false
                    }
                    
                    if active.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("No active downloads")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(active) { item in
                            DownloadRow(item: item)
                        }
                    }
                }
            }
        }
        .padding(30)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .sheet(isPresented: $showingAddSheet) {
            AddDownloadView()
        }
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        if speed < 1024 { return String(format: "%.0f B/s", speed) }
        if speed < 1024 * 1024 { return String(format: "%.1f KB/s", speed / 1024) }
        return String(format: "%.1f MB/s", speed / 1024 / 1024)
    }
}
