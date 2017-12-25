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

enum CalculateRateStrategies {
  //this strategy forbids adding
  //new vertices which may lead to grath cycles
  case strict
  //in case of path cycles
  //just returns it, so result will be like
  //BTC -> ETH -> BTC
  //it allows user to get profit without echange :-)
  case unstrict
}

final class AppLogic {
  
  let strategy: CalculateRateStrategies
  
  init(strategy: CalculateRateStrategies) {
    self.strategy = strategy
  }
  
  private let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()
  private let ratesTable = RatesTable()
  
  func getIndex(for vertex: Vertex) -> VertexIndex? {
    return ratesTable.getIndex(for: vertex)
  }
  
  func getAllExchanges() -> Set<Exchange> {
    return ratesTable.getAllExchanges()
  }
  
  func disableEdge(for rateInfo: RateInfo) -> (FullExchangeInfo, FullExchangeInfo)? {
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
    
    let allowCycle: Bool
    switch strategy {
    case .strict:
      allowCycle = false
    case .unstrict:
      allowCycle = true
    }
    
    let vertexIndexes = exchangeRateCalculator
      .bestRatesPath(source: source, destination: destination, allowCycle: allowCycle)
    
    guard let rate = ratesTable.getRate(for: vertexIndexes) else {
      return .failure(.invalidPath(path: vertexIndexes))
    }
    
    let path = vertexIndexes.map { $0.vertex }
    return .success(PathRateInfo(pair: pair, rate: rate, path: path))
  }
}
