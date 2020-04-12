//
//  Double+StringUtils.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

extension Double {
  private var whole: Self { modf(self).0 }
  private var decimal: Self { modf(self).1 }

  private var roundedWhole: Double {
    guard self < 50.0 else {
      return rounded(FloatingPointRoundingRule.toNearestOrEven)
    }

    return whole
  }

  private var decimalFraction: Fraction {
    guard self < 50.0 else { return .zero }
    return Fraction(value: decimal)
  }

  var roundedValue: Double {
    roundedWhole + decimalFraction.rawValue
  }

  var vulgarFractionString: String {
    let rounded = roundedValue
    let whole = rounded.whole
    let fraction = rounded.decimalFraction

    if whole == 0, fraction != .zero {
      return fraction.string
    }
    return String(format: "%.0f", whole) + fraction.string
  }
}
