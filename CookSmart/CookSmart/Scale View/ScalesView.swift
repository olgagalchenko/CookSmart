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
    let scaleView = ScalesView(ingredient: ingredient, unitConversionFactor: 125, syncScales: false)
    scaleView.unitConversionFactor = 3
    view.addSubview(scaleView)
    scaleView.constrainToSuperview()
  }
}

class ScalesView: UIView {

  var ingredient: CSIngredient {
    didSet {
      updateScaleDensity()
    }
  }

  var unitConversionFactor: CGFloat {
    didSet {
      updateScaleDensity()
    }
  }

  private let syncScales: Bool

  init(ingredient: CSIngredient,
       unitConversionFactor: CGFloat,
       syncScales: Bool = true) {
    self.ingredient = ingredient
    self.unitConversionFactor = unitConversionFactor
    self.syncScales = syncScales
    super.init(frame: .zero)
    setupViews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let volumeScrollView = ScaleScrollView()
  private let weightScrollView = ScaleScrollView(mirror: true)

  private var cancellable: AnyCancellable?
  private var cancellable2: AnyCancellable?

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

    updateScaleDensity()
    setupSync()
  }

  private func setupSync() {
    cancellable = volumeScrollView.$unitValue
      .filter { _ in self.syncScales }
      .sink { volumeValue in
        self.weightScrollView.updateCenterValue(volumeValue * self.unitConversionFactor)
      }

    cancellable2 = weightScrollView.$unitValue
      .filter { _ in self.syncScales }
      .sink { weightValue in
        self.volumeScrollView.updateCenterValue(weightValue / self.unitConversionFactor)
      }
  }
}

extension ScalesView {
  private func updateScaleDensity() {
    var volumeScale: CGFloat = 1

    let idealWeightScale = unitConversionFactor
    var humanReadableWeightScale: CGFloat = 1
    if idealWeightScale >= 10 {
      let orderOfMagnitue = floor(log10(idealWeightScale))
      humanReadableWeightScale = idealWeightScale - idealWeightScale.truncatingRemainder(dividingBy: pow(10, orderOfMagnitue))
    } else {
      let idealVolumeScale = humanReadableWeightScale / idealWeightScale
      if idealVolumeScale >= 10 {
        let orderOfMagnitue = floor(log10(idealVolumeScale))
        volumeScale = idealVolumeScale - idealVolumeScale.truncatingRemainder(dividingBy: pow(10, orderOfMagnitue))
      }
    }

    volumeScrollView.unitsPerTile = Int(volumeScale)
    weightScrollView.unitsPerTile = Int(humanReadableWeightScale)
    weightScrollView.updateCenterValue(volumeScrollView.unitValue * unitConversionFactor)
  }
}
