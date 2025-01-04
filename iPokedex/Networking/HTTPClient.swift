import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

protocol HTTPClientProtocol {
    func request<T: Decodable>(from url: String) async -> Result<T, ResponseError>
}

extension URLSession: URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await self.data(from: url, delegate: nil)
    }
}

class HTTPClient: HTTPClientProtocol {

    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func request<T: Decodable>(from url: String) async -> Result<T, ResponseError> {
        guard let url = URL(string: url) else {
            return .failure(.invalidURL)
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let response = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(.decodable)
                }

                return .success(decodedResponse)
            case 400...499:
                return .failure(.clientError)
            default:
                return .failure(.invalidResponse)
            }
        } catch {
            return .failure(.invalidURL)
        }
    }
}
