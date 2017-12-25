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
    ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/antitypical/Result.git", from: "3.2.4"),
    .package(url: "https://github.com/emaloney/CleanroomLogger.git", from: "6.0.2"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "TenX",
      dependencies: [
        "Parser",
        "ExchangeRateCalculator",
        "RatesTable",
        "CleanroomLogger"
      ]),
    .target(
      name: "Parser",
      dependencies: ["Result"]),
    .target(
      name: "SquareMatrix",
      dependencies: []),
    .target(
      name: "ExchangeRateCalculator",
      dependencies: ["SquareMatrix"]),
    .target(
      name: "RatesTable",
      dependencies: []),
    .testTarget(
      name: "TenXTests",
      dependencies: ["TenX"]),
    ]
)

