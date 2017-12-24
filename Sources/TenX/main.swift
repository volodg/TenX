//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Foundation

//TODO validate SOURCE != DESTINATION
//TODO store exchanger

struct RateInfo {
  let pair: Pair
  let weight: Double
}

let testVertexes: [RateInfo] = [
  RateInfo(pair: Pair(source: "1", destination: "2"), weight: 1),
  RateInfo(pair: Pair(source: "1", destination: "3"), weight: 1),
  RateInfo(pair: Pair(source: "2", destination: "3"), weight: 0.5),
  RateInfo(pair: Pair(source: "3", destination: "2"), weight: 0.5),
  RateInfo(pair: Pair(source: "2", destination: "4"), weight: 1),
  RateInfo(pair: Pair(source: "3", destination: "4"), weight: 1),
  RateInfo(pair: Pair(source: "3", destination: "6"), weight: 2),
  RateInfo(pair: Pair(source: "4", destination: "6"), weight: 2),
  RateInfo(pair: Pair(source: "3", destination: "5"), weight: 2),
  RateInfo(pair: Pair(source: "4", destination: "5"), weight: 2),
  RateInfo(pair: Pair(source: "6", destination: "5"), weight: 0.5),
  RateInfo(pair: Pair(source: "5", destination: "6"), weight: 0.5),
  RateInfo(pair: Pair(source: "6", destination: "7"), weight: 2),
  RateInfo(pair: Pair(source: "5", destination: "7"), weight: 0.5),
  //  RateInfo(pair: Pair(source: "7", destination: "5"), weight: 1),
]

let exchangesVertex = ExchangesVertex()

testVertexes.forEach { vertex in
  
  let exchangeInfo = ExchangeInfo(exchanger: "some exchanger", weight: vertex.weight, date: Date())
  exchangesVertex.update(pair: vertex.pair, exchangeInfo: exchangeInfo)
}

let exchangeRateCalculator = ExchangeRateCalculator<CurrencyIndex>()

exchangeRateCalculator.updateBestRatesTable(elements: exchangesVertex.allEdges)

func processBestPath() {
  
  guard let source = exchangesVertex.getIndex(for: "1") else {
    print("invalid source")
    return
  }
  
  guard let destination = exchangesVertex.getIndex(for: "7") else {
    print("invalid destination")
    return
  }
  
  let result = exchangeRateCalculator.bestPath(source: source, destination: destination)
  
  print("best path: \(result)")
}

processBestPath()

