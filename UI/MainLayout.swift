import SwiftUI

struct MainLayout: View {
    @State private var selectedTab: NavigationItem = .dashboard
    
    enum NavigationItem: String, CaseIterable {
        case dashboard = "Dashboard"
        case queue = "Queue"
        case history = "History"
        case search = "Search"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .dashboard: return "square.grid.2x2.fill"
            case .queue: return "list.bullet"
            case .history: return "clock.fill"
            case .search: return "magnifyingglass"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // Sidebar
            List(NavigationItem.allCases, id: \.self, selection: $selectedTab) { item in
                NavigationLink(
                    destination: destinationView(for: item),
                    tag: item,
                    selection: $selectedTab
                ) {
                    Label(item.rawValue, systemImage: item.icon)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            // Default View
            DashboardView()
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
    }
    
    @ViewBuilder
    func destinationView(for item: NavigationItem) -> some View {
        switch item {
        case .dashboard: DashboardView()
        case .queue: DownloadQueueView()
        case .history: HistoryView()
        case .search: SearchView()
        case .settings: SettingsView()
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
