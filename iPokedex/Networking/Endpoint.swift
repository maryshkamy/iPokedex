import Foundation

/// An endpoint provides an easy way to define the base URL and authentication credentials.
protocol Endpoint {
    var path: String { get }
}
