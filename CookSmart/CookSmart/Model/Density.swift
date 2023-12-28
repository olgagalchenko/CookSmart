//
//  Density.swift
//  cake
//
//  Created by Vova Galchenko on 12/1/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

import Foundation

struct Density: Codable, Equatable {
  private let density: Double
  var isValid: Bool {
    !density.isNaN && density.isFinite && !density.isZero
  }

  var analyticsRepresentation: String {
    isValid ? "\(density)" : "invalid"
  }

  // TODO: This should be removed after CSUnit-related models are easy-to-access enums
  var canonical: Double { density }

  // TODO: Once CSUnit-related models are replaced with enums, we should be exlusively using the other initializer
  init(inGramsPerCup canonicalDensity: Double) {
    density = canonicalDensity
  }

  init(_ magnitude: Float, in weightUnit: CSUnit, per volumeUnit: CSUnit) {
    density = Double(magnitude * (volumeUnit.conversionFactor / weightUnit.conversionFactor))
  }

  init(from decoder: Decoder) throws {
    let topLevelContainer = try decoder.singleValueContainer()
    density = try topLevelContainer.decode(Double.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(density)
  }

  func `in`(_ weightUnit: CSUnit, per volumeUnit: CSUnit) -> Double {
    density * Double(weightUnit.conversionFactor / volumeUnit.conversionFactor)
  }
}
