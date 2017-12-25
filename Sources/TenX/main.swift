//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import Foundation
import CleanroomLogger

private let appLogic = AppLogic(strategy: .unstrict)

let logFileConfiguration = RotatingLogFileConfiguration(
  minimumSeverity: .verbose,
  daysToKeep: 7,
  directoryPath: "TenXLogs/")

try? logFileConfiguration.createLogDirectory()

private let logConfigurations = [
  XcodeLogConfiguration(debugMode: true),
  logFileConfiguration
]

Log.enable(configuration: logConfigurations)

private var currentLine: String?
repeat {
  currentLine = readLine()//readTestLine()
  if let line = currentLine {
    let cmd = CommandsParser.parse(line: line)
    switch cmd {
    case .success(let cmd):
      switch cmd {
      case .updateRates(let updateRatesInfo):
        let result = appLogic.update(rateInfo: updateRatesInfo.toRateInfo)
        switch result {
        case .success:
          break//do nothing
        case .failure(let error):
          error.logError()
        }
      case .exchangeRateRequest(let exchangeRateRequestInfo):
        let result = appLogic.getRateInfo(
          sourceCurrency: exchangeRateRequestInfo.sourceCurrency,
          sourceExchange: exchangeRateRequestInfo.sourceExchange,
          destinationCurrency: exchangeRateRequestInfo.destinationCurrency,
          destinationExchange: exchangeRateRequestInfo.destinationExchange)
        
        switch result {
        case .success(let info):
          print(info.toResultString)
        case .failure(let error):
          error.logError(exchangeRateRequestInfo: exchangeRateRequestInfo)
        }
      }
    case .failure(let error):
      Log.error?.message("parse command line: \(error.error)")
    }
  }
} while currentLine != nil
