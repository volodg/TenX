//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Foundation
import RatesTable
import ExchangeRateCalculator

//TODO validate SOURCE != DESTINATION
//TODO store exchanger
//TODO change math:
//1. infinity to zero,
//2. + to *,
//3. > to <,
//3. 0 to 1,

extension VertexIndex: IndexType {}

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
}

let testVertexes: [RateInfo] = [
  RateInfo(source: "1", destination: "2", exchange: "KRAKEN", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "1", destination: "3", exchange: "KRAKEN", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "2", destination: "3", exchange: "KRAKEN", weight: 0.5, backwardWeight: 0.5, date: Date()),
  RateInfo(source: "2", destination: "4", exchange: "KRAKEN", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "4", exchange: "KRAKEN", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "6", exchange: "KRAKEN", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "6", exchange: "KRAKEN", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "3", destination: "5", exchange: "KRAKEN", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "5", exchange: "KRAKEN", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "5", destination: "6", exchange: "KRAKEN", weight: 0.5, backwardWeight: 0.5, date: Date()),
  RateInfo(source: "6", destination: "7", exchange: "KRAKEN", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "5", destination: "7", exchange: "KRAKEN", weight: 0.5, backwardWeight: 0.5, date: Date()),

  RateInfo(source: "1", destination: "2", exchange: "GDAX", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "1", destination: "3", exchange: "GDAX", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "2", destination: "3", exchange: "GDAX", weight: 0.5, backwardWeight: 0.5, date: Date()),
  RateInfo(source: "2", destination: "4", exchange: "GDAX", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "4", exchange: "GDAX", weight: 1  , backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "6", exchange: "GDAX", weight: 1  , backwardWeight: 2  , date: Date()),//
  RateInfo(source: "4", destination: "6", exchange: "GDAX", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "3", destination: "5", exchange: "GDAX", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "5", exchange: "GDAX", weight: 2  , backwardWeight: 2  , date: Date()),
  RateInfo(source: "5", destination: "6", exchange: "GDAX", weight: 0.5, backwardWeight: 0.5, date: Date()),
  RateInfo(source: "6", destination: "7", exchange: "GDAX", weight: 1.7, backwardWeight: 2  , date: Date()),//here
  RateInfo(source: "5", destination: "7", exchange: "GDAX", weight: 0.5, backwardWeight: 0.5, date: Date()),
//  RateInfo(pair: Pair(source: "7", destination: "5"), weight: 1),
]

let ratesTable = RatesTable()

testVertexes.forEach { rateInfo in
  ratesTable.update(rateInfo: rateInfo)
}

let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()

exchangeRateCalculator.updateRatesTable(
  currenciesCount: ratesTable.currenciesCount,
  elements: ratesTable.allEdges)

func processBestPath() {
  
  let sourceVertex = Vertex(currency: Currency(rawValue: "1"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let source = ratesTable.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let distanceVertex = Vertex(currency: Currency(rawValue: "7"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let destination = ratesTable.getIndex(for: distanceVertex) else {
    print("invalid destination")
    return
  }
  
  let result = exchangeRateCalculator
    .bestRatesPath(source: source, destination: destination)
    .map { ($0.vertex.currency, $0.vertex.exchange) }
  
  print("best path: \(result)")
}

processBestPath()

