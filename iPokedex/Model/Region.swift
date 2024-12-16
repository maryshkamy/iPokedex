import Foundation

struct RegionResponse: Decodable {
    let count: Int
    let results: [Region]
}

struct Region: Decodable {
    let name: String
    let url: URL
}
