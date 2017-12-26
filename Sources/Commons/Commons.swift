//
//  Commons.swift
//  Commons
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

public protocol Semigroup {
  // Binary semigroup operation
  // **AXIOM** Should be associative:
  //   a.op(b.op(c)) == (a.op(b)).op(c)
  func op(_ g: Self) -> Self
}

public protocol Monoid: Semigroup {
  // Identity value of monoid
  // **AXIOM** Should satisfy:
  //   Self.e() <> a == a <> Self.e() == a
  // for all values a
  static func e() -> Self
}

public protocol Group: Monoid {
  // Inverse value of group
  // **AXIOM** Should satisfy:
  //   a <> a.inv() == a.inv() <> a == Self.e()
  // for each value a.
  func inv() -> Self
}

public protocol Ordered {
  static func maximum() -> Self
  // anyVal.less(Ordered.maximum()) == true
  func less(_ than: Self) -> Bool
}

extension Ordered {
  
  public var isMaximum: Bool {
    let result = !less(Self.maximum()) && !Self.maximum().less(self)
    return result
  }
}
