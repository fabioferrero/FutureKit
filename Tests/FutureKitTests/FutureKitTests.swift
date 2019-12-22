import XCTest
@testable import FutureKit

final class FutureKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FutureKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
