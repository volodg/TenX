import XCTest
import AppLogic

final class TenXTests: XCTestCase {
  func testStrictMode() {
    let appLogic = AppLogic<RateGroupType>(strategy: .strict)
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    //XCTAssertEqual(TenX().text, "Hello, World!")
  }
  
  static var allTests = [
    ("testExample", testStrictMode),
  ]
}

