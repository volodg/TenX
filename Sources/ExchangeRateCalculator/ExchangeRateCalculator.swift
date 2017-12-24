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

public final class ExchangeRateCalculator<Index: IndexType, WeightT: Monoid> {
  
  public typealias RateComparator = (_ lhs: WeightT, _ rhs: WeightT) -> Bool
  
  private let defaultRate: WeightT
  private let rateComparator: RateComparator
  
  public init(defaultRate: WeightT, rateComparator: @escaping RateComparator) {
    self.defaultRate = defaultRate
    self.rateComparator = rateComparator
  }
  
  private lazy var rate: SquareMatrix<WeightT> = {
    return SquareMatrix<WeightT>(defValue: self.defaultRate)
  }()
  private let next = SquareMatrix<Index?>(defValue: nil)
  
  //TODO test
  public func updateRatesTable(currenciesCount: Int, elements: [(source: Index, destination: Index, weight: WeightT)]) {
    
    rate.reallocate(newEdgeSize: currenciesCount)
    next.reallocate(newEdgeSize: currenciesCount)
    
    for info in elements {
      rate[(info.source.index, info.destination.index)] = info.weight
      next[(info.source.index, info.destination.index)] = info.destination
    }
    
    for k in 0..<currenciesCount {
      for i in 0..<currenciesCount {
        for j in 0..<currenciesCount {
          if rateComparator(rate[(i, j)], rate[(i, k)].mappend(rate[(k, j)])) {
            rate[(i, j)] = rate[(i, k)].mappend(rate[(k, j)])
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
      result.append(currentSource)
    }
    return result
  }
  
}
