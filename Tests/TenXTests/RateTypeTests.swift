//
//  RateTypeTests.swift
//  TenXTests
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

import XCTest
import Commons

private struct ZeroMaximum: Maximum {
  let rawValue: Double
  
  static func maximum() -> ZeroMaximum {
    return ZeroMaximum(rawValue: 4)
  }
  
  func less(_ than: ZeroMaximum) -> Bool {
    return rawValue > than.rawValue
  }  
}

final class RateTypeTests: XCTestCase {
  
  func testIsMaximum() {
    XCTAssertTrue(RateGroupType.maximum().isMaximum)
  }
  
  func testZeroIsMaximum() {
    XCTAssertTrue(ZeroMaximum.maximum().isMaximum)
  }
  
  static var allTests = [
    ("testIsMaximum", testIsMaximum),
    ("testZeroIsMaximum", testZeroIsMaximum),
    ]
}
