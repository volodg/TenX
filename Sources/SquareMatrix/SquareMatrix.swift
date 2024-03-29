//
//  SquareMatrix.swift
//  SquareMatrix
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

public final class SquareMatrix<Element> {
  //use one dimension array to reduce anount of allocations
  private var values = [Element]()
  private var edgeSize = 0
  private let defValue: Element
  
  public init(defValue: Element) {
    self.defValue = defValue
  }
  
  public func copy() -> SquareMatrix<Element> {
    let result = SquareMatrix<Element>(defValue: defValue)
    result.values = values
    result.edgeSize = edgeSize
    return result
  }
  
  public subscript(index: (x: Int, y: Int)) -> Element {
    set {
      values[index.y * edgeSize + index.x] = newValue
    }
    get {
      return values[index.y * edgeSize + index.x]
    }
  }
  
  private func reinit(toIndex: Int) {
    for i in 0..<toIndex {
      values[i] = defValue
    }
  }
  
  public func reallocate(newEdgeSize: Int, reinit: Bool = true) {
    
    func reinitIfNeeded() {
      if reinit {
        self.reinit(toIndex: values.count)
      }
    }
    
    if edgeSize == newEdgeSize {
      reinitIfNeeded()
      return
    }
    
    if edgeSize > newEdgeSize {
      let shrinkOnSize = values.count * values.count - newEdgeSize * newEdgeSize
      edgeSize = newEdgeSize
      values.removeLast(shrinkOnSize)
      reinitIfNeeded()
      return
    }
    
    reinitIfNeeded()
    
    let newSize = newEdgeSize * newEdgeSize
    values.reserveCapacity(newSize)
    
    let additionalSize = newSize - values.count
    
    for _ in 0..<additionalSize {
      values.append(defValue)
    }
    
    edgeSize = newEdgeSize
  }
}
