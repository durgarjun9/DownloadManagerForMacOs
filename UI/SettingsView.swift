import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager = DownloadManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("General").font(.headline)) {
                Toggle("Launch at Login", isOn: .constant(true))
                TextField("Download Location", text: .constant("~/Downloads"))
            }
            
            Section(header: Text("Network & Speed").font(.headline)) {
                Toggle("Global Speed Limit", isOn: $manager.isSpeedLimited)
                if manager.isSpeedLimited {
                    Slider(value: $manager.speedLimitMbps, in: 1...1000) {
                        Text("Limit: \(Int(manager.speedLimitMbps)) Mbps")
                    }
                }
                
                Stepper("Parallel Segments (HTTP)", value: .constant(8), in: 1...32)
            }
            
            Section(header: Text("Torrent Engine (libtorrent)").font(.headline)) {
                Toggle("Enable DHT", isOn: .constant(true))
                Toggle("Enable PeX", isOn: .constant(true))
                TextField("Max Peer Connections", text: .constant("500"))
                Toggle("Enable OS Cache (Recommended for SSD)", isOn: .constant(true))
            }
        }
        .formStyle(GroupedFormStyle())
        .padding(30)
    }
}
