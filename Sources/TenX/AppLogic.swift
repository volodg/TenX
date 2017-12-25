//
//  AppLogic.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Result
import RatesTable
import ExchangeRateCalculator

extension VertexIndex: IndexType {}

final class AppLogic {
  
  private let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()
  private let ratesTable = RatesTable()
  
  func getIndex(for vertex: Vertex) -> VertexIndex? {
    return ratesTable.getIndex(for: vertex)
  }
  
  func getAllExchanges() -> Set<Exchange> {
    return ratesTable.getAllExchanges()
  }
  
  public func disableEdge(for rateInfo: RateInfo) -> (FullExchangeInfo, FullExchangeInfo)? {
    let result = ratesTable.disableEdge(for: rateInfo)
    exchangeRateCalculator.updateRatesTable(
      currenciesCount: ratesTable.currenciesCount,
      elements: ratesTable.allEdges)
    return result
  }
  
  func enableEdge(for rateInfo: RateInfo, fullInfo: (FullExchangeInfo, FullExchangeInfo)) {
    ratesTable.enableEdge(for: rateInfo, fullInfo: fullInfo)
    exchangeRateCalculator.updateRatesTable(
      currenciesCount: ratesTable.currenciesCount,
      elements: ratesTable.allEdges)
  }
  
  func update(rateInfo: RateInfo) -> Result<Void,RateInfoValidationError> {
    if let error = rateInfo.validationError(appLogic: self) {
      return .failure(error)
    }
    
    ratesTable.update(rateInfo: rateInfo)
    
    exchangeRateCalculator.updateRatesTable(
      currenciesCount: ratesTable.currenciesCount,
      elements: ratesTable.allEdges)
    
    return .success(())
  }
  
  enum GetRateError: Error {
    case undefinedSouce
    case undefinedDestination
    case invalidPath(path: [VertexIndex])
  }
  
  func getRateInfo(
    sourceCurrency: String,
    sourceExchange: String,
    destinationCurrency: String,
    destinationExchange: String) -> Result<PathRateInfo, GetRateError> {
    
    return getRateInfo(
      sourceCurrency: Currency(rawValue: sourceCurrency),
      sourceExchange: Exchange(rawValue: sourceExchange),
      destinationCurrency: Currency(rawValue: destinationCurrency),
      destinationExchange: Exchange(rawValue: destinationExchange))
  }
  
  func getRateInfo(
    sourceCurrency: Currency,
    sourceExchange: Exchange,
    destinationCurrency: Currency,
    destinationExchange: Exchange) -> Result<PathRateInfo, GetRateError> {
    
    let sourceVertex = Vertex(currency: sourceCurrency, exchange: sourceExchange)
    let destinationVertex = Vertex(currency: destinationCurrency, exchange: destinationExchange)
    return getRateInfo(pair: Pair(source: sourceVertex, destination: destinationVertex))
  }
  
  struct PathRateInfo {
    let pair: Pair
    let rate: Double
    let path: [Vertex]
  }
  
  func getRateInfo(pair: Pair) -> Result<PathRateInfo, GetRateError> {
    
    guard let source = ratesTable.getIndex(for: pair.source) else {
      return .failure(.undefinedSouce)
    }
    
    guard let destination = ratesTable.getIndex(for: pair.destination) else {
      return .failure(.undefinedSouce)
    }
    
    let vertexIndexes = exchangeRateCalculator
      .bestRatesPath(source: source, destination: destination)
    
    guard let rate = ratesTable.getRate(for: vertexIndexes) else {
      return .failure(.invalidPath(path: vertexIndexes))
    }
    
    let path = vertexIndexes.map { $0.vertex }
    return .success(PathRateInfo(pair: pair, rate: rate, path: path))
  }
}
