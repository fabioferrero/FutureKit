
import XCTest
import Foundation
@testable import FutureKit

final class FutureKitTests: XCTestCase {
    
    func testFutureSuccess() {
        
        let promise = Promise<String>()
        let future = promise as Future<String>
        
        promise.resolve(with: "Hello, World!")
        
        future.onSuccess { string in
            XCTAssertEqual(string, "Hello, World!")
        }
    }
    
    func testFutureFailure() {
        
        struct Error: Swift.Error, LocalizedError {
            var errorDescription: String? { "Error, World!" }
        }
        let promise = Promise<String>()
        let future = promise as Future<String>
        
        promise.reject(with: Error())
        
        future.onFailure { error in
            XCTAssertEqual(error.localizedDescription, "Error, World!")
        }
    }

    static var allTests = [
        ("testFutureSuccess", testFutureSuccess),
        ("testFutureFailure", testFutureFailure)
    ]
}
