//
//  UpdateRatesInfo+Extensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Parser
import RatesTable

extension UpdateRatesInfo {
  
  var toRateInfo: RateInfo {
    return RateInfo(
      source: sourceCurrency,
      destination: destinationCurrency,
      exchange: exchange,
      weight: rate,
      backwardWeight: backwardRate,
      date: updateTime)
  }
}
