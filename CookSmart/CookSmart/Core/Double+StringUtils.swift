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

  private var decimalFraction: Fraction {
    guard self < fractionThreshold else { return .zero }
    return Fraction(value: decimal)
  }

  var roundedValue: Double {
    Double(roundedWhole) + decimalFraction.rawValue
  }

  var vulgarFractionString: String {
    let rounded = roundedValue
    let whole = rounded.whole
    let fraction = rounded.decimalFraction

    if whole == 0, fraction != .zero {
      return fraction.string
    }
    return String(whole) + fraction.string
  }
}
