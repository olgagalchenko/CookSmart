//
//  Fonts.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

public enum Fonts {
  case condensedMedium
  case regular
  case medium

  private var name: String {
    switch self {
    case .condensedMedium: return "AvenirNextCondensed-Medium"
    case .regular: return "AvenirNext-Regular"
    case .medium: return "AvenirNext-Medium"
    }
  }

  public func of(size: CGFloat) -> UIFont? {
    return UIFont(name: name, size: size)
  }
}
