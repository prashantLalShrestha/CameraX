import XCTest
@testable import CameraX

final class CameraXTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CameraX().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
