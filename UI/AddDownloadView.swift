import SwiftUI

struct AddDownloadView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var urlString: String = ""
    @State private var segments: Int = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add New Download")
                .font(.title2).bold()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("URL or Magnet Link")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("https://... or magnet:?", text: $urlString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if !urlString.lowercased().hasPrefix("magnet:") {
                Stepper("Parallel Segments: \(segments)", value: $segments, in: 1...32)
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                
                Button("Download") {
                    if let url = URL(string: urlString) {
                        let type: DownloadEngineType = urlString.lowercased().hasPrefix("magnet:") ? .torrent : .http
                        DownloadManager.shared.addDownload(url: url, type: type)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(URL(string: urlString) == nil)
            }
        }
        .padding(25)
        .frame(width: 450)
    }
}
