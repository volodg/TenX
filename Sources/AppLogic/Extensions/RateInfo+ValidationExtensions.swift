//
//  RateInfo+ValidationExtensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import RatesTable
import Commons

public enum RateInfoValidationError<RateT>: Error {
  case invalidWeight(info: RateInfo<RateT>, rate: RateT, maximumRate: RateT)
  case invalidBackwardWeight(info: RateInfo<RateT>, rate: RateT, maximumRate: RateT)
  case invalidSourceOrDestination(info: RateInfo<RateT>)
}

extension RateInfo where RateT: Maximum & Group {
  private func weightValidationError(
    appLogic: AppLogic<RateT>,
    exchange: Exchange,
    reverted: Bool,
    var stop: inout Bool) -> RateInfoValidationError<RateT>? {
    
    let rateInfo = appLogic.getRateInfo(
      sourceCurrency: self.destination,
      sourceExchange: exchange,
      destinationCurrency: self.source,
      destinationExchange: exchange)
    
    guard let rate = rateInfo.value?.rate else {
      return nil
    }
    
    guard !rate.isMaximum else {
      stop = true
      return nil
    }
    
    let result = !(weight.less(rate.inv()))
    if !result {
      if reverted {
        return .invalidBackwardWeight(info: self, rate: weight, maximumRate: rate.inv())
      } else {
        return .invalidWeight(info: self, rate: weight, maximumRate: rate.inv())
      }
    }
    
    stop = true
    return nil
  }
  
  private func weightValidationError(appLogic: AppLogic<RateT>, reverted: Bool) -> RateInfoValidationError<RateT>? {
    
    //do not check current edge, because it going to be replaced
    let oldEdgeInfo = appLogic.disableEdges(for: self)
    if oldEdgeInfo == nil {
      //TODO add zero weight edge here instead of enumerating exchanges
    }
    defer {
      //enable current edge
      if let oldEdgeInfo = oldEdgeInfo {
        appLogic.enableEdges(for: self, edgeInfo: oldEdgeInfo)
      }
    }
    
    let checkRateInfo = reverted ? reversed() : self
    
    let allExchanges = appLogic.getAllExchanges().union([exchange])
    
    var result: RateInfoValidationError<RateT>? = nil
    
    var stop = false
    
    for exchange in allExchanges {
      
      result = checkRateInfo.weightValidationError(
        appLogic: appLogic,
        exchange: exchange,
        reverted: reverted,
        stop: &stop)
      
      if result != nil || stop {
        break
      }
    }
    
    return result
  }
  
  func validationError(appLogic: AppLogic<RateT>) -> RateInfoValidationError<RateT>? {
    
    guard source != destination else {
      return .invalidSourceOrDestination(info: self)
    }
    
    switch appLogic.strategy {
    case .strict:
      break
    case .unstrictAllowCycle, .unstrictIgnoreCycles:
      return nil
    }
    
    let result = weight.isMaximum || !(backwardWeight.less(weight.inv()))
    if !result {
      return .invalidBackwardWeight(info: self, rate: backwardWeight, maximumRate: weight.inv())
    }
    
    for reverted in [false, true] {
      if let validationError = weightValidationError(appLogic: appLogic, reverted: reverted) {
        return validationError
      }
    }
    
    return nil
  }
  
}
