//
//  BestExchangeRate.swift
//  TenX
//
//  Created by Volodymyr  Gorbenko on 24/12/17.
//

//let rate[][] = a lookup table of edge weights initialized to 0 for each (source_vertex, destination_vertex) pair
//let next[][] = a lookup table of vertices initialized to None for each (source_vertex, destination_vertex) pair
//let V[] = an array containing each vertex

var rate = [[Double]]()
var next = [[FullExchangeInfo?]]()

extension Array where Element: WithDefaultValue {
  
  static func createSquareMatrix(size: Int, defValue: Element) -> [[Element]] {
    var result = [[Element]](repeating: [], count: size)
    for i in 0..<size {
      result[i] = [Element](repeating: Element.defaultValue, count: size)
    }
    return result
  }
}

func pudateBestRatesTable(exchangesVertex: ExchangesVertex) {
  
  rate = [Double].createSquareMatrix(size: exchangesVertex.currenciesCount, defValue: .infinity)
  next = [FullExchangeInfo?].createSquareMatrix(size: exchangesVertex.currenciesCount, defValue: nil)
}

//procedure BestRates()
//for each edge (u,v)
//  rate[u][v] ← w(u,v)  // the weight of the edge (u,v)
//  next[u][v] ← v
//for k from 1 to length(V) // modified Floyd-Warshall implementation
//  for i from 1 to length(V)
//    for j from 1 to length(V)
//      if rate[i][j] < rate[i][k] * rate[k][j] then
//        rate[i][j] ← rate[i][k] * rate[k][j]
//        next[i][j] ← next[i][k]
//
//procedure Path(u, v)
//  if next[u][v] = null then
//    return []
//  path = [u]
//  while u ≠ v
//    u ← next[u][v]
//    path.append(u)
//  return path

