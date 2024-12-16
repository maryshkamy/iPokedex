import Foundation

@testable import iPokedex
class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?

    private(set) var lastURL: URL?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastURL = url

        return (data ?? Data(), response ?? URLResponse())
    }
}
