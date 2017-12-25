//
//  ExchangeRateCalculator.swift
//  ExchangeRateCalculator
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import SquareMatrix
import Commons

public protocol IndexType: Equatable {
  var index: Int { get }
}

public final class ExchangeRateCalculator<Index: IndexType> {
  
  public init() {}
  
  private lazy var rate: SquareMatrix<Double> = {
    return SquareMatrix<Double>(defValue: 0)
  }()
  private let next = SquareMatrix<Index?>(defValue: nil)
  
  //TODO test
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
  
  //TODO test
  public func bestRatesPath(source: Index, destination: Index) -> [Index] {
    if next[(source.index, destination.index)] == nil {
      return []
    }
    var currentSource = source
    var result = [currentSource]
    while currentSource != destination {
      //TODO fix force unwrapp
      currentSource = next[(currentSource.index, destination.index)]!
      if result.contains(currentSource) {
        assert(false)
        return []
      }
      result.append(currentSource)
    }
    return result
  }
  
}
