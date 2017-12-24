//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Commons
import Foundation
import RatesTable
import ExchangeRateCalculator

//TODO use Decimal type instead of Double
//TODO validate input SOURCE != DESTINATION

extension VertexIndex: IndexType {}

let testVertexes: [RateInfo] = [
  RateInfo(source: "1", destination: "2", exchange: "KRAKEN", weight: 1.1,  backwardWeight: 0.9, date: Date()),
  RateInfo(source: "1", destination: "3", exchange: "KRAKEN", weight: 0.5,  backwardWeight: 1  , date: Date()),
  RateInfo(source: "2", destination: "3", exchange: "KRAKEN", weight: 0.5,  backwardWeight: 0.9, date: Date()),
  RateInfo(source: "2", destination: "4", exchange: "KRAKEN", weight: 1  ,  backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "4", exchange: "KRAKEN", weight: 1  ,  backwardWeight: 0.9, date: Date()),
  RateInfo(source: "3", destination: "5", exchange: "KRAKEN", weight: 0.5,  backwardWeight: 2  , date: Date()),
  RateInfo(source: "3", destination: "6", exchange: "KRAKEN", weight: 0.5,  backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "5", exchange: "KRAKEN", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "6", exchange: "KRAKEN", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "5", destination: "6", exchange: "KRAKEN", weight: 1.0 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "5", destination: "7", exchange: "KRAKEN", weight: 2   , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "6", destination: "7", exchange: "KRAKEN", weight: 0.5 , backwardWeight: 0.5, date: Date()),
  
  RateInfo(source: "1", destination: "2", exchange: "GDAX", weight: 1   , backwardWeight: 0.9, date: Date()),
  RateInfo(source: "1", destination: "3", exchange: "GDAX", weight: 1   , backwardWeight: 1  , date: Date()),
  RateInfo(source: "2", destination: "3", exchange: "GDAX", weight: 0.9 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "2", destination: "4", exchange: "GDAX", weight: 1   , backwardWeight: 1  , date: Date()),
  RateInfo(source: "3", destination: "4", exchange: "GDAX", weight: 1.1 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "3", destination: "6", exchange: "GDAX", weight: 0.5 , backwardWeight: 1  , date: Date()),
  RateInfo(source: "4", destination: "6", exchange: "GDAX", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "3", destination: "5", exchange: "GDAX", weight: 0.5 , backwardWeight: 2  , date: Date()),
  RateInfo(source: "4", destination: "5", exchange: "GDAX", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "5", destination: "6", exchange: "GDAX", weight: 1.0 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "6", destination: "7", exchange: "GDAX", weight: 0.6 , backwardWeight: 0.5, date: Date()),//here
  RateInfo(source: "5", destination: "7", exchange: "GDAX", weight: 2  , backwardWeight: 0.5, date: Date()),
//  RateInfo(pair: Pair(source: "7", destination: "5"), weight: 1),
]

let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()

let ratesTable = RatesTable()

testVertexes.forEach { rateInfo in
  
  guard rateInfo.isValid(ratesTable: ratesTable,
                         exchangeRateCalculator: exchangeRateCalculator) else {
    return
  }
  
  ratesTable.update(rateInfo: rateInfo)
  
  exchangeRateCalculator.updateRatesTable(
    currenciesCount: ratesTable.currenciesCount,
    elements: ratesTable.allEdges)
}


func processBestPath() {
  
  let sourceVertex = Vertex(currency: Currency(rawValue: "1"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let source = ratesTable.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let destinationVertex = Vertex(currency: Currency(rawValue: "7"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let destination = ratesTable.getIndex(for: destinationVertex) else {
    print("invalid destination")
    return
  }
  
  let vertexIndexes = exchangeRateCalculator
    .bestRatesPath(source: source, destination: destination)
  
  let result = vertexIndexes.map { ($0.vertex.currency, $0.vertex.exchange) }
  
  let rate = ratesTable.getRate(for: vertexIndexes)
  
  print("best path: \n\(result)")
  print("best rate: \(rate!)")
}

processBestPath()

