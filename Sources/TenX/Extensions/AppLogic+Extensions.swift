//
//  AppLogic+Extensions.swift
//  TenXPackageDescription
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

import Result
import AppLogic
import RatesTable

extension AppLogic {
  
  func getRateInfo(
    sourceCurrency: String,
    sourceExchange: String,
    destinationCurrency: String,
    destinationExchange: String) -> Result<PathRateInfo, GetRateError> {
    
    return getRateInfo(
      sourceCurrency: Currency(rawValue: sourceCurrency),
      sourceExchange: Exchange(rawValue: sourceExchange),
      destinationCurrency: Currency(rawValue: destinationCurrency),
      destinationExchange: Exchange(rawValue: destinationExchange))
  }
}
