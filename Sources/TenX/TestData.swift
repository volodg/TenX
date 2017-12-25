//
//  TestData.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Foundation
import RatesTable

let testVertexes: [RateInfo] = [
  RateInfo(source: "BTC" , destination: "ETH" , exchange: "KRAKEN", weight: 1.1,  backwardWeight: 0.9 , date: Date()),
  RateInfo(source: "BTC" , destination: "DASH", exchange: "KRAKEN", weight: 0.5,  backwardWeight: 1   , date: Date()),
  RateInfo(source: "ETH" , destination: "DASH", exchange: "KRAKEN", weight: 0.9,  backwardWeight: 1.11, date: Date()),
  RateInfo(source: "ETH" , destination: "DASH", exchange: "KRAKEN", weight: 0.90, backwardWeight: 0.33, date: Date()),
  RateInfo(source: "ETH" , destination: "XRP" , exchange: "KRAKEN", weight: 1  ,  backwardWeight: 1   , date: Date()),
  RateInfo(source: "DASH", destination: "XRP" , exchange: "KRAKEN", weight: 1  ,  backwardWeight: 0.9 , date: Date()),
  RateInfo(source: "DASH", destination: "BCH" , exchange: "KRAKEN", weight: 0.5,  backwardWeight: 2   , date: Date()),
  RateInfo(source: "DASH", destination: "LTC" , exchange: "KRAKEN", weight: 0.5,  backwardWeight: 2   , date: Date()),
  RateInfo(source: "DASH", destination: "LTC" , exchange: "KRAKEN", weight: 0.5,  backwardWeight: 0.5 , date: Date()),
  RateInfo(source: "XRP" , destination: "BCH" , exchange: "KRAKEN", weight: 0.45, backwardWeight: 2   , date: Date()),
  RateInfo(source: "XRP" , destination: "LTC" , exchange: "KRAKEN", weight: 0.45, backwardWeight: 2   , date: Date()),
  RateInfo(source: "BCH" , destination: "LTC" , exchange: "KRAKEN", weight: 1.0 , backwardWeight: 0.5 , date: Date()),
  RateInfo(source: "BCH" , destination: "USD" , exchange: "KRAKEN", weight: 2   , backwardWeight: 0.5 , date: Date()),
  RateInfo(source: "LTC" , destination: "USD" , exchange: "KRAKEN", weight: 0.5 , backwardWeight: 0.5 , date: Date()),
  
  RateInfo(source: "BTC" , destination: "ETH" , exchange: "GDAX", weight: 1   , backwardWeight: 0.9, date: Date()),
  RateInfo(source: "BTC" , destination: "DASH", exchange: "GDAX", weight: 1   , backwardWeight: 1  , date: Date()),
  RateInfo(source: "ETH" , destination: "DASH", exchange: "GDAX", weight: 0.9 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "ETH" , destination: "XRP" , exchange: "GDAX", weight: 1   , backwardWeight: 1  , date: Date()),
  RateInfo(source: "DASH", destination: "XRP" , exchange: "GDAX", weight: 1.1 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "DASH", destination: "LTC" , exchange: "GDAX", weight: 0.5 , backwardWeight: 1  , date: Date()),
  RateInfo(source: "DASH", destination: "BCH" , exchange: "GDAX", weight: 0.5 , backwardWeight: 2  , date: Date()),
  RateInfo(source: "XRP" , destination: "LTC" , exchange: "GDAX", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "XRP" , destination: "BCH" , exchange: "GDAX", weight: 0.45, backwardWeight: 2  , date: Date()),
  RateInfo(source: "BCH" , destination: "LTC" , exchange: "GDAX", weight: 1.0 , backwardWeight: 0.5, date: Date()),
  RateInfo(source: "LTC" , destination: "USD" , exchange: "GDAX", weight: 0.6 , backwardWeight: 0.5, date: Date()),//here
  RateInfo(source: "BCH" , destination: "USD" , exchange: "GDAX", weight: 2   , backwardWeight: 0.5, date: Date()),
]
