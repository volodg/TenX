//
//  StructsDescriptions.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 25/12/17.
//

import RatesTable

extension Currency: CustomStringConvertible {
  public var description: String {
    return "Currency: \(rawValue)"
  }
}

extension Exchange: CustomStringConvertible {
  public var description: String {
    return "Exchange: \(rawValue)"
  }
}
