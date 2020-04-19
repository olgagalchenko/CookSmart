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
  private let gradientLayer: CAGradientLayer

  init(topColor: UIColor = Color.background, bottomColor: UIColor = Color.background.withAlphaComponent(0)) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.1)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
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
