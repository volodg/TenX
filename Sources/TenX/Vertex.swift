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

struct Vertex {
  let pair: Pair
  let weight: Double
}

let testVertexes: [Vertex] = [
  Vertex(pair: Pair(source: "1", destination: "2"), weight: 1),
  Vertex(pair: Pair(source: "1", destination: "3"), weight: 1),
  Vertex(pair: Pair(source: "2", destination: "3"), weight: 0.5),
  Vertex(pair: Pair(source: "3", destination: "2"), weight: 0.5),
  Vertex(pair: Pair(source: "2", destination: "4"), weight: 1),
  Vertex(pair: Pair(source: "3", destination: "4"), weight: 1),
  Vertex(pair: Pair(source: "3", destination: "6"), weight: 2),
  Vertex(pair: Pair(source: "4", destination: "6"), weight: 2),
  Vertex(pair: Pair(source: "3", destination: "5"), weight: 2),
  Vertex(pair: Pair(source: "4", destination: "5"), weight: 2),
  Vertex(pair: Pair(source: "6", destination: "5"), weight: 0.5),
  Vertex(pair: Pair(source: "5", destination: "6"), weight: 0.5),
  Vertex(pair: Pair(source: "6", destination: "7"), weight: 2),
  Vertex(pair: Pair(source: "5", destination: "7"), weight: 0.5),
  //  Vertex(pair: Pair(source: "7", destination: "5"), weight: 1),
]

struct ExchangeInfo {
  let exchanger: String
  let weight: Double
  let date: Date
}

class ExchangesVertex {
  
  struct ExchangeInfoWithIndexes {
    let pair: Pair//do we need it?
    let exchangeInfo: ExchangeInfo
    let sourceIndex: Int
    let destinationIndex: Int
  }
  
  /*private */var exchangeInfoByPair = [Pair:ExchangeInfoWithIndexes]()
  
  private var currentIndex = 0
  private var currencyToIndexDict = [Currency:Int]()
  private var indexToCurrencyDict = [Int:Currency]()
  
  private func index(for currency: Currency) -> Int {
    if let result = currencyToIndexDict[currency] {
      return result
    }
    
    currencyToIndexDict[currency] = currentIndex
    indexToCurrencyDict[currentIndex] = currency
    let result = currentIndex
    currentIndex += 1
    return result
  }
  
  private func fillIndexes(vertexes: [Vertex]) {
    
    func storeCurrencyIndex(for currency: Currency) {
      if currencyToIndexDict[currency] == nil {
        currencyToIndexDict[currency] = currentIndex
        indexToCurrencyDict[currentIndex] = currency
        currentIndex += 1
      }
    }
    
    for vertex in vertexes {
      storeCurrencyIndex(for: vertex.pair.source)
      storeCurrencyIndex(for: vertex.pair.destination)
    }
  }
  
  func enumerate(_ f: ((x: Int, y: Int), _ weight: Double) -> Void) {
    
  }
  
  func update(pair: Pair, exchangeInfo: ExchangeInfo) {
    
    if let oldExchangeInfo = exchangeInfoByPair[pair],
      exchangeInfo.date < oldExchangeInfo.exchangeInfo.date {
      //WARN log here
      return
    }
    
    let sourceIndex = 0
    let destinationIndex = 0
    
    let newValue = ExchangeInfoWithIndexes(
      pair: pair,
      exchangeInfo: exchangeInfo,
      sourceIndex: sourceIndex,
      destinationIndex: destinationIndex)
    
    exchangeInfoByPair[pair] = newValue
  }
}

let exchangesVertex = ExchangesVertex()

