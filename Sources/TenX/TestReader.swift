//
//  TestReader.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

private var lineIndex = 0

let lines = [
  "2017-11-01T09:42:24+00:00 KRAKEN BTC ETH 1.1 0.9",
//  "2017-11-01T09:42:25+00:00 KRAKEN BTC ETH 0.5 2",
  "2017-11-01T09:42:25+00:00 KRAKEN BTC DASH 0.5 1",
  "2017-11-01T09:42:26+00:00 KRAKEN ETH DASH 0.9 1.11",
  "2017-11-01T09:42:27+00:00 KRAKEN ETH DASH 0.9 0.33",
  "2017-11-01T09:42:28+00:00 KRAKEN ETH XRP 1 1",
  "2017-11-01T09:42:29+00:00 KRAKEN DASH XRP 1 0.9",
  "2017-11-01T09:42:30+00:00 KRAKEN DASH BCH 0.5 2",
  "2017-11-01T09:42:31+00:00 KRAKEN DASH LTC 0.5 2",
  "2017-11-01T09:42:32+00:00 KRAKEN DASH LTC 0.5 0.5",
  "2017-11-01T09:42:33+00:00 KRAKEN XRP BCH 0.45 2",
  "2017-11-01T09:42:34+00:00 KRAKEN XRP LTC 0.45 2",
  "2017-11-01T09:42:35+00:00 KRAKEN BCH LTC 1.0 0.5",
  "2017-11-01T09:42:36+00:00 KRAKEN BCH USD 2 0.5",
  "2017-11-01T09:42:37+00:00 KRAKEN LTC USD 0.5 0.5",
  
  "2017-11-01T09:42:38+00:00 GDAX BTC ETH 1 0.9",
  "2017-11-01T09:42:39+00:00 GDAX BTC DASH 1 1",
  "2017-11-01T09:42:40+00:00 GDAX ETH DASH 0.9 0.5",
  "2017-11-01T09:42:41+00:00 GDAX ETH XRP 1 1",
  "2017-11-01T09:42:42+00:00 GDAX DASH XRP 1.1 0.5",
  "2017-11-01T09:42:43+00:00 GDAX DASH LTC 0.5 1",
  "2017-11-01T09:42:44+00:00 GDAX DASH BCH 0.5 2",
  "2017-11-01T09:42:45+00:00 GDAX XRP LTC 0.45 2",
  "2017-11-01T09:42:46+00:00 GDAX XRP BCH 0.45 2",
  "2017-11-01T09:42:47+00:00 GDAX BCH LTC 1.0 0.5",
  "2017-11-01T09:42:48+00:00 GDAX LTC USD 0.6 0.5",
  "2017-11-01T09:42:49+00:00 GDAX BCH USD 2 0.5",
  
  "EXCHANGE_RATE_REQUEST KRAKEN BTC GDAX USD",
]

func readTestLine() -> String? {
  
  guard lineIndex < lines.count else {
    return nil
  }
  
  let result = lines[lineIndex]
  
  lineIndex += 1
  
  return result
}
