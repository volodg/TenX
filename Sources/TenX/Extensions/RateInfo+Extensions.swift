//
//  RateInfo+Extensions.swift
//  TenXPackageDescription
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

import RatesTable
import Foundation

extension RateInfo where RateT == RateGroupType {
  
  init(source: String, destination: String, exchange: String, weight: Double, backwardWeight: Double, date: Date) {
    
    self.init(
      source: Currency(rawValue: source),
      destination: Currency(rawValue: destination),
      exchange: Exchange(rawValue: exchange),
      weight: RateGroupType(rawValue: weight),
      backwardWeight: RateGroupType(rawValue: backwardWeight),
      date: date)
  }
}
