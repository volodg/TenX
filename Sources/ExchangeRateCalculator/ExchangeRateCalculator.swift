//
//  ExchangeRateCalculator.swift
//  ExchangeRateCalculator
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import SquareMatrix
import Commons
import Result

public protocol IndexType: Equatable {
  var index: Int { get }
}

public final class ExchangeRateCalculator<Index: IndexType> {
  
  public init() {}
  
  private lazy var rate: SquareMatrix<Double> = {
    return SquareMatrix<Double>(defValue: 0)
  }()
  private let next = SquareMatrix<Index?>(defValue: nil)
  
  public func updateRatesTable(currenciesCount: Int, elements: [(source: Index, destination: Index, weight: Double)]) {
    
    rate.reallocate(newEdgeSize: currenciesCount)
    next.reallocate(newEdgeSize: currenciesCount)
    
    for info in elements {
      rate[(info.source.index, info.destination.index)] = info.weight
      next[(info.source.index, info.destination.index)] = info.destination
    }
    
    for k in 0..<currenciesCount {
      for i in 0..<currenciesCount {
        for j in 0..<currenciesCount {
          let newRate = rate[(i, k)] * rate[(k, j)]
          if rate[(i, j)] < newRate {
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
  
  public func bestRatesPath(source: Index, destination: Index, allowCycle: Bool) -> Result<[Index],BestRatesPathError> {
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
        if allowCycle {
          return .success(result + [currentSource])
        }
        assert(false, "algorithm bug, please try to fix")
        return .failure(.cyclicPath(source: source, destination: destination))
      }
      result.append(currentSource)
    }
    return .success(result)
  }
  
}
