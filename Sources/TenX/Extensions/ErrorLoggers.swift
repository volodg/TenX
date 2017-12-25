//
//  ErrorLoggers.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Parser
import CleanroomLogger

extension AppLogic.GetRateError {
  
  func logError(exchangeRateRequestInfo: ExchangeRateRequestInfo) {
    guard let error = Log.error else { return }
    
    switch self {
    case .undefinedSouce:
      error.message("invalid source currency: \(exchangeRateRequestInfo.sourceCurrency)")
    case .undefinedDestination:
      error.message("invalid destination currency: \(exchangeRateRequestInfo.destinationCurrency)")
    case .invalidPath(let path):
      error.message("Critical error: invalid rate's path: \(path)")
    }
  }
}

extension RateInfoValidationError {
  
  func logError() {
    guard let error = Log.error else { return }
    
    switch self {
    case .invalidWeight(let info, let rate, let maximumRate):
      error.message("Error: invalid weight: \(rate), should be less or equal to \(maximumRate) pair: \(info)")
    case .invalidBackwardWeight(let info, let rate, let maximumRate):
      error.message("Error: invalid Backward weight: \(rate), should be less or equal to \(maximumRate) pair: \(info)")
    case .invalidSourceOrDestination(let info):
      error.message("Error invalid source/destination for pair: \(info)")
    }
  }
}

