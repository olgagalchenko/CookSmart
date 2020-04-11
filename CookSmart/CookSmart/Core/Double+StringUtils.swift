//
//  Double+StringUtils.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

extension Double {
  var humanReadableValue: Double {
    guard self < 50.0 else {
      return rounded(FloatingPointRoundingRule.toNearestOrEven)
    }

    let wholeNumber = floor(self)
    let leftover = self - wholeNumber

    // iterate over special fractions to figure out which is closer

    return self
  }

  var humanReadableString: String {
    String(format: "%.0f", humanReadableValue)
  }
}
