//
//  Parser.swift
//  Parser
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

private extension DateFormatter {
  
  static var RFC3339DateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }
}

public enum CommandsParser {
  
  private static func parseExchangeRateRequest(components: [String]) -> Result<Command, ParseError> {
    
    guard components.count >= 5 else {
      return .failure(ParseError(error: "wrong components count"))
    }
    
    guard components[0] == "EXCHANGE_RATE_REQUEST" else {
      return .failure(ParseError(error: "wrong components count"))
    }
    
    let result = ExchangeRateRequestInfo(
      sourceExchange: components[1],
      sourceCurrency: components[2],
      destinationExchange: components[3],
      destinationCurrency: components[4])
    
    return .success(.exchangeRateRequest(result))
  }
  
  //2017-11-01T09:42:23+00:05 KRAKEN ETH XRP 1 1
  private static func parseUpdateRates(components: [String]) -> Result<Command, ParseError> {
    
    guard components.count >= 6 else {
      return .failure(ParseError(error: "wrong components count"))
    }
    
    let dateFormatter = DateFormatter.RFC3339DateFormatter
    let dateStr = components[0]
    guard let date = dateFormatter.date(from: components[0]) else {
      return .failure(ParseError(error: "invalid date format: \(dateStr)"))
    }
    
    let rateStr = components[4]
    guard let rate = Double(rateStr) else {
      return .failure(ParseError(error: "invalid rate format: \(rateStr)"))
    }
    
    let backwardRateStr = components[5]
    guard let backwardRate = Double(backwardRateStr) else {
      return .failure(ParseError(error: "invalid backwardRate format: \(backwardRateStr)"))
    }
    
    let result = UpdateRatesInfo(
      updateTime: date,
      exchange: components[1],
      sourceCurrency: components[2],
      destinationCurrency: components[3],
      rate: rate,
      backwardRate: backwardRate)
    
    return .success(.updateRates(result))
  }
  
  public static func parse(line: String) -> Result<Command, ParseError> {
    
    let components = line.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
    
    let cmdComponents = components.map { $0.uppercased() }
    
    let result = parseExchangeRateRequest(components: cmdComponents)
      .flatMapError { _ in parseUpdateRates(components: cmdComponents) }
    
    return result
  }
}
