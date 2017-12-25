//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Commons
import RatesTable
import ExchangeRateCalculator

//TODO use Decimal type instead of Double
//TODO validate input SOURCE != DESTINATION

extension VertexIndex: IndexType {}

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
  
  let sourceVertex = Vertex(currency: Currency(rawValue: "BTC"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let source = ratesTable.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let destinationVertex = Vertex(currency: Currency(rawValue: "USD"), exchange: Exchange(rawValue: "KRAKEN"))
  guard let destination = ratesTable.getIndex(for: destinationVertex) else {
    print("invalid destination")
    return
  }
  
  let vertexIndexes = exchangeRateCalculator
    .bestRatesPath(source: source, destination: destination)
  
  let result = vertexIndexes.map { ($0.vertex.currency, $0.vertex.exchange) }
    .map { "\($0), \($0)" }
    .joined(separator: "\n")
  
  let rate = ratesTable.getRate(for: vertexIndexes)
  
  print("best path: \n\(result)")
  print("best rate: \(rate!)")
}

processBestPath()

