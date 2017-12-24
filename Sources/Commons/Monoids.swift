//
//  Monoids.swift
//  Commons
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

public protocol Semigroup {
  /* A semigroup is a set and a binary operator defined for elements within that
   set, to yeild a another element of the same type.
   */
  static func combine (_ lhs: Self, _ rhs: Self) -> Self
}

extension Semigroup {
  // Extending a protocol enables to get free functions based on the implementation of the protocol
  public func mappend(_ with: Self) -> Self {
    return Self.combine(self, with)
  }
}

public protocol Monoid : Semigroup { // Protocols can inherit from one another.
  static func unit() -> Self
}

extension Monoid {
  //Implementations for higher ordered types (kind > 1)
  static func mconcat (_ items:[Self]) -> Self {
    let mzero = Self.unit()
    let result = items.reduce(mzero) { (accum, m) -> Self in
      m.mappend(accum)
    }
    return result
  }
  
}

// Implementations
extension Array:Monoid {
  public static func unit() -> [Element] {
    return []
  }
  
  public static func combine(_ lhs: Array, _ rhs: Array) -> Array{
    return lhs + rhs
  }
}

extension Int: Monoid {
  public static func unit() -> Int { return 0 }
  public static func combine(_ lhs: Int,_ rhs:Int) -> Int {
    return lhs + rhs
  }
}

extension String : Monoid {
  public static func unit() -> String {return ""}
  public static func combine(_ lhs: String, _ rhs:String) -> String{
    return lhs + rhs // As you can see swift already has overloaded the + operator
  }
}

/*
 There can be more than one implementation of a protocol for single type.
 Int can be a monoid under multiplication ( *, 1) and sumatiion (+, 0)
 so the solution is to wrap them to make different types.
 */

public enum ProdNum<T : Numeric> : Monoid { //Enums can conform to protocols
  case Prod(T)
  
  public static func unit () ->  ProdNum {
    return .Prod(1)
  }
  
  public static func combine(_ lhs: ProdNum, _ rhs:ProdNum) -> ProdNum{
    switch  (lhs, rhs) {
    case (.Prod(let v), .Prod(let v2)):
      return .Prod(v * v2)
    }
  }
}

public enum SumNum<T : Numeric> : Monoid { //Enums can conform to protocols
  case Sum(T)
  
  public static func unit () -> SumNum {
    return .Sum(0)
  }
  
  public static func combine(_ lhs: SumNum, _ rhs:SumNum) -> SumNum{
    switch  (lhs, rhs) {
    case (.Sum(let v), .Sum(let v2)):
      return .Sum(v + v2)
    }
  }
}
