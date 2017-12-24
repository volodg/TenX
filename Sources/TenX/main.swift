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
//TODO change math:
//1. infinity to zero,
//2. + to *,
//2. > to <,

let testVertexes: [RateInfo] = [
  RateInfo(source: "1", destination: "2", exchange: "KRAKEN", weight: 1  , reverseWeight: 1),
  RateInfo(source: "1", destination: "3", exchange: "KRAKEN", weight: 1  , reverseWeight: 1),
  RateInfo(source: "2", destination: "3", exchange: "KRAKEN", weight: 0.5, reverseWeight: 0.5),
  RateInfo(source: "2", destination: "4", exchange: "KRAKEN", weight: 1  , reverseWeight: 1),
  RateInfo(source: "3", destination: "4", exchange: "KRAKEN", weight: 1  , reverseWeight: 1),
  RateInfo(source: "3", destination: "6", exchange: "KRAKEN", weight: 2  , reverseWeight: 2),
  RateInfo(source: "4", destination: "6", exchange: "KRAKEN", weight: 2  , reverseWeight: 2),
  RateInfo(source: "3", destination: "5", exchange: "KRAKEN", weight: 2  , reverseWeight: 2),
  RateInfo(source: "4", destination: "5", exchange: "KRAKEN", weight: 2  , reverseWeight: 2),
  RateInfo(source: "5", destination: "6", exchange: "KRAKEN", weight: 0.5, reverseWeight: 0.5),
  RateInfo(source: "6", destination: "7", exchange: "KRAKEN", weight: 2  , reverseWeight: 2),
  RateInfo(source: "5", destination: "7", exchange: "KRAKEN", weight: 0.5, reverseWeight: 0.5),
  //  RateInfo(pair: Pair(source: "7", destination: "5"), weight: 1),
]

let exchangesVertex = ExchangesVertex()

testVertexes.forEach { rateInfo in
  exchangesVertex.update(rateInfo: rateInfo)
}

let exchangeRateCalculator = ExchangeRateCalculator<VertexIndex>()

exchangeRateCalculator.updateBestRatesTable(elements: exchangesVertex.allEdges)

func processBestPath() {
  
  let sourceVertex = Vertex(currency: "1", exchange: "KRAKEN")
  guard let source = exchangesVertex.getIndex(for: sourceVertex) else {
    print("invalid source")
    return
  }
  
  let distanceVertex = Vertex(currency: "7", exchange: "KRAKEN")
  guard let destination = exchangesVertex.getIndex(for: distanceVertex) else {
    print("invalid destination")
    return
  }
  
  let result = exchangeRateCalculator.bestPath(source: source, destination: destination)
  
  print("best path: \(result)")
}

processBestPath()

