//
//  Fonts.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import SwiftUI
import UIKit

public enum AvenirFont: String {
  case condensedMedium = "AvenirNextCondensed-Medium"
  case regular = "AvenirNext-Regular"
  case medium = "AvenirNext-Medium"

  public func of(size: CGFloat) -> UIFont {
    UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
  }
}

struct CustomFont: ViewModifier {
  var weight: AvenirFont
  var size: CGFloat

  func body(content: Content) -> some View {
    content.font(.custom(weight.rawValue, size: size))
  }
}

extension View {
  func font(weight: AvenirFont, size: CGFloat) -> some View {
    modifier(CustomFont(weight: weight, size: size))
  }
}
