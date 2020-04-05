//
//  Fonts.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

public enum Fonts {}

extension Fonts {
  private static let medium: UIFont! = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.labelFontSize)

  public static let regular = UIFontMetrics(forTextStyle: .body).scaledFont(for: Fonts.medium)
  public static let tiny = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: Fonts.medium)
}
