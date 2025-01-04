import XCTest

@testable import iPokedex
final class RegionServiceTest: XCTestCase {

    func test_requestRegions_whenRequestSucceeds_shouldReturnRegionResponse() async {
        // Given
        let response = RegionResponse(
            count: 2,
            results: [
                Region(name: "kanto", url: "https://pokeapi.co/api/v2/region/1/"),
                Region(name: "johto", url: "https://pokeapi.co/api/v2/region/2/")
            ]
        )
        let httpClient = HTTPClientMock(result: .success(response))
        let service = RegionService(httpClient: httpClient)

        // When
        let result = await service.requestRegions()

        // Then
        if case .success(let response) = result {
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.results.count, 2)
            XCTAssertEqual(response.results.first?.name, "kanto")
        } else {
            XCTFail("Expected success but got failure")
        }
    }
}
