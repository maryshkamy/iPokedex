import XCTest

@testable import iPokedex
final class HTTPClientTest: XCTestCase {

    private var httpClient: HTTPClientProtocol!
    private var urlSessionMock: URLSessionMock!

    override func setUp() {
        super.setUp()
        urlSessionMock = URLSessionMock()
        httpClient = HTTPClient(session: urlSessionMock)
    }

    override func tearDown() {
        httpClient = nil
        urlSessionMock = nil
        super.tearDown()
    }

    func test_httpClient_whenRequestFromAnInvalidURL_shouldReturnAnError() async throws {
        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "")

        // Then
        XCTAssertEqual(urlSessionMock.lastURL?.host, nil)

        if case .failure(let error) = result {
            XCTAssertEqual(error, .invalidURL)
        } else {
            XCTFail("Expected an invalid URL error but got success")
        }
    }

    func test_httpClient_whenRequestRegionSucceeds_shouldReturnDecodedRegionResponse() async throws {
        // Given
        let jsonString = """
        {
          "count": 2,
          "next": null,
          "previous": null,
          "results": [
            {
              "name": "kanto",
              "url": "https://pokeapi.co/api/v2/region/1/"
            },
            {
              "name": "johto",
              "url": "https://pokeapi.co/api/v2/region/2/"
            }
          ]
        }
        """

        guard let data = jsonString.data(using: .utf8) else {
                XCTFail("Could not convert JSON string to Data")
                return
        }

        urlSessionMock.data = data
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        XCTAssertEqual(urlSessionMock.lastURL?.host, "pokeapi.co")
        XCTAssertEqual(urlSessionMock.lastURL?.path, "/api/v2/region")

        if case .success(let response) = result {
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.results.count, 2)
            XCTAssertEqual(response.results.first?.name, "kanto")
        } else {
            XCTFail("Expected success but got failure")
        }
    }

    func test_httpClient_whenResponseIsEmpty_shouldReturnDecodingError() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .decodable)
        } else {
            XCTFail("Expected a decoding error but got success")
        }
    }

    func test_httpClient_whenResponseHasInvalidData_shouldReturnDecodingError() async throws {
        // Given
        urlSessionMock.data = Data("invalid".utf8)
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .decodable)
        } else {
            XCTFail("Expected a decoding error but got success")
        }
    }

    func test_httpClient_whenResponseHasMalformedJSON_shouldReturnDecodingError() async throws {
        // Given
        urlSessionMock.data = Data("{ invalid json".utf8)
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .decodable)
        } else {
            XCTFail("Expected a decoding error but got success")
        }
    }


    func test_httpClient_whenResponseHasClientError_shouldReturnClientError() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .clientError)
        } else {
            XCTFail("Expected a client error but got success")
        }
    }

    func test_httpClient_whenResponseIsNotHTTPURLResponse_shouldReturnInvalidResponseError() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = URLResponse()

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .invalidResponse)
        } else {
            XCTFail("Expected an invalid response error but got success")
        }
    }

    func test_httpClient_whenResponseHasServerError_shouldReturnInvalidResponseError() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .invalidResponse)
        } else {
            XCTFail("Expected an invalid response error but got success")
        }
    }

    func test_httpClient_whenResponseHasRedirectStatus_shouldReturnInvalidResponseError() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/region")!,
            statusCode: 301,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .invalidResponse)
        } else {
            XCTFail("Expected an invalid response error but got success")
        }
    }

    func test_httpClient_whenNetworkTimeoutOccurs_shouldReturnInvalidURL() async throws {
        // Given
        urlSessionMock.data = Data()
        urlSessionMock.response = nil

        // When
        let result: Result<RegionResponse, ResponseError> = await httpClient.request(from: "https://pokeapi.co/api/v2/region")

        // Then
        if case .failure(let error) = result {
            XCTAssertEqual(error, .invalidResponse)
        } else {
            XCTFail("Expected an invalid response error but got success")
        }
    }

}
