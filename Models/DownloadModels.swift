import Foundation

enum DownloadEngineType: String, Codable {
    case http
    case torrent
}

enum DownloadStatus: Codable, Equatable {
    case pending
    case downloading(progress: Double, speed: Double)
    case paused
    case verifying
    case completed
    case failed(error: String)
    
    // Custom Codable implementation because of associated values
    private enum CodingKeys: String, CodingKey {
        case type, progress, speed, error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "pending": self = .pending
        case "downloading":
            let p = try container.decode(Double.self, forKey: .progress)
            let s = try container.decode(Double.self, forKey: .speed)
            self = .downloading(progress: p, speed: s)
        case "paused": self = .paused
        case "verifying": self = .verifying
        case "completed": self = .completed
        case "failed":
            let e = try container.decode(String.self, forKey: .error)
            self = .failed(error: e)
        default: self = .pending
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending: try container.encode("pending", forKey: .type)
        case .downloading(let p, let s):
            try container.encode("downloading", forKey: .type)
            try container.encode(p, forKey: .progress)
            try container.encode(s, forKey: .speed)
        case .paused: try container.encode("paused", forKey: .type)
        case .verifying: try container.encode("verifying", forKey: .type)
        case .completed: try container.encode("completed", forKey: .type)
        case .failed(let e):
            try container.encode("failed", forKey: .type)
            try container.encode(e, forKey: .error)
        }
    }
}

struct DownloadItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let url: URL
    let type: DownloadEngineType
    var status: DownloadStatus
    var totalSize: Int64
    var downloadedSize: Int64
    var priority: DownloadPriority = .normal
    var createdAt: Date = Date()
    
    enum DownloadPriority: Int, Codable, Comparable {
        case low = 0
        case normal = 1
        case high = 2
        
        static func < (lhs: DownloadPriority, rhs: DownloadPriority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
