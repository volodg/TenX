import XCTest
@testable import AppLogic

final class AppLogicTests: XCTestCase {
  func testRemoveCycles() {
    func isIdempotent<T: Equatable>(_ x: [T], _ f: ([T]) -> [T]) -> Bool {
      let y = f(x)
      return y == f(y)
    }
    
    func allUniqueue<T: Hashable>(_ x: [T]) -> Bool {
      return Set<T>(x).count == x.count
    }
    
    let testArrays: [[Int]] = [
      [],
      [1],
      [1,2],
      [1,2,2],
      [1,2,4,2,3,4,5,6,3,5]
    ]
    
    for arr in testArrays {
      XCTAssertTrue(isIdempotent(arr, { self_ in self_.removeCycles() } ))
      XCTAssertTrue(allUniqueue(arr.removeCycles()))
    }
  }
  
  func testStrictMode() {
    let appLogic = AppLogic<RateGroupType>(strategy: .strict)
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    //XCTAssertEqual(TenX().text, "Hello, World!")
  }
  
  static var allTests = [
    ("testStrictMode", testStrictMode),
    ("testRemoveCycles", testRemoveCycles),
  ]
}

