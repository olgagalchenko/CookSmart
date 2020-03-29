//
//  Colors.swift
//  cake
//
//  Created by Alex King on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

enum Color {
  static let cakeRed = Color.color(
    light: UIColor(red: 187.0 / 255.0, green: 1.0 / 255.0, blue: 3.0 / 255.0, alpha: 1.0),
    dark: UIColor(red: 234.0 / 255.0, green: 110.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
  )

  static let background = Color.color(
    light: UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0),
    dark: UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
  )

  private static func color(light: UIColor, dark: UIColor) -> UIColor {
    UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return dark
      case .light, .unspecified: return light
            @unknown default: return light
      }
    }
  }
}
