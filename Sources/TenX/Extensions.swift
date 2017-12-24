//
//  Extensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation
import RatesTable

extension RateInfo where WeightT == RateMonoidType {
  
  init(source: String, destination: String, exchange: String, weight: Double, backwardWeight: Double, date: Date) {
    
    self.init(
      source: Currency(rawValue: source),
      destination: Currency(rawValue: destination),
      exchange: Exchange(rawValue: exchange),
      weight: .Sum(weight),
      backwardWeight: .Sum(backwardWeight),
      date: date)
  }
}
