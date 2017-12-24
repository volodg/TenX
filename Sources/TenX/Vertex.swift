//
//  Vertex.swift
//  TenXPackageDescription
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation

typealias Currency = String

struct Pair {
  let source: Currency
  let destination: Currency
}

extension Pair: Equatable {
  static func ==(lhs: Pair, rhs: Pair) -> Bool {
    return lhs.source == rhs.source
      && lhs.destination == rhs.destination
  }
}

extension Pair: Hashable {
  var hashValue: Int {
    return source.hashValue ^ destination.hashValue
  }
}

struct ExchangeInfo {
  let exchanger: String
  let weight: Double
  let date: Date
}

struct FullExchangeInfo {
  let exchangeInfo: ExchangeInfo
  let source: CurrencyIndex
  let destination: CurrencyIndex
}

struct CurrencyIndex {
  let currency: Currency
  let index: Int
}

extension CurrencyIndex: Hashable {
  var hashValue: Int {
    return currency.hashValue ^ index
  }
}

extension CurrencyIndex: IndexType {
  static func ==(lhs: CurrencyIndex, rhs: CurrencyIndex) -> Bool {
    return lhs.currency == rhs.currency
      && lhs.index == rhs.index
  }
}

class ExchangesVertex {
  
  /*private */var exchangeInfoByPair = [Pair:FullExchangeInfo]()
  
  var currenciesCount: Int {
    return currentIndex
  }
  
  private var currentIndex = 0
  /*private */var currencyToIndexDict = [Currency:CurrencyIndex]()
  //TODO remove this property
  /*private */var indexToCurrencyDict = [Int:Currency]()
  
  //TODO test
  func getIndex(for currency: Currency) -> CurrencyIndex? {
    return currencyToIndexDict[currency]
  }
  
  //TODO test
  private func createOrGetIndex(for currency: Currency) -> CurrencyIndex {
    if let result = currencyToIndexDict[currency] {
      return result
    }
    
    let result = CurrencyIndex(currency: currency, index: currentIndex)
    currencyToIndexDict[currency] = result
    indexToCurrencyDict[currentIndex] = currency
    currentIndex += 1
    return result
  }
  
  //TODO test
  func forEach(_ body: (FullExchangeInfo) -> Void) {
    exchangeInfoByPair.forEach { body($0.value) }
  }
  
  typealias Edge = (source: CurrencyIndex, destination: CurrencyIndex, weight: Double)
  
  var allEdges: [Edge] {
    return exchangeInfoByPair.map { (_, value) -> Edge in
      return (value.source, value.destination, value.exchangeInfo.weight)
    }
  }
  
  //TODO test
  func update(pair: Pair, exchangeInfo: ExchangeInfo) {
    
    if let oldExchangeInfo = exchangeInfoByPair[pair],
      exchangeInfo.date < oldExchangeInfo.exchangeInfo.date {
      //WARN log old date here
      return
    }
    
    let newValue = FullExchangeInfo(
      exchangeInfo: exchangeInfo,
      source: createOrGetIndex(for: pair.source),
      destination: createOrGetIndex(for: pair.destination))
    
    exchangeInfoByPair[pair] = newValue
  }
}
