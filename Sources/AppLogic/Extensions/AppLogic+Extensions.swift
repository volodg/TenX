//
//  AppLogic+Extensions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import Result
import RatesTable

extension AppLogic {
  
  public func getRateInfo(
    sourceCurrency: Currency,
    sourceExchange: Exchange,
    destinationCurrency: Currency,
    destinationExchange: Exchange) -> Result<PathRateInfo, GetRateError> {
    
    let sourceVertex = Vertex(currency: sourceCurrency, exchange: sourceExchange)
    let destinationVertex = Vertex(currency: destinationCurrency, exchange: destinationExchange)
    return getRateInfo(pair: Pair(source: sourceVertex, destination: destinationVertex))
  }
  
}
