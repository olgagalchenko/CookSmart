//
//  CakeColor.swift
//  cake
//
//  Created by Vova Galchenko on 12/2/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

import SwiftUI

// TODO: There should be no reference to any color except through this enum

enum CSColor: String {
  case background = "BackgroundColor"
  case accent = "AccentColor"

  func asUIColor() -> UIColor {
    UIColor(named: rawValue)!
  }

  func asSwiftUIColor() -> Color {
    Color(asUIColor())
  }
}
