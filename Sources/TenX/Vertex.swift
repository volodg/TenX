//
//  Vertex.swift
//  TenXPackageDescription
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation

typealias Currency = String
typealias Exchange = String

struct RateInfo {
  let source: Currency
  let destination: Currency
  let exchange: Exchange
  let weight: Double
  let reverseWeight: Double
}

struct Vertex {
  let currency: Currency
  let exchange: Exchange
}

extension Vertex: Equatable {
  static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.currency == rhs.currency
      && lhs.exchange == rhs.exchange
  }
}

extension Vertex: Hashable {
  var hashValue: Int {
    return currency.hashValue ^ exchange.hashValue
  }
}

struct Pair {
  let source: Vertex
  let destination: Vertex
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
  let weight: Double
  let date: Date
}

struct FullExchangeInfo {
  let exchangeInfo: ExchangeInfo
  let source: VertexIndex
  let destination: VertexIndex
}

struct VertexIndex {
  let vertex: Vertex
  let index: Int
}

extension VertexIndex: Hashable {
  var hashValue: Int {
    return vertex.hashValue ^ index
  }
}

extension VertexIndex: IndexType {
  static func ==(lhs: VertexIndex, rhs: VertexIndex) -> Bool {
    return lhs.vertex == rhs.vertex
      && lhs.index == rhs.index
  }
}

class ExchangesVertex {
  
  /*private */var exchangeInfoByPair = [Pair:FullExchangeInfo]()
  
  var currenciesCount: Int {
    return currentIndex
  }
  
  private var currentIndex = 0
  /*private */var vertexToIndexDict = [Vertex:VertexIndex]()
  //TODO remove this property
  /*private */var indexToVertexDict = [Int:Vertex]()
  
  //TODO test
  func getIndex(for vertex: Vertex) -> VertexIndex? {
    return vertexToIndexDict[vertex]
  }
  
  //TODO test
  private func createOrGetIndex(for vertex: Vertex) -> VertexIndex {
    if let result = vertexToIndexDict[vertex] {
      return result
    }
    
    let result = VertexIndex(vertex: vertex, index: currentIndex)
    vertexToIndexDict[vertex] = result
    indexToVertexDict[currentIndex] = vertex
    currentIndex += 1
    return result
  }
  
  //TODO test
  func forEach(_ body: (FullExchangeInfo) -> Void) {
    exchangeInfoByPair.forEach { body($0.value) }
  }
  
  typealias Edge = (source: VertexIndex, destination: VertexIndex, weight: Double)
  
  var allEdges: [Edge] {
    return exchangeInfoByPair.map { (_, value) -> Edge in
      return (value.source, value.destination, value.exchangeInfo.weight)
    }
  }
  
  //TODO test
  private func update(pair: Pair, exchangeInfo: ExchangeInfo) {
    
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
  
  //TODO test
  func update(rateInfo: RateInfo) {
    
    let source = Vertex(currency: rateInfo.source, exchange: rateInfo.exchange)
    let destination = Vertex(currency: rateInfo.destination, exchange: rateInfo.exchange)
    
    let pair1 = Pair(source: source, destination: destination)
    let exchangeInfo1 = ExchangeInfo(weight: rateInfo.weight, date: Date())
    
    update(pair: pair1, exchangeInfo: exchangeInfo1)
    
    let pair2 = Pair(source: destination, destination: source)
    let exchangeInfo2 = ExchangeInfo(weight: rateInfo.reverseWeight, date: Date())
    
    update(pair: pair2, exchangeInfo: exchangeInfo2)
    
    //TODO add 1 to 1 edges
  }
}
