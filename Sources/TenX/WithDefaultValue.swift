//
//  WithDefaultValue.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

protocol WithDefaultValue {
  static var defaultValue: Self { get }
}

extension Array: WithDefaultValue {
  static var defaultValue: [Element] {
    return []
  }
}

extension Optional: WithDefaultValue {
  static var defaultValue: Wrapped? {
    return nil
  }
}

extension Int: WithDefaultValue {
  static var defaultValue: Int {
    return 0
  }
}

extension Int64: WithDefaultValue {
  static var defaultValue: Int64 {
    return 0
  }
}

extension Bool: WithDefaultValue {
  static var defaultValue: Bool {
    return false
  }
}

extension String: WithDefaultValue {
  static var defaultValue: String {
    return ""
  }
}
