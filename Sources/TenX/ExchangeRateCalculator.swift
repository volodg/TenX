//
//  ExchangeRateCalculator.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

final class ExchangeRateCalculator {
  
  private let rate = SquareMatrix<Double>(defValue: .infinity)
  private let next = SquareMatrix<Int?>(defValue: nil)

  //TODO make it template to remove dependence on type
  //TODO test
  func updateBestRatesTable(exchangesVertex: ExchangesVertex) {
    
    let currenciesCount = exchangesVertex.currenciesCount
    
    rate.reallocate(newEdgeSize: currenciesCount)
    next.reallocate(newEdgeSize: currenciesCount)
    
    exchangesVertex.forEach { info in
      rate[(info.sourceIndex, info.destinationIndex)] = info.exchangeInfo.weight
      next[(info.sourceIndex, info.destinationIndex)] = info.destinationIndex
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
  func bestPath(source: Int, destination: Int) -> [Int] {
    if next[(source, destination)] == nil {
      return []
    }
    var currentSource = source
    var result = [currentSource]
    while currentSource != destination {
      currentSource = next[(currentSource, destination)]!
      result.append(currentSource)
    }
    return result
  }
  
  //TODO make it template to remove dependence on type
  //TODO test
  func bestPath(source: Currency, destination: Currency) -> [Currency] {
    
    let sourceIndex = exchangesVertex.currencyToIndexDict[source]!
    let destinationIndex = exchangesVertex.currencyToIndexDict[destination]!
    
    let result = bestPath(source: sourceIndex, destination: destinationIndex)
    
    return result.map { exchangesVertex.indexToCurrencyDict[$0]! }
  }
}

let exchangeRateCalculator = ExchangeRateCalculator()
