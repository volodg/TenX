//
//  Array+RemoveCycles.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 26/12/17.
//

extension Array where Element: Equatable {
  func removeCycles() -> [Element] {
    guard !isEmpty else { return self }
    for i in 0..<(count - 1) {
      for j in (i + 1)..<count {
        let jj = i + count - j
        if self[i] == self[jj] {
          return Array(self[0...i]) + Array(self[(jj + 1)..<count]).removeCycles()
        }
      }
    }
    return self
  }
}
