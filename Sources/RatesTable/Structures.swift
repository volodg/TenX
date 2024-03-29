//
//  Structures.swift
//  RatesTable
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation

public struct Currency {
  public let rawValue: String
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
  public let rawValue: String
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

public struct RateInfo<RateT> {
  public let source: Currency
  public let destination: Currency
  public let exchange: Exchange
  public let weight: RateT
  public let backwardWeight: RateT
  let date: Date
  
  public init(source: Currency, destination: Currency, exchange: Exchange, weight: RateT, backwardWeight: RateT, date: Date) {
    self.source = source
    self.destination = destination
    self.exchange = exchange
    self.weight = weight
    self.backwardWeight = backwardWeight
    self.date = date
  }
}

public struct Vertex {
  public let currency: Currency
  public let exchange: Exchange
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

public struct Pair {
  public let source: Vertex
  public let destination: Vertex
  public init(source: Vertex, destination: Vertex) {
    self.source = source
    self.destination = destination
  }
}

extension Pair: Equatable {
  public static func ==(lhs: Pair, rhs: Pair) -> Bool {
    return lhs.source == rhs.source
      && lhs.destination == rhs.destination
  }
}

extension Pair: Hashable {
  public var hashValue: Int {
    return source.hashValue ^ destination.hashValue
  }
}

struct ExchangeInfo<RateT> {
  internal(set) var weight: RateT
  let date: Date
}

public struct FullExchangeInfo<RateT> {
  internal(set) var exchangeInfo: ExchangeInfo<RateT>
  let source: VertexIndex
  let destination: VertexIndex
}

public struct VertexIndex {
  public let vertex: Vertex
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
