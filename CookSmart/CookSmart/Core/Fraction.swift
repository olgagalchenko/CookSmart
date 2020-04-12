//
//  Fraction.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

enum Fraction: Double, CaseIterable {
  case zero = 0
  case eighth = 0.125
  case quarter = 0.250
  case third = 0.333
  case threeEighths = 0.375
  case half = 0.500
  case fiveEighths = 0.625
  case twoThirds = 0.666
  case threeQuarters = 0.750
  case sevenEighths = 0.875
  case one = 1.0

  init(value: Double) {
    var closestFraction: Fraction = .zero
    var smallestDifference: Double = 1.0

    for fraction in Fraction.allCases {
      let difference = fabs(fraction.rawValue - value)
      if difference < smallestDifference {
        smallestDifference = difference
        closestFraction = fraction
      }
    }

    self = closestFraction
  }

  var string: String {
    switch self {
    case .eighth: return "⅛"
    case .quarter: return "¼"
    case .third: return "⅓"
    case .threeEighths: return "⅜"
    case .half: return "½"
    case .fiveEighths: return "⅝"
    case .twoThirds: return "⅔"
    case .threeQuarters: return "¾"
    case .sevenEighths: return "⅞"
    case .zero, .one: return ""
    }
  }
}
