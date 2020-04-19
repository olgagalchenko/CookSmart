//
//  GradientView.swift
//  cake
//
//  Created by Alex King on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

class GradientView: UIView {

  init(topColor: UIColor = Color.background, bottomColor: UIColor = Color.background.withAlphaComponent(0)) {
    colors = [topColor, bottomColor]
    super.init(frame: .zero)

    isOpaque = false
    translatesAutoresizingMaskIntoConstraints = false
    addGradientLayer()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    applyColors(colors)
  }

  override var bounds: CGRect {
    didSet {
      if bounds != oldValue {
        gradientLayer.frame = bounds
      }
    }
  }

  // MARK: Private

  private let gradientLayer = CAGradientLayer()
  private let colors: [UIColor]

  private func addGradientLayer() {
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.1)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    applyColors(colors)

    layer.addSublayer(gradientLayer)
    gradientLayer.frame = bounds
  }

  private func applyColors(_ colors: [UIColor]) {
    let resolvedColors = colors.map { color -> CGColor in
      color.resolvedColor(with: traitCollection).cgColor
    }
    gradientLayer.colors = resolvedColors
  }
}
