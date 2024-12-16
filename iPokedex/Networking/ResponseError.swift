import Foundation

enum ResponseError: Error {
    case clientError
    case decodable
    case invalidURL
    case invalidResponse
    case none

    var localizedDescription: String {
        switch self {
        case .clientError:
            return "Client Error: There was an issue with the request sent to the server. Please check the request parameters, headers, or data and try again."
        case .decodable:
            return "Type Mismatch: The data type does not match the expected type. Please check the data and ensure it matches the expected format."
        case .invalidURL:
            return "URL Not Found: The request URL does not exist. Please verify the URL and ensure it points to a valid resource."
        case .invalidResponse:
            return "Invalid Server Response: The server response is not valid. Please try again later or contact support."
        case .none:
            return ""
        }
    }
}
