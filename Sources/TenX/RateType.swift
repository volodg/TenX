//
//  RateType.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

import Commons

//TODO try to use Decimal - https://developer.apple.com/documentation/foundation/decimal
typealias RateType = Double

struct RateGroupType {
  private let rawValue: RateType
}

extension RateGroupType: Semigroup {
  
  func op(_ g: RateGroupType) -> RateGroupType {
    return RateGroupType(rawValue: rawValue * g.rawValue)
  }
}

extension RateGroupType: Monoid {
  
  static func e() -> RateGroupType {
    return RateGroupType(rawValue: 1)
  }
}

extension RateGroupType: Group {
  
  func inv() -> RateGroupType {
    return RateGroupType(rawValue: 1/rawValue)
  }
}

extension RateGroupType: Ordered {
  
  static func neutral() -> RateGroupType {
    return RateGroupType(rawValue: 0)
  }
  
  func less(_ than: RateGroupType) -> Bool {
    return rawValue > than.rawValue
  }
  
}
