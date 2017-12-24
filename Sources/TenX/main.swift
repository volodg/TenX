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

//fillIndexes(vertexes: allVertexes)

testVertexes.forEach { vertex in
  
  let exchangeInfo = ExchangeInfo(exchanger: "some exchanger", weight: vertex.weight, date: Date())
  exchangesVertex.update(pair: vertex.pair, exchangeInfo: exchangeInfo)
}

updateBestRatesTable(exchangesVertex: exchangesVertex)

let result = bestPath(source: "1", destination: "7")

print("best path: \(result)")
