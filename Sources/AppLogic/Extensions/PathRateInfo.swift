//
//  PathRateInfo.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

extension AppLogic.PathRateInfo {
  
  public var toResultString: String {
    
    var result = [String]()
    var firstLineComponents = [String]()
    firstLineComponents.append("BEST_RATES_BEGIN")
    firstLineComponents.append(pair.source.exchange.rawValue)
    firstLineComponents.append(pair.source.currency.rawValue)
    firstLineComponents.append(pair.destination.exchange.rawValue)
    firstLineComponents.append(pair.destination.currency.rawValue)
    firstLineComponents.append("\(rate)")
    result.append(firstLineComponents.joined(separator: " "))
    
    for vertex in path {
      var vertexComponents = [String]()
      vertexComponents.append(vertex.exchange.rawValue)
      vertexComponents.append(vertex.currency.rawValue)
      result.append(vertexComponents.joined(separator: " "))
    }
    
    result.append("BEST_RATES_END")
    
    return result.joined(separator: "\n")
  }
}
