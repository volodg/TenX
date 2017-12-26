//
//  AppLogic.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Result
import RatesTable
import ExchangeRateCalculator

//To avoid Index to Vertex calculation
//incapsulate Vertex's info inside of VertexIndex
extension VertexIndex: IndexType {}

final class AppLogic {
  
  var strategy: CalculateRateStrategies
  
  convenience init(strategy: CalculateRateStrategies = .unstrictIgnoreCycles) {
    self.init(strategy: strategy,
              exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>(),
              ratesTable: RatesTable())
  }
  
  private init(strategy: CalculateRateStrategies,
               exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>,
               ratesTable: RatesTable) {
    self.strategy = strategy
    self.exchangeRateCalculator = exchangeRateCalculator
    self.ratesTable = ratesTable
  }
  
  private let exchangeRateCalculator: ExchangeRateCalculator<VertexIndex>
  private let ratesTable: RatesTable
  
  func getIndex(for vertex: Vertex) -> VertexIndex? {
    return ratesTable.getIndex(for: vertex)
  }
  
  func getAllExchanges() -> Set<Exchange> {
    return ratesTable.getAllExchanges()
  }
  
  private func updateRatesTable() {
    exchangeRateCalculator.updateRatesTable(
      currenciesCount: ratesTable.currenciesCount,
      elements: ratesTable.allEdges)
  }
  
  private func disableEdge(for pair: Pair) {
    _ = ratesTable.disableEdge(for: pair)
  }
  
  func disableEdges(for rateInfo: RateInfo) -> RatesTable.DisabledEdgeInfo? {
    let result = ratesTable.disableEdges(for: rateInfo)
    updateRatesTable()
    return result
  }
  
  func enableEdges(for rateInfo: RateInfo, edgeInfo: RatesTable.DisabledEdgeInfo) {
    ratesTable.enableEdges(for: rateInfo, edgeInfo: edgeInfo)
    updateRatesTable()
  }
  
  func update(rateInfo: RateInfo) -> Result<Void,RateInfoValidationError> {
    if let error = rateInfo.validationError(appLogic: self) {
      return .failure(error)
    }
    
    ratesTable.update(rateInfo: rateInfo)
    updateRatesTable()
    
    return .success(())
  }
  
  enum GetRateError: Error {
    case undefinedSouce
    case undefinedDestination
    case invalidBestRatesPath(error: ExchangeRateCalculator<VertexIndex>.BestRatesPathError)
    case invalidRate(path: [VertexIndex])
  }
  
  struct PathRateInfo {
    let pair: Pair
    let rate: Double
    let path: [Vertex]
  }
  
  private func copy() -> AppLogic {
    return AppLogic(strategy: strategy,
                    exchangeRateCalculator: exchangeRateCalculator.copy(),
                    ratesTable: ratesTable.copy())
  }
  
  private func closeCycleByDisablingLastEdge(for vertexIndexes: [VertexIndex]) {
    guard vertexIndexes.count >= 2 else {
      assert(false, "logic error")
      return
    }
    
    let pairToDisable = Pair(
      source: vertexIndexes[vertexIndexes.count - 2].vertex,
      destination: vertexIndexes[vertexIndexes.count - 1].vertex)
    _ = disableEdge(for: pairToDisable)
    updateRatesTable()
  }
  
  private func bestRatesPath(for pair: Pair) -> Result<[VertexIndex],GetRateError> {
    
    guard let source = ratesTable.getIndex(for: pair.source) else {
      return .failure(.undefinedSouce)
    }
    
    guard let destination = ratesTable.getIndex(for: pair.destination) else {
      return .failure(.undefinedSouce)
    }
    
    let vertexIndexes = exchangeRateCalculator
      .bestRatesPath(source: source, destination: destination, strategy: strategy)
    
    switch vertexIndexes {
    case .success(let vertexIndexes):
      var result = vertexIndexes
      switch strategy {
      case .unstrictAllowCycle:
        break
      case .strict, .unstrictIgnoreCycles:
        if let last = vertexIndexes.last, last.vertex != pair.destination {
          assert(strategy != .strict, "logic error, we have cycles in strict strategy")
          
          let newPair = Pair(source: last.vertex, destination: pair.destination)
          
          let copy = self.copy()
          copy.closeCycleByDisablingLastEdge(for: vertexIndexes)
          
          switch copy.bestRatesPath(for: newPair) {
          case .success(let newValues):
            if !newValues.isEmpty {
              result.append(contentsOf: newValues[1...])
              result = result.removeCycles()
            }
            assert(newValues.count >= 2, "logic error, new sub path should not be empty")
          case .failure(let error):
            return .failure(error)
          }
        }
      }
      
      return .success(result)
    case .failure(let error):
      return .failure(.invalidBestRatesPath(error: error))
    }
  }
  
  func getRateInfo(pair: Pair) -> Result<PathRateInfo, GetRateError> {
    
    return bestRatesPath(for: pair).flatMap { vertexIndexes in
      guard let rate = ratesTable.getRate(for: vertexIndexes) else {
        return .failure(.invalidRate(path: vertexIndexes))
      }
      
      let path = vertexIndexes.map { $0.vertex }
      return .success(PathRateInfo(pair: pair, rate: rate, path: path))
    }
  }
}
