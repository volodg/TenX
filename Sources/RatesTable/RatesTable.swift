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
  private var exchangeInfoByPair = [Pair:FullExchangeInfo]()
  
  public var currenciesCount: Int {
    return currentIndex
  }
  
  private var currentIndex = 0
  private var vertexToIndexDict = [Vertex:VertexIndex]()
  
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
      //TODO change weight on 1
      let exchangeInfo = ExchangeInfo(weight: 0, date: rateInfo.date)
      
      update(pair: pair, exchangeInfo: exchangeInfo)
      
      //update backward pair
      let backwardSource = Vertex(currency: currency, exchange: exchange)
      let backwardDestination = Vertex(currency: currency, exchange: rateInfo.exchange)
      
      let backwardPair = Pair(source: backwardSource, destination: backwardDestination)
      //TODO change weight on 1
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