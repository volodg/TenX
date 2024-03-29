//
//  ExchangeRateCalculator.swift
//  ExchangeRateCalculator
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import SquareMatrix
import Result
import Commons

public protocol IndexType: Equatable {
  var index: Int { get }
}

public enum CalculateRateStrategies {
  //it tries to build path ignoring cycles
  //but in this case the result's rate is not the best,
  //because best one is "infinity profit"
  case unstrictIgnoreCycles
  //This strategy prohibits addition of
  //new vertices that can lead to cycles
  case strict
  //in case of path's cycles
  //just returns it, so result might be like
  //(BTC, KRAKEN) -> (ETH, KRAKEN) -> (BTC, KRAKEN)
  //it allows user to get "infinity profit"
  case unstrictAllowCycle
}

public final class ExchangeRateCalculator<Index: IndexType, RateT: Monoid & Maximum> {
  
  public convenience init() {
    self.init(
      rate: SquareMatrix(defValue: RateT.maximum()),
      next: SquareMatrix(defValue: nil))
  }
  
  private init(rate: SquareMatrix<RateT>, next: SquareMatrix<Index?>) {
    self.rate = rate
    self.next = next
  }
  
  public func copy() -> ExchangeRateCalculator<Index, RateT> {
    return ExchangeRateCalculator(rate: rate.copy(), next: next.copy())
  }
  
  private let rate: SquareMatrix<RateT>
  private let next: SquareMatrix<Index?>
  
  public func updateRatesTable(currenciesCount: Int, elements: [(source: Index, destination: Index, weight: RateT)]) {
    
    rate.reallocate(newEdgeSize: currenciesCount)
    next.reallocate(newEdgeSize: currenciesCount)
    
    for info in elements {
      rate[(info.source.index, info.destination.index)] = info.weight
      next[(info.source.index, info.destination.index)] = info.destination
    }
    
    for k in 0..<currenciesCount {
      for i in 0..<currenciesCount {
        for j in 0..<currenciesCount {
          let newRate = rate[(i, k)].op(rate[(k, j)])
          if newRate.less(rate[(i, j)]) {
            rate[(i, j)] = newRate
            next[(i, j)] = next[(i, k)]
          }
        }
      }
    }
  }
  
  public enum BestRatesPathError: Error {
    case noPath(source: Index, destination: Index)
    case cyclicPath(source: Index, destination: Index)
  }
  
  public func bestRatesPath(source: Index, destination: Index, strategy: CalculateRateStrategies) -> Result<[Index],BestRatesPathError> {
    if next[(source.index, destination.index)] == nil {
      return .success([])
    }
    var currentSource = source
    var result = [currentSource]
    while currentSource != destination {
      let optionalNextSource = next[(currentSource.index, destination.index)]
      guard let nextSource = optionalNextSource else {
        assert(false, "algorithm bug, please try to fix")
        return .failure(.noPath(source: source, destination: destination))
      }
      currentSource = nextSource
      if result.contains(currentSource) {
        switch strategy {
        case .strict:
          assert(false, "algorithm bug, please try to fix")
          return .failure(.cyclicPath(source: source, destination: destination))
        case .unstrictAllowCycle:
          return .success(result + [currentSource])
        case .unstrictIgnoreCycles:
          return .success(result)
        }
      }
      result.append(currentSource)
    }
    return .success(result)
  }
  
}
