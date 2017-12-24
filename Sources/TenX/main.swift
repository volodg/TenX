import Parser

struct Vertex {
  let source: String
  let destination: String
  let weight: Double
}

let allVertexes: [Vertex] = [
  Vertex(source: "1", destination: "2", weight: 1),
  Vertex(source: "1", destination: "3", weight: 1),
  Vertex(source: "2", destination: "3", weight: 0.5),
  Vertex(source: "3", destination: "2", weight: 0.5),
  Vertex(source: "2", destination: "4", weight: 1),
  Vertex(source: "3", destination: "4", weight: 1),
  Vertex(source: "3", destination: "6", weight: 2),
  Vertex(source: "4", destination: "6", weight: 2),
  Vertex(source: "3", destination: "5", weight: 2),
  Vertex(source: "4", destination: "5", weight: 2),
  Vertex(source: "6", destination: "5", weight: 0.5),
  Vertex(source: "5", destination: "6", weight: 0.5),
  Vertex(source: "6", destination: "7", weight: 2),
  Vertex(source: "5", destination: "7", weight: 0.5),
  Vertex(source: "7", destination: "5", weight: 1),
]

print("Hello World!!!")
