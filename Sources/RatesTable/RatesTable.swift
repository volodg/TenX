//
//  Vertex.swift
//  RatesTable
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation

public struct Currency {
  let rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension Currency: Equatable {
  public static func ==(lhs: Currency, rhs: Currency) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

extension Currency: Hashable {
  public var hashValue: Int {
    return rawValue.hashValue
  }
}

public struct Exchange {
  let rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension Exchange: Equatable {
  public static func ==(lhs: Exchange, rhs: Exchange) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

extension Exchange: Hashable {
  public var hashValue: Int {
    return rawValue.hashValue
  }
}

public struct RateInfo {
  let source: Currency
  let destination: Currency
  let exchange: Exchange
  let weight: Double
  let backwardWeight: Double
  let date: Date
  
  public init(source: Currency, destination: Currency, exchange: Exchange, weight: Double, backwardWeight: Double, date: Date) {
    self.source = source
    self.destination = destination
    self.exchange = exchange
    self.weight = weight
    self.backwardWeight = backwardWeight
    self.date = date
  }
}

public struct Vertex {
  let currency: Currency
  let exchange: Exchange
  public init(currency: Currency, exchange: Exchange) {
    self.currency = currency
    self.exchange = exchange
  }
}

extension Vertex: Equatable {
  public static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.currency == rhs.currency
      && lhs.exchange == rhs.exchange
  }
}

extension Vertex: Hashable {
  public var hashValue: Int {
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

public struct FullExchangeInfo {
  let exchangeInfo: ExchangeInfo
  let source: VertexIndex
  let destination: VertexIndex
}

public struct VertexIndex {
  let vertex: Vertex
  public let index: Int
}

extension VertexIndex: Hashable {
  public static func ==(lhs: VertexIndex, rhs: VertexIndex) -> Bool {
    return lhs.vertex == rhs.vertex
      && lhs.index == rhs.index
  }
  
  public var hashValue: Int {
    return vertex.hashValue ^ index
  }
}

public final class RatesTable {
  
  public init() {}
  
  private var allExchangesByCurrency = [Currency:Set<Exchange>]()
  private var exchangeInfoByPair = [Pair:FullExchangeInfo]()
  
  public var currenciesCount: Int {
    return currentIndex
  }
  
  private var currentIndex = 0
  /*private */var vertexToIndexDict = [Vertex:VertexIndex]()
  //TODO remove this property
  /*private */var indexToVertexDict = [Int:Vertex]()
  
  //TODO test
  public func getIndex(for vertex: Vertex) -> VertexIndex? {
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
  public func forEach(_ body: (FullExchangeInfo) -> Void) {
    exchangeInfoByPair.forEach { body($0.value) }
  }
  
  public typealias Edge = (source: VertexIndex, destination: VertexIndex, weight: Double)
  
  public var allEdges: [Edge] {
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
  private func updateExchangesPairs(with rateInfo: RateInfo, currency: Currency) {
    
    var allExchanges = allExchangesByCurrency[currency] ?? Set()
    
    guard !allExchanges.contains(rateInfo.exchange) else { return }
    
    let otherExchanges = allExchanges.subtracting([rateInfo.exchange])
    
    for exchange in otherExchanges {
      
      //update pair
      let source = Vertex(currency: currency, exchange: rateInfo.exchange)
      let destination = Vertex(currency: currency, exchange: exchange)
      
      let pair = Pair(source: source, destination: destination)
      //TODO change on 1
      let exchangeInfo = ExchangeInfo(weight: 0, date: rateInfo.date)
      
      update(pair: pair, exchangeInfo: exchangeInfo)
      
      //update backward pair
      let backwardSource = Vertex(currency: currency, exchange: exchange)
      let backwardDestination = Vertex(currency: currency, exchange: rateInfo.exchange)
      
      let backwardPair = Pair(source: backwardSource, destination: backwardDestination)
      //TODO change on 1
      let backwardExchangeInfo = ExchangeInfo(weight: 0, date: rateInfo.date)
      
      update(pair: backwardPair, exchangeInfo: backwardExchangeInfo)
    }
    
    allExchanges.insert(rateInfo.exchange)
    allExchangesByCurrency[currency] = allExchanges
  }
  
  //TODO test
  private func updateExchangesPairs(with rateInfo: RateInfo) {
    
    updateExchangesPairs(with: rateInfo, currency: rateInfo.source)
    updateExchangesPairs(with: rateInfo, currency: rateInfo.destination)
  }
  
  //TODO test
  public func update(rateInfo: RateInfo) {
    
    updateExchangesPairs(with: rateInfo)
    
    //update pair
    let source = Vertex(currency: rateInfo.source, exchange: rateInfo.exchange)
    let destination = Vertex(currency: rateInfo.destination, exchange: rateInfo.exchange)
    
    let pair = Pair(source: source, destination: destination)
    let exchangeInfo = ExchangeInfo(weight: rateInfo.weight, date: rateInfo.date)
    
    update(pair: pair, exchangeInfo: exchangeInfo)
    
    //update backward pair
    let backwardPair = Pair(source: destination, destination: source)
    let backwardExchangeInfo = ExchangeInfo(weight: rateInfo.backwardWeight, date: rateInfo.date)
    
    update(pair: backwardPair, exchangeInfo: backwardExchangeInfo)
  }
}
