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

//TODO validate input SOURCE != DESTINATION

//TODO change math:
//1. infinity to zero,
//2. + to *,
//3. > to <,
//3. 0 to 1,

extension VertexIndex: IndexType {}

//TODO use Decimal type instead of Double
typealias RateType = Double
typealias RateMonoidType = SumNum<RateType>

private let defaultRate = RateMonoidType.Sum(.infinity)

//have to write free function because swift does not allow me to extend `SumNum` enum with protocol
private func rateComparator(_ lhs: RateMonoidType, _ rhs: RateMonoidType) -> Bool {
  switch  (lhs, rhs) {
  case (.Sum(let v), .Sum(let v2)):
    return v > v2
  }
}

let testVertexes: [RateInfo<RateMonoidType>] = [
  RateInfo(source: "1", destination: "2", exchange: "KRAKEN", weight: 1  , backwardWeight: 1.0, date: Date()),
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

let ratesTable = RatesTable<RateMonoidType>()

testVertexes.forEach { rateInfo in
  ratesTable.update(rateInfo: rateInfo)
}

let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex,RateMonoidType>(
  defaultRate: defaultRate,
  rateComparator: rateComparator)

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
  
  let vertexIndexes = exchangeRateCalculator
    .bestRatesPath(source: source, destination: destination)
  
  let result = vertexIndexes.map { ($0.vertex.currency, $0.vertex.exchange) }
  
  let rate = ratesTable.getRate(for: vertexIndexes)
  
  print("best path: \(result)")
  print("best path: \(rate!)")
}

processBestPath()

