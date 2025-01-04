import Foundation

@testable import iPokedex
class HTTPClientMock: HTTPClientProtocol {

    var result: Result<RegionResponse, ResponseError>?

    init(result: Result<RegionResponse, ResponseError>? = nil) {
        self.result = result
    }

    func request<T: Decodable>(from url: String) async -> Result<T, ResponseError> {
        guard let result = result as? Result<T, ResponseError> else {
            fatalError("Unexpected result type")
        }

        return result
    }
}
