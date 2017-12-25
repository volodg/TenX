//
//  Parser.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Foundation
import Result

public struct ParseError: Error {
  public let error:  String
}

public struct UpdateRatesInfo {
  public let updateTime: Date
  public let exchange: String
  public let sourceCurrency: String
  public let destinationCurrency: String
  public let rate: Double
  public let backwardRate: Double
}

public struct ExchangeRateRequestInfo {
  public let sourceExchange: String
  public let sourceCurrency: String
  public let destinationExchange: String
  public let destinationCurrency: String
}

public enum Command {
  //2017-11-01T09:42:23+00:05 KRAKEN ETH XRP 1 1
  case updateRates(UpdateRatesInfo)
  //EXCHANGE_RATE_REQUEST KRAKEN BTC KRAKEN USD
  case exchangeRateRequest(ExchangeRateRequestInfo)
}

public enum CommandsParser {
  
  private static func parseExchangeRateRequest(components: [String]) -> Result<Command, ParseError> {
    
    guard components.count >= 5 else {
      return .failure(ParseError(error: "wrong components count"))
    }
    
    let cmdComponents = components.map { $0.uppercased() }
    
    guard cmdComponents[0] == "EXCHANGE_RATE_REQUEST" else {
      return .failure(ParseError(error: "wrong components count"))
    }
    
    let result = ExchangeRateRequestInfo(
      sourceExchange: cmdComponents[1],
      sourceCurrency: cmdComponents[2],
      destinationExchange: cmdComponents[3],
      destinationCurrency: cmdComponents[4])
    
    return .success(.exchangeRateRequest(result))
  }
  
  private static func parseUpdateRates(components: [String]) -> Result<Command, ParseError> {
    
    return .failure(ParseError(error: "test error"))
  }
  
  public static func parse(line: String) -> Result<Command, ParseError> {
    
    let components = line.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
    
    let result = parseExchangeRateRequest(components: components)
      .flatMapError { _ in parseUpdateRates(components: components) }
    
    return result
  }
}
