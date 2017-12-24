// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TenX",
  products: [
    .executable(
      name: "TenX",
      targets: ["TenX"]),
    .library(
      name: "Parser",
      targets: ["Parser"]),
    .library(
      name: "SquareMatrix",
      targets: ["SquareMatrix"]),
    .library(
      name: "ExchangeRateCalculator",
      targets: ["ExchangeRateCalculator"]),
    .library(
      name: "RatesTable",
      targets: ["RatesTable"]),
    .library(
      name: "Commons",
      targets: ["Commons"]),
    ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "TenX",
      dependencies: ["Parser", "ExchangeRateCalculator", "RatesTable", "Commons"]),
    .target(
      name: "Parser",
      dependencies: []),
    .target(
      name: "SquareMatrix",
      dependencies: []),
    .target(
      name: "ExchangeRateCalculator",
      dependencies: ["SquareMatrix", "Commons"]),
    .target(
      name: "RatesTable",
      dependencies: ["Commons"]),
    .target(
      name: "Commons",
      dependencies: []),
    .testTarget(
      name: "TenXTests",
      dependencies: ["Parser"]),
    ]
)

