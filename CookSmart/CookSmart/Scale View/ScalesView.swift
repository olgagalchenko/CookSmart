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
    setUpSubscribers()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let volumeScrollView = ScaleScrollView()
  private let weightScrollView = ScaleScrollView(unitsPerTile: 100, mirror: true)
  private let volumeLabel = Label()
  private let weightLabel = Label()
  private let volumeCenterLine = CenterLineView()
  private let weightCenterLine = CenterLineView()

  private var volumeSubscriber: AnyCancellable?
  private var volumeLabelSubscriber: AnyCancellable?
  private var weightLabelSubscriber: AnyCancellable?

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

    addSubview(volumeLabel)
    volumeLabel.constrain(to: volumeScrollView, anchors: [.centerX, .centerY])

    addSubview(weightLabel)
    weightLabel.constrain(to: weightScrollView, anchors: [.centerX, .centerY])

    addSubview(volumeCenterLine)
    volumeCenterLine.constrain(to: volumeScrollView, anchors: [.centerY, .leading, .trailing])
    addSubview(weightCenterLine)
    weightCenterLine.constrain(to: weightScrollView, anchors: [.centerY, .leading, .trailing])
  }

  private func setUpSubscribers() {
    volumeSubscriber = volumeScrollView.$unitValue
      .filter { _ in self.syncScales }
      .sink { volumeValue in
        self.weightScrollView.updateCenterValue(volumeValue * self.density)
      }

    volumeLabelSubscriber = volumeScrollView.$unitValue
      .map { scaleValue -> String in
        Double(scaleValue).vulgarFractionString
      }
      .assign(to: \.text, on: volumeLabel)

    weightLabelSubscriber = weightScrollView.$unitValue
      .map { scaleValue -> String in
        Double(scaleValue).vulgarFractionString
      }
      .assign(to: \.text, on: weightLabel)
  }
}

extension ScalesView {}
