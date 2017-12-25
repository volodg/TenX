//
//  Vertex.swift
//  RatesTable
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation

public final class RatesTable {
  
  public init() {}
  
  private var allExchangesByCurrency = [Currency:Set<Exchange>]()
  private var allExchanges = Set<Exchange>()
  
  public func getAllExchanges() -> Set<Exchange> {
    return allExchanges
  }
  
  private var exchangeInfoByPair = [Pair:FullExchangeInfo]()
  
  public var currenciesCount: Int {
    return currentIndex
  }
  
  private var currentIndex = 0
  private var vertexToIndexDict = [Vertex:VertexIndex]()
  
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
  
  public func forEach(_ body: (FullExchangeInfo) -> Void) {
    exchangeInfoByPair.forEach { body($0.value) }
  }
  
  public typealias EdgeWithWeight = (source: VertexIndex, destination: VertexIndex, weight: Double)
  
  public var allEdges: [EdgeWithWeight] {
    return exchangeInfoByPair.map { (_, value) -> EdgeWithWeight in
      return (value.source, value.destination, value.exchangeInfo.weight)
    }
  }
  
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
  
  private func disableEdge(for pair: Pair) -> FullExchangeInfo? {
    
    guard var info = exchangeInfoByPair[pair] else {
      return nil
    }
    
    let oldInfo = info
    info.exchangeInfo.weight = 0
    exchangeInfoByPair[pair] = info
    return oldInfo
  }
  
  private func enableEdge(for pair: Pair, fullInfo: FullExchangeInfo) {
    exchangeInfoByPair[pair] = fullInfo
  }
  
  public struct DisabledEdgeInfo {
    let rateInfo: FullExchangeInfo
    let backwardRateInfo: FullExchangeInfo
  }
  
  public func disableEdge(for rateInfo: RateInfo) -> DisabledEdgeInfo? {
    
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
  
  public func enableEdge(for rateInfo: RateInfo, edgeInfo: DisabledEdgeInfo) {
    exchangeInfoByPair[rateInfo.toPair] = edgeInfo.rateInfo
    exchangeInfoByPair[rateInfo.toBackwardPair] = edgeInfo.backwardRateInfo
  }
  
  private func updateExchangesPairs(with rateInfo: RateInfo, currency: Currency) {
    
    var allExchanges = allExchangesByCurrency[currency] ?? Set()
    
    guard !allExchanges.contains(rateInfo.exchange) else { return }
    
    let otherExchanges = allExchanges.subtracting([rateInfo.exchange])
    
    for exchange in otherExchanges {
      
      //update pair
      let source = Vertex(currency: currency, exchange: rateInfo.exchange)
      let destination = Vertex(currency: currency, exchange: exchange)
      let exchangeInfo = ExchangeInfo(weight: 1, date: rateInfo.date)
      
      let pair = Pair(source: source, destination: destination)
      update(pair: pair, exchangeInfo: exchangeInfo)
      
      //update backward pair
      let backwardPair = Pair(source: destination, destination: source)
      update(pair: backwardPair, exchangeInfo: exchangeInfo)
    }
    
    allExchanges.insert(rateInfo.exchange)
    allExchangesByCurrency[currency] = allExchanges
  }
  
  private func updateExchangesPairs(with rateInfo: RateInfo) {
    
    updateExchangesPairs(with: rateInfo, currency: rateInfo.source)
    updateExchangesPairs(with: rateInfo, currency: rateInfo.destination)
  }
  
  public func update(rateInfo: RateInfo) {
    
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
  
  public func getRate(for path: [VertexIndex]) -> Double? {
    
    if path.count < 2 {
      return nil
    }
    
    var index = 1
    var result = 1.0
    
    while index < path.count {
      let pair = Pair(source: path[index - 1].vertex, destination: path[index].vertex)
      
      index += 1
      
      guard let exchangeInfo = exchangeInfoByPair[pair] else {
        //TODO return error !!!
        assert(false)
        continue
      }
      
      result = result * exchangeInfo.exchangeInfo.weight
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
