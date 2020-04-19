//
//  ScalesView.swift
//  cake
//
//  Created by Alex King on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation

extension CSConversionVC {
  @objc
  func addNewScaleView(ingredient: CSIngredient) {
//    let scaleView = ScalesView(ingredient: ingredient)
//    view.addSubview(scaleView)
//    scaleView.constrainToSuperview()
  }
}

class ScalesView: UIView {

  var ingredient: CSIngredient
  private var density: CGFloat = 125

  var syncScales = true

  init(ingredient: CSIngredient) {
    self.ingredient = ingredient
    super.init(frame: .zero)
    setupViews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let volumeScrollView = ScaleScrollView()
  private let weightScrollView = ScaleScrollView(unitsPerTile: 100, mirror: true)

  private var cancellable: AnyCancellable?

  private func setupViews() {
    weightScrollView.translatesAutoresizingMaskIntoConstraints = false

    translatesAutoresizingMaskIntoConstraints = false
    addSubview(volumeScrollView)
    volumeScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    volumeScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    volumeScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    addSubview(weightScrollView)
    weightScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    weightScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    weightScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    volumeScrollView.trailingAnchor.constraint(equalTo: centerXAnchor).isActive = true
    weightScrollView.leadingAnchor.constraint(equalTo: centerXAnchor).isActive = true

    setupSync()
  }

  private func setupSync() {
    cancellable = volumeScrollView.$unitValue
      .filter { _ in self.syncScales }
      .sink { volumeValue in
        self.weightScrollView.updateCenterValue(volumeValue * self.density)
      }
  }
}

extension ScalesView {}
