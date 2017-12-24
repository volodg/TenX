//
//  Extensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation
import RatesTable
import ExchangeRateCalculator

extension RateInfo {
  
  init(source: String, destination: String, exchange: String, weight: Double, backwardWeight: Double, date: Date) {
    
    self.init(
      source: Currency(rawValue: source),
      destination: Currency(rawValue: destination),
      exchange: Exchange(rawValue: exchange),
      weight: weight,
      backwardWeight: backwardWeight,//max(0.0, 1/weight - 0.01),
      date: date)
  }
  
  private func isValidWeight(
    ratesTable: RatesTable,
    exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>,
    exchange: Exchange,
    reverted: Bool) -> Bool {
    
    let sourceVertex = Vertex(currency: destination, exchange: exchange)
    guard let source = ratesTable.getIndex(for: sourceVertex) else {
      return true
    }
    
    let destinationVertex = Vertex(currency: self.source, exchange: exchange)
    guard let destination = ratesTable.getIndex(for: destinationVertex) else {
      return true
    }
    
    //do not check current edge
    let oldInfo = ratesTable.disableEdge(for: self)
    
    let vertexIndexes = exchangeRateCalculator
      .bestRatesPath(source: source, destination: destination)
    
    //enable current pair
    if let oldInfo = oldInfo {
      ratesTable.enableEdge(for: self, fullInfo: oldInfo)
    }
    
    guard let rate = ratesTable.getRate(for: vertexIndexes) else {
      return true
    }
    
    let result = weight <= 1/rate
    if !result {
      let backwardStr = reverted ? "Backward" : ""
      let sourceStr = reverted ? destination : source
      let destinationStr = reverted ? source : destination
      print("Error: invalid \(backwardStr) weight: \(weight), should be less or equal to \(1/rate) pair: \(sourceStr):\(destinationStr)")
    }
    return result
  }
  
  private func isValidWeight(
    ratesTable: RatesTable,
    exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>,
    reverted: Bool) -> Bool {
    
    let checkRateInfo = reverted ? reversed() : self
    
    let allExchanges = ratesTable.getAllExchanges().union([exchange])
    
    for exchange in allExchanges {
      
      let result = checkRateInfo.isValidWeight(
        ratesTable: ratesTable,
        exchangeRateCalculator: exchangeRateCalculator,
        exchange: exchange,
        reverted: reverted)
      
      if !result {
        return false
      }
    }
    
    return true
  }
  
  func isValid(
    ratesTable: RatesTable,
    exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>
    ) -> Bool {
    
    let result = backwardWeight <= 1/weight
    if !result {
      print("Error invalid backwardWeight: \(backwardWeight), should be less or equal to \(1/weight) pair: \(source):\(destination)")
      return false
    }
    
    for reverted in [false, true] {
      if !isValidWeight(
        ratesTable: ratesTable,
        exchangeRateCalculator: exchangeRateCalculator,
        reverted: reverted) {
        return false
      }
    }
    
    return true
  }
  
}
