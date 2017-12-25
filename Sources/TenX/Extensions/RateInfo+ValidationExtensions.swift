//
//  RateInfo+ValidationExtensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation
import RatesTable
import ExchangeRateCalculator

enum RateInfoValidationError: Error {
  case invalidWeight(info: RateInfo, rate: Double, maximumRate: Double)
  case invalidBackwardWeight(info: RateInfo, rate: Double, maximumRate: Double)
  case invalidSourceOrDestination(info: RateInfo)
}

extension RateInfo {
  
  init(source: String, destination: String, exchange: String, weight: Double, backwardWeight: Double, date: Date) {
    
    self.init(
      source: Currency(rawValue: source),
      destination: Currency(rawValue: destination),
      exchange: Exchange(rawValue: exchange),
      weight: weight,
      backwardWeight: backwardWeight,
      date: date)
  }
  
  private func weightValidationError(
    appLogic: AppLogic,
    exchange: Exchange,
    reverted: Bool) -> RateInfoValidationError? {
    
    let rateInfo = appLogic.getRateInfo(
      sourceCurrency: self.destination,
      sourceExchange: exchange,
      destinationCurrency: self.source,
      destinationExchange: exchange)
    
    guard let rate = rateInfo.value?.rate, rate != 0 else {
      return nil
    }
    
    let result = weight <= 1/rate
    if !result {
      if reverted {
        return .invalidBackwardWeight(info: self, rate: weight, maximumRate: 1/rate)
      } else {
        return .invalidWeight(info: self, rate: weight, maximumRate: 1/rate)
      }
    }
    return nil
  }
  
  private func weightValidationError(appLogic: AppLogic, reverted: Bool) -> RateInfoValidationError? {
    
    //do not check current edge, because it going to be replaced
    let oldEdgeInfo = appLogic.disableEdge(for: self)
    defer {
      //enable current edge
      if let oldEdgeInfo = oldEdgeInfo {
        appLogic.enableEdge(for: self, edgeInfo: oldEdgeInfo)
      }
    }
    
    let checkRateInfo = reverted ? reversed() : self
    
    let allExchanges = appLogic.getAllExchanges().union([exchange])
    
    var result: RateInfoValidationError? = nil
    
    for exchange in allExchanges {
      
      result = checkRateInfo.weightValidationError(
        appLogic: appLogic,
        exchange: exchange,
        reverted: reverted)
      
      if result != nil {
        break
      }
    }
    
    return result
  }
  
  func validationError(appLogic: AppLogic) -> RateInfoValidationError? {
    
    if source == destination {
      return .invalidSourceOrDestination(info: self)
    }
    
    switch appLogic.strategy {
    case .strict:
      break
    case .unstrict:
      return nil
    }
    
    let result = backwardWeight <= 1/weight
    if !result {
      return .invalidBackwardWeight(info: self, rate: backwardWeight, maximumRate: 1/weight)
    }
    
    for reverted in [false, true] {
      if let validationError = weightValidationError(appLogic: appLogic, reverted: reverted) {
        return validationError
      }
    }
    
    return nil
  }
  
}
