//
//  CommandsProcessor.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import RatesTable
import ExchangeRateCalculator

extension VertexIndex: IndexType {}

private let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()

private let ratesTable = RatesTable()

func updateRates(rateInfo: RateInfo) {
  
  guard rateInfo.isValid(ratesTable: ratesTable, exchangeRateCalculator: exchangeRateCalculator) else {
    return
  }
  
  ratesTable.update(rateInfo: rateInfo)
  
  exchangeRateCalculator.updateRatesTable(
    currenciesCount: ratesTable.currenciesCount,
    elements: ratesTable.allEdges)
}

func processExchangeRateRequest(
  sourceCurrency: String,
  sourceExchange: String,
  destinationCurrency: String,
  destinationExchange: String) {
  
  let sourceVertex = Vertex(
    currency: Currency(rawValue: sourceCurrency),
    exchange: Exchange(rawValue: sourceExchange))
  guard let source = ratesTable.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let destinationVertex = Vertex(
    currency: Currency(rawValue: destinationCurrency),
    exchange: Exchange(rawValue: destinationExchange))
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
