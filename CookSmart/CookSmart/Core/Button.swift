//
//  Button.swift
//  cake
//
//  Created by Olga Galchenko on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

final class Button: UIButton, StyledView {
  init(style: ButtonStyle = .standard) {
    super.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false
    applyStyle(style)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyStyle(_ style: ButtonStyle) {
    setTitleColor(style.titleColor, for: .normal)
    titleLabel?.font = style.font
  }
}

struct ButtonStyle {
  var titleColor: UIColor = Color.redLineColor
  var font: UIFont = AvenirFont.regular.of(size: 17)

  static var standard: ButtonStyle {
    ButtonStyle()
  }
}
