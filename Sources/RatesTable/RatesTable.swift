//
//  Vertex.swift
//  RatesTable
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation
import Commons

public final class RatesTable<RateT: Monoid & Ordered> {
  
  public init() {}
  
  public func copy() -> RatesTable {
    let result = RatesTable<RateT>()
    result.allExchangesByCurrency = allExchangesByCurrency
    result.allExchanges = allExchanges
    result.exchangeInfoByPair = exchangeInfoByPair
    result.currentIndex = currentIndex
    result.vertexToIndexDict = vertexToIndexDict
    return result
  }
  
  private var allExchangesByCurrency = [Currency:Set<Exchange>]()
  private var allExchanges = Set<Exchange>()
  private var exchangeInfoByPair = [Pair:FullExchangeInfo<RateT>]()
  private var currentIndex = 0
  private var vertexToIndexDict = [Vertex:VertexIndex]()
  
  public func getAllExchanges() -> Set<Exchange> {
    return allExchanges
  }
  
  public var currenciesCount: Int {
    return currentIndex
  }
  
  public func getIndex(for vertex: Vertex) -> VertexIndex? {
    return vertexToIndexDict[vertex]
  }
  
  private func createOrGetIndex(for vertex: Vertex) -> VertexIndex {
    if let result = vertexToIndexDict[vertex] {
      return result
    }
    
    let result = VertexIndex(vertex: vertex, index: currentIndex)
    vertexToIndexDict[vertex] = result
    currentIndex += 1
    return result
  }
  
  public func forEach(_ body: (FullExchangeInfo<RateT>) -> Void) {
    exchangeInfoByPair.forEach { body($0.value) }
  }
  
  public typealias EdgeWithWeight = (source: VertexIndex, destination: VertexIndex, weight: RateT)
  
  public var allEdges: [EdgeWithWeight] {
    return exchangeInfoByPair.map { (_, value) -> EdgeWithWeight in
      return (value.source, value.destination, value.exchangeInfo.weight)
    }
  }
  
  private func update(pair: Pair, exchangeInfo: ExchangeInfo<RateT>) {
    
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
  
  public func disableEdge(for pair: Pair) -> FullExchangeInfo<RateT>? {
    
    guard var info = exchangeInfoByPair[pair] else {
      return nil
    }
    
    let oldInfo = info
    info.exchangeInfo.weight = RateT.maximum()
    exchangeInfoByPair[pair] = info
    return oldInfo
  }
  
  private func enableEdge(for pair: Pair, fullInfo: FullExchangeInfo<RateT>) {
    exchangeInfoByPair[pair] = fullInfo
  }
  
  public struct DisabledEdgeInfo {
    let rateInfo: FullExchangeInfo<RateT>
    let backwardRateInfo: FullExchangeInfo<RateT>
  }
  
  public func disableEdges(for rateInfo: RateInfo<RateT>) -> DisabledEdgeInfo? {
    
    let pair = rateInfo.toPair
    guard let left = disableEdge(for: pair) else {
      return nil
    }
    
    let backwardPair = rateInfo.toBackwardPair
    guard let right = disableEdge(for: backwardPair) else {
      return nil
    }
    
    return DisabledEdgeInfo(rateInfo: left, backwardRateInfo: right)
  }
  
  public func enableEdges(for rateInfo: RateInfo<RateT>, edgeInfo: DisabledEdgeInfo) {
    exchangeInfoByPair[rateInfo.toPair] = edgeInfo.rateInfo
    exchangeInfoByPair[rateInfo.toBackwardPair] = edgeInfo.backwardRateInfo
  }
  
  private func updateExchangesPairs(with rateInfo: RateInfo<RateT>, currency: Currency) {
    
    var allExchanges = allExchangesByCurrency[currency] ?? Set()
    
    guard !allExchanges.contains(rateInfo.exchange) else { return }
    
    let otherExchanges = allExchanges.subtracting([rateInfo.exchange])
    
    for exchange in otherExchanges {
      
      //update pair
      let source = Vertex(currency: currency, exchange: rateInfo.exchange)
      let destination = Vertex(currency: currency, exchange: exchange)
      let exchangeInfo = ExchangeInfo(weight: RateT.e(), date: rateInfo.date)
      
      let pair = Pair(source: source, destination: destination)
      update(pair: pair, exchangeInfo: exchangeInfo)
      
      //update backward pair
      let backwardPair = Pair(source: destination, destination: source)
      update(pair: backwardPair, exchangeInfo: exchangeInfo)
    }
    
    allExchanges.insert(rateInfo.exchange)
    allExchangesByCurrency[currency] = allExchanges
  }
  
  private func updateExchangesPairs(with rateInfo: RateInfo<RateT>) {
    
    updateExchangesPairs(with: rateInfo, currency: rateInfo.source)
    updateExchangesPairs(with: rateInfo, currency: rateInfo.destination)
  }
  
  public func update(rateInfo: RateInfo<RateT>) {
    
    allExchanges.insert(rateInfo.exchange)
    
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
  
  public func getRate(for path: [VertexIndex]) -> RateT? {
    
    if path.count < 2 {
      return nil
    }
    
    var index = 1
    var result = RateT.e()
    
    while index < path.count {
      let pair = Pair(source: path[index - 1].vertex, destination: path[index].vertex)
      
      index += 1
      
      guard let exchangeInfo = exchangeInfoByPair[pair] else {
        //TODO return error !!!
        assert(false)
        continue
      }
      
      result = result.op(exchangeInfo.exchangeInfo.weight)
    }
    
    return result
  }
}

extension RateInfo {
  
  fileprivate var toPair: Pair {
    let source = Vertex(currency: self.source, exchange: exchange)
    let destination = Vertex(currency: self.destination, exchange: exchange)
    
    return Pair(source: source, destination: destination)
  }
  
  fileprivate var toBackwardPair: Pair {
    return reversed().toPair
  }
  
  public func reversed() -> RateInfo {
    
    return RateInfo(
      source: destination,
      destination: source,
      exchange: exchange,
      weight: backwardWeight,
      backwardWeight: weight,
      date: date)
  }
  
}
