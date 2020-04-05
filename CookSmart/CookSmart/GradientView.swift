//
//  GradientView.swift
//  cake
//
//  Created by Alex King on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

class GradientView: UIView {
  private let gradientLayer: CAGradientLayer

  init(startColor: UIColor = .clear, endColor: UIColor = .clear) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    self.gradientLayer = gradientLayer

    super.init(frame: .zero)

    isOpaque = false
    translatesAutoresizingMaskIntoConstraints = false
    addGradientLayer()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var bounds: CGRect {
    didSet {
      if bounds != oldValue {
        gradientLayer.frame = bounds
      }
    }
  }

  private func addGradientLayer() {
    layer.addSublayer(gradientLayer)
    gradientLayer.frame = bounds
  }
}
