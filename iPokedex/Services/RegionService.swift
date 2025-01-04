import Foundation

protocol RegionServiceProtocol {
    var httpClient: HTTPClientProtocol { get }
    func requestRegions() async -> Result<RegionResponse, ResponseError>
}

class RegionService: RegionServiceProtocol {

    private(set) var httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = HTTPClient()) {
        self.httpClient = httpClient
    }

    func requestRegions() async -> Result<RegionResponse, ResponseError> {
        await httpClient.request(from: "https://pokeapi.co/api/v2/region")
    }
}
