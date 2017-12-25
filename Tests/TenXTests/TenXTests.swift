import XCTest
import TenX

final class TenXTests: XCTestCase {
  func testStrictMode() {
    let appLogic = AppLogic(strategy: .strict)
    //appLogic.
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    //XCTAssertEqual(TenX().text, "Hello, World!")
  }
  
  static var allTests = [
    ("testExample", testStrictMode),
  ]
}

