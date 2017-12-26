import XCTest
import RatesTable
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
      [1,2,4,2,3,4,5,6,3],
      [3,2,4,2,3,4,5,6,3],
      [1,3,2,4,2,3,4,5,6,3],
      [3,2,4,2,3,4,5,6,3,5],
      [1,2,4,2,3,4,5,6,3,5],
      [1,3,2,4,2,3,4,5,6,3,5]
    ]
    
    XCTAssertEqual([1,3,2,4,2,3,4,5,6,3,5].removeCycles(), [1,3,5])
    XCTAssertEqual([3,2,4,2,3,4,5,6,3].removeCycles(), [3])
    
    for arr in testArrays {
      XCTAssertTrue(isIdempotent(arr, { self_ in self_.removeCycles() } ))
      XCTAssertTrue(allUniqueue(arr.removeCycles()))
    }
  }
  
  private let rates: [(exchange: String, source: String, destination: String, rate: Double, backwardRate: Double)] = [
    ("GDAX", "A", "B", 1.0 , .infinity),
    ("GDAX", "B", "C", 1.0 , .infinity),
    ("GDAX", "C", "A", -3.0, .infinity),
    ("GDAX", "B", "D", 2.0 , .infinity),
  ]
  
  private lazy var ratesInfo: [RateInfo<RateGroupType>] = {
    return self.rates.map { el in
      RateInfo<RateGroupType>(
        source: Currency(rawValue: el.source),
        destination: Currency(rawValue: el.destination),
        exchange: Exchange(rawValue: el.exchange),
        weight: RateGroupType(rawValue: el.rate),
        backwardWeight: RateGroupType(rawValue: el.backwardRate),
        date: Date()
      )
    }
  }()
  
  func testStrictMode() {
    let appLogic = AppLogic<RateGroupType>(strategy: .strict)
    
    var numberOfFailures = 0
    
    ratesInfo.forEach { el in
      let result = appLogic.update(rateInfo: el)
      switch result {
      case .success:
        break
      case .failure(let error):
        numberOfFailures += 1
        XCTAssertEqual(1, numberOfFailures)
        switch error {
        case .invalidSourceOrDestination, .invalidBackwardWeight:
          XCTFail()
        case .invalidWeight(let info):
          XCTAssertEqual("C", info.info.source.rawValue)
          XCTAssertEqual("A", info.info.destination.rawValue)
        }
      }
    }
    
    let result = appLogic.getRateInfo(
      sourceCurrency: Currency(rawValue: "A"),
      sourceExchange: Exchange(rawValue: "GDAX"),
      destinationCurrency: Currency(rawValue: "D"),
      destinationExchange: Exchange(rawValue: "GDAX"))
    
    switch result {
    case .success(let rateInfo):
      XCTAssertEqual(3.0, rateInfo.rate.rawValue)
      XCTAssertEqual("A", rateInfo.path[0].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[0].exchange.rawValue)
      XCTAssertEqual("B", rateInfo.path[1].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[1].exchange.rawValue)
      XCTAssertEqual("D", rateInfo.path[2].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[2].exchange.rawValue)
    case .failure:
      XCTFail()
    }
  }
  
  func testUnstrictAllowCycleMode() {
    let appLogic = AppLogic<RateGroupType>(strategy: .unstrictAllowCycle)
    
    ratesInfo.forEach { el in
      let result = appLogic.update(rateInfo: el)
      switch result {
      case .success:
        break
      case .failure:
        XCTFail()
      }
    }
    
    let result = appLogic.getRateInfo(
      sourceCurrency: Currency(rawValue: "A"),
      sourceExchange: Exchange(rawValue: "GDAX"),
      destinationCurrency: Currency(rawValue: "D"),
      destinationExchange: Exchange(rawValue: "GDAX"))
    
    switch result {
    case .success(let rateInfo):
      XCTAssertEqual(-1.0, rateInfo.rate.rawValue)
      XCTAssertEqual("A", rateInfo.path[0].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[0].exchange.rawValue)
      XCTAssertEqual("B", rateInfo.path[1].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[1].exchange.rawValue)
      XCTAssertEqual("C", rateInfo.path[2].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[2].exchange.rawValue)
      XCTAssertEqual("A", rateInfo.path[3].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[3].exchange.rawValue)
    case .failure:
      XCTFail()
    }
  }
  
  func testUnstrictIgnoreCyclesMode() {
    let appLogic = AppLogic<RateGroupType>(strategy: .unstrictIgnoreCycles)
    
    ratesInfo.forEach { el in
      let result = appLogic.update(rateInfo: el)
      switch result {
      case .success:
        break
      case .failure:
        XCTFail()
      }
    }
    
    let result = appLogic.getRateInfo(
      sourceCurrency: Currency(rawValue: "A"),
      sourceExchange: Exchange(rawValue: "GDAX"),
      destinationCurrency: Currency(rawValue: "D"),
      destinationExchange: Exchange(rawValue: "GDAX"))
    
    switch result {
    case .success(let rateInfo):
      XCTAssertEqual(3.0, rateInfo.rate.rawValue)
      XCTAssertEqual("A", rateInfo.path[0].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[0].exchange.rawValue)
      XCTAssertEqual("B", rateInfo.path[1].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[1].exchange.rawValue)
      XCTAssertEqual("D", rateInfo.path[2].currency.rawValue)
      XCTAssertEqual("GDAX", rateInfo.path[2].exchange.rawValue)
    case .failure:
      XCTFail()
    }
  }
  
  static var allTests = [
    ("testStrictMode", testStrictMode),
    ("testRemoveCycles", testRemoveCycles),
    ("testUnstrictAllowCycleMode", testUnstrictAllowCycleMode),
    ("testUnstrictIgnoreCyclesMode", testUnstrictIgnoreCyclesMode),
  ]
}

