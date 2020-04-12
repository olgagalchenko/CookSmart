//
//  Double+StringUtils.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

extension Double {
  var wholeValue: Double {
    guard self < 50.0 else {
      return rounded(FloatingPointRoundingRule.toNearestOrEven)
    }

    return modf(self).0
  }

  var decimalFraction: Fraction {
    guard self < 50.0 else { return .zero }
    return Fraction(value: modf(self).1)
  }

  var roundedValue: Double {
    wholeValue + decimalFraction.rawValue
  }

  var vulgarFractionString: String {
    let whole = wholeValue
    let fraction = decimalFraction

    if whole == 0, fraction != .zero {
      return fraction.string
    }

    return String(format: "%.0f", whole) + fraction.string
  }
}

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
