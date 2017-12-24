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
var next = [[Currency?]]()

extension Array where Element: WithDefaultValue {
  
  static func createSquareMatrix(size: Int, defValue: Element) -> [[Element]] {
    var result = [[Element]](repeating: [], count: size)
    for i in 0..<size {
      result[i] = [Element](repeating: Element.defaultValue, count: size)
    }
    return result
  }
}

//TODO make it template to remove dependence on type
func updateBestRatesTable(exchangesVertex: ExchangesVertex) {
  
  let currenciesCount = exchangesVertex.currenciesCount
  
  rate = [Double].createSquareMatrix(size: currenciesCount, defValue: .infinity)
  next = [Currency?].createSquareMatrix(size: currenciesCount, defValue: nil)
  
  exchangesVertex.forEach { info in
    rate[info.sourceIndex][info.destinationIndex] = info.exchangeInfo.weight
    next[info.sourceIndex][info.destinationIndex] = info.pair.destination
  }
  
  for k in 0..<currenciesCount {
    for i in 0..<currenciesCount {
      for j in 0..<currenciesCount {
        if rate[i][j] < rate[i][k] + rate[k][j] {
          rate[i][j] = rate[i][k] + rate[k][j]
          next[i][j] = next[i][k]
        }
      }
    }
  }
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

