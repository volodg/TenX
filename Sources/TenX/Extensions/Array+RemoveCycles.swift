//
//  Array+RemoveCycles.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

extension Array where Element: Equatable {
  func removeCycles() -> [Element] {
    for i in 0..<(count - 1) {
      for j in (i + 1)..<count {
        if self[i] == self[j] {
          return Array(self[0...i]) + Array(self[(j + 1)..<count]).removeCycles()
        }
      }
    }
    return self
  }
}
