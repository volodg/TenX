//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import CleanroomLogger

private let logConfigurations = [
  XcodeLogConfiguration(debugMode: true),
  RotatingLogFileConfiguration(minimumSeverity: .info,
                               daysToKeep: 7,
                               directoryPath: "./TenXTest.log")
]

Log.enable(configuration: logConfigurations)

private var currentLine: String?
repeat {
  currentLine = readTestLine()//readLine()
  if let line = currentLine {
    let cmd = CommandsParser.parse(line: line)
    switch cmd {
    case .success(let cmd):
      switch cmd {
        case .updateRates(let updateRatesInfo):
          updateRates(rateInfo: updateRatesInfo.toRateInfo)
        case .exchangeRateRequest(let exchangeRateRequestInfo):
          processExchangeRateRequest(
            sourceCurrency: exchangeRateRequestInfo.sourceCurrency,
            sourceExchange: exchangeRateRequestInfo.sourceExchange,
            destinationCurrency: exchangeRateRequestInfo.destinationCurrency,
            destinationExchange: exchangeRateRequestInfo.destinationExchange)
      }
    case .failure(let error):
      Log.error?.message("parse command line: \(error.error)")
    }
  }
} while currentLine != nil
