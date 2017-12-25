//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

import Parser
import CleanroomLogger

//TODO implement other stategies

private let appLogic = AppLogic()

private let logConfigurations = [
  XcodeLogConfiguration(debugMode: true),
  RotatingLogFileConfiguration(minimumSeverity: .info,
                               daysToKeep: 7,
                               directoryPath: "./")
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
