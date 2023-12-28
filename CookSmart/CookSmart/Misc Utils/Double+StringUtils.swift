//
//  Double+StringUtils.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

private let fractionThreshold: Double = 50.0

extension Double {
  private var whole: Int { Int(modf(self).0) }
  private var decimal: Self { modf(self).1 }

  private var roundedWhole: Int {
    guard self < fractionThreshold else {
      return Int(rounded(FloatingPointRoundingRule.toNearestOrEven))
    }

    return whole
  }

  private var decimalFraction: HumanReadableFraction {
    guard self < fractionThreshold else { return .zero }
    return HumanReadableFraction(value: decimal)
  }

  var roundedValue: Double {
    Double(roundedWhole) + decimalFraction.rawValue
  }

  var humanReabableString: String {
    let rounded = roundedValue
    let whole = rounded.whole
    let fraction = rounded.decimalFraction

    if whole == 0, fraction != .zero {
      return fraction.string
    }
    return String(whole) + fraction.string
  }
}

private enum HumanReadableFraction: Double, CaseIterable {
  case zero = 0
  case eighth = 0.125
  case quarter = 0.250
  case third = 0.3333333333333333
  case threeEighths = 0.375
  case half = 0.500
  case fiveEighths = 0.625
  case twoThirds = 0.6666666666666666
  case threeQuarters = 0.750
  case sevenEighths = 0.875
  case one = 1.0

  init(value: Double) {
    var closestFraction: HumanReadableFraction = .zero
    var smallestDifference = 1.0

    for fraction in HumanReadableFraction.allCases {
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
