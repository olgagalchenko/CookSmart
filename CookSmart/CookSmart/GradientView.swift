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
    backgroundColor = .clear
    // Redraw on bounds changes so the gradient always spans the view. Drawing in
    // `draw(_:)` also means UIKit resolves the dynamic colors against the current
    // trait collection for us, so light/dark changes need no trait observation.
    contentMode = .redraw
    translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext(),
          let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors.map(\.cgColor) as CFArray,
                                    locations: nil)
    else {
      return
    }

    context.drawLinearGradient(
      gradient,
      start: CGPoint(x: bounds.midX, y: bounds.minY + (bounds.height * Constants.startY)),
      end: CGPoint(x: bounds.midX, y: bounds.maxY),
      options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )
  }

  // MARK: Private

  private enum Constants {
    /// Fraction of the view's height at which the gradient begins.
    static let startY: CGFloat = 0.1
  }

  private let colors: [UIColor]
}
