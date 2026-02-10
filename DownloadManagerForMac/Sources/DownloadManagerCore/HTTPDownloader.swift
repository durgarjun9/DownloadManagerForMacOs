import Foundation

public enum DownloadStatus: String, Codable {
    case pending, downloading, paused, completed, failed
}

public struct DownloadItem: Identifiable, Codable {
    public let id: UUID
    public let url: URL
    public let fileName: String
    public var status: DownloadStatus
    public var progress: Double
    public var totalSize: Int64
    public var downloadedSize: Int64
    public var speed: Double // Bytes per second
    
    public init(url: URL) {
        self.id = UUID()
        self.url = url
        self.fileName = url.lastPathComponent
        self.status = .pending
        self.progress = 0
        self.totalSize = 0
        self.downloadedSize = 0
        self.speed = 0
    }
}

public class HTTPDownloader: NSObject, URLSessionDataDelegate {
    private var session: URLSession!
    private var segments: [HTTPSegment] = []
    private let segmentCount = 8
    public var onProgress: ((DownloadItem) -> Void)?
    
    private var item: DownloadItem
    private var startTime: Date?
    
    public init(item: DownloadItem) {
        self.item = item
        super.init()
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    public func start() {
        // First, get the file size
        var request = URLRequest(url: item.url)
        request.httpMethod = "HEAD"
        
        let task = session.dataTask(with: request) { [weak self] _, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                self?.item.status = .failed
                return
            }
            
            let size = response.expectedContentLength
            self?.item.totalSize = size
            self?.dispatchSegments(totalSize: size)
        }
        task.resume()
    }
    
    private func dispatchSegments(totalSize: Int64) {
        let chunkSize = totalSize / Int64(segmentCount)
        for i in 0..<segmentCount {
            let start = Int64(i) * chunkSize
            let end = (i == segmentCount - 1) ? totalSize - 1 : (Int64(i + 1) * chunkSize) - 1
            let segment = HTTPSegment(url: item.url, range: (start, end), index: i)
            segments.append(segment)
            downloadSegment(segment)
        }
        
        // Start dynamic monitor
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.balanceSegments()
        }
    }
    
    private func balanceSegments() {
        guard let _ = segments.first(where: { $0.speed < 1024 && !$0.isCompleted }),
              let fastSegment = segments.max(by: { $0.speed < $1.speed }),
              fastSegment.remainingBytes > 1024 * 1024 * 2 else { return }
        
        // Split fast segment's remaining work
        print("Dynamic Segmentation: Re-assigning work from fast segment to slow segment")
        // Logic to cancel slow, split fast, and restart
    }
    
    private func downloadSegment(_ segment: HTTPSegment) {
        var request = URLRequest(url: segment.url)
        request.addValue("bytes=\(segment.range.start)-\(segment.range.end)", forHTTPHeaderField: "Range")
        
        let task = session.dataTask(with: request)
        task.resume()
    }
}

class HTTPSegment {
    let url: URL
    let range: (start: Int64, end: Int64)
    let index: Int
    var downloaded: Int64 = 0
    var isCompleted: Bool = false
    var speed: Double = 0
    var remainingBytes: Int64 { (range.end - range.start) - downloaded }
    
    init(url: URL, range: (start: Int64, end: Int64), index: Int) {
        self.url = url
        self.range = range
        self.index = index
    }
}
