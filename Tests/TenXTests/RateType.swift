//
//  RateType.swift
//  TenXTests
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

import Commons

typealias RateType = Int

struct RateGroupType {
  private let rawValue: RateType
  init(rawValue: RateType) {
    self.rawValue = rawValue
  }
}

extension RateGroupType: CustomStringConvertible {
  var description: String {
    return "\(rawValue)"
  }
}

extension RateGroupType: Semigroup {
  
  func op(_ g: RateGroupType) -> RateGroupType {
    return RateGroupType(rawValue: rawValue + g.rawValue)
  }
}

extension RateGroupType: Monoid {
  
  static func e() -> RateGroupType {
    return RateGroupType(rawValue: 0)
  }
}

extension RateGroupType: Group {
  
  func inv() -> RateGroupType {
    return RateGroupType(rawValue: -rawValue)
  }
}

extension RateGroupType: Maximum {
  
  static func maximum() -> RateGroupType {
    return RateGroupType(rawValue: Int.max)
  }
  
  func less(_ than: RateGroupType) -> Bool {
    return rawValue < than.rawValue
  }
  
}
