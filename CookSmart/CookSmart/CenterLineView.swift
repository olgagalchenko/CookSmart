//
//  CenterLineView.swift
//  cake
//
//  Created by Alex King on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

class CenterLineView: UIView {
  private enum Constants {
    static let lineHeight: CGFloat = 2.0
    static let unitLabelWidth: CGFloat = 110
  }

  init() {
    super.init(frame: .zero)
    setupViews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalToConstant: Constants.lineHeight).isActive = true

    let leftLine = UIView()
    addSubview(leftLine)
    leftLine.translatesAutoresizingMaskIntoConstraints = false
    leftLine.backgroundColor = Color.redLineColor
    leftLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    leftLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
    leftLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    leftLine.trailingAnchor.constraint(equalTo: centerXAnchor,
                                       constant: -(Constants.unitLabelWidth / 2)).isActive = true

    let rightLine = UIView()
    addSubview(rightLine)
    rightLine.translatesAutoresizingMaskIntoConstraints = false
    rightLine.backgroundColor = Color.redLineColor
    rightLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    rightLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
    rightLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    rightLine.leadingAnchor.constraint(equalTo: centerXAnchor,
                                       constant: Constants.unitLabelWidth / 2).isActive = true
  }
}
