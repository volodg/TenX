//
//  ExchangeRateCalculator.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import SquareMatrix

protocol IndexType: Equatable {
  var index: Int { get }
}

final class ExchangeRateCalculator<Index: IndexType> {
  
  //TODO use Decimal type instead of Double
  private let rate = SquareMatrix<Double>(defValue: .infinity)
  private let next = SquareMatrix<Index?>(defValue: nil)
  
  //TODO make it template to remove dependence on type
  //TODO test
  func updateBestRatesTable(elements: [(source: Index, destination: Index, weight: Double)]) {
    
    let currenciesCount = exchangesVertex.currenciesCount
    
    rate.reallocate(newEdgeSize: currenciesCount)
    next.reallocate(newEdgeSize: currenciesCount)
    
    for info in elements {
      rate[(info.source.index, info.destination.index)] = info.weight
      next[(info.source.index, info.destination.index)] = info.destination
    }
    
    for k in 0..<currenciesCount {
      for i in 0..<currenciesCount {
        for j in 0..<currenciesCount {
          if rate[(i, j)] > rate[(i, k)] + rate[(k, j)] {
            rate[(i, j)] = rate[(i, k)] + rate[(k, j)]
            next[(i, j)] = next[(i, k)]
          }
        }
      }
    }
  }
  
  //TODO make it template to remove dependence on type
  //TODO test
  func bestPath(source: Index, destination: Index) -> [Index] {
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
