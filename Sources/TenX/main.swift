//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Foundation

//TODO check time
//TODO validate SOURCE != DESTINATION
//TODO store exchanger

//fillIndexes(vertexes: allVertexes)

testVertexes.forEach { vertex in
  
  let exchangeInfo = ExchangeInfo(exchanger: "some exchanger", weight: vertex.weight, date: Date())
  exchangesVertex.update(pair: vertex.pair, exchangeInfo: exchangeInfo)
}


for i in 0..<2 {
  print("size: \(i)")
}

print("Hello World!!!: \(exchangesVertex.exchangeInfoByPair)")
