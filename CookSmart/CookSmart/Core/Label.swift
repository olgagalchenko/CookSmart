//
//  Label.swift
//  cake
//
//  Created by Olga Galchenko on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

final class Label: UILabel, StyledView {
  init(style: LabelStyle = .standard) {
    super.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false
    applyStyle(style)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyStyle(_ style: LabelStyle) {
    textColor = style.titleColor
    font = style.font
  }
}

struct LabelStyle {
  var titleColor: UIColor = UIColor.label
  var font: UIFont = AvenirFont.regular.of(size: 17)

  static var standard: LabelStyle {
    LabelStyle()
  }

  static var tiny: LabelStyle {
    var style = standard
    style.font = AvenirFont.condensedMedium.of(size: 12)
    return style
  }
}
