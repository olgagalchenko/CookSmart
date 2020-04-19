//
//  StyledView.swift
//  cake
//
//  Created by Olga Galchenko on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

protocol StyledView: AnyObject {
  associatedtype Style

  init(style: Style)
}

extension StyledView {
  public static func make(style: Self.Style) -> Self {
    Self(style: style)
  }
}
