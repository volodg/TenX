//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Foundation
import SquareMatrix
import ExchangeRateCalculator

//TODO validate SOURCE != DESTINATION
//TODO store exchanger
//TODO change math:
//1. infinity to zero,
//2. + to *,
//3. > to <,
//3. 0 to 1,

extension VertexIndex: IndexType {
  static func ==(lhs: VertexIndex, rhs: VertexIndex) -> Bool {
    return lhs.vertex == rhs.vertex
      && lhs.index == rhs.index
  }
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

let exchangesVertex = ExchangesVertex()

testVertexes.forEach { rateInfo in
  exchangesVertex.update(rateInfo: rateInfo)
}

let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()

exchangeRateCalculator.updateRatesTable(
  currenciesCount: exchangesVertex.currenciesCount,
  elements: exchangesVertex.allEdges)

func processBestPath() {
  
  let sourceVertex = Vertex(currency: Currency(rawValue: "1"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let source = exchangesVertex.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let distanceVertex = Vertex(currency: Currency(rawValue: "7"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let destination = exchangesVertex.getIndex(for: distanceVertex) else {
    print("invalid destination")
    return
  }
  
  let result = exchangeRateCalculator.bestPath(source: source, destination: destination)
  
  print("best path: \(result)")
}

processBestPath()

