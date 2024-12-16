import Foundation

@testable import iPokedex
class HTTPClientMock: HTTPClientProtocol {
    var didCallRequest: Bool = false

    func request<T: Decodable>(from url: String) async -> Result<T, ResponseError> {
        didCallRequest = true
        return .failure(.none)
    }
}
