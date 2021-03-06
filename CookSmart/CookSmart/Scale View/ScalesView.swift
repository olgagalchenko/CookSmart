//
//  ScalesView.swift
//  cake
//
//  Created by Alex King on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation

class ScalesView: UIView {

  enum Mode {
    case sync
    case edit
  }

  private(set) var unitConversionFactor: CGFloat {
    didSet {
      guard mode == .sync else { return }
      updateScaleDensity()
    }
  }

  private let mode: Mode

  init(unitConversionFactor: CGFloat,
       syncScales: Bool = true) {
    self.unitConversionFactor = unitConversionFactor
    mode = syncScales ? .sync : .edit
    super.init(frame: .zero)
    setupViews()
    setUpSubscribers()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  func updateConversionFactor(_ conversionFactor: CGFloat) {
    unitConversionFactor = conversionFactor
    updateScaleDensity()
  }

  private let volumeScrollView = ScaleScrollView()
  private let weightScrollView = ScaleScrollView(unitsPerTile: 100, mirror: true)
  private let volumeLabel = Label()
  private let weightLabel = Label()
  private let volumeCenterLine = CenterLineView()
  private let weightCenterLine = CenterLineView()

  private var volumeSubscriber: AnyCancellable?
  private var weightSubscriber: AnyCancellable?
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

    updateScaleDensity()
  }

  private func setUpSubscribers() {
    switch mode {
    case .edit:
      volumeSubscriber = Publishers.CombineLatest(volumeScrollView.$unitValue, weightScrollView.$unitValue)
        .sink(receiveValue: {
          self.unitConversionFactor = $0.1 / $0.0
        })
    case .sync:
      volumeSubscriber = volumeScrollView.$unitValue
        .filter { _ in self.mode == .sync }
        .sink { volumeValue in
          self.weightScrollView.syncToUnitValue(volumeValue * self.unitConversionFactor)
        }

      weightSubscriber = weightScrollView.$unitValue
        .filter { _ in self.mode == .sync }
        .sink { weightValue in
          self.volumeScrollView.syncToUnitValue(weightValue / self.unitConversionFactor)
        }
    }

    volumeLabelSubscriber = volumeScrollView.unitText
      .assign(to: \.text, on: volumeLabel)

    weightLabelSubscriber = weightScrollView.unitText
      .assign(to: \.text, on: weightLabel)
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
      let idealVolumeScale = 1 / unitConversionFactor
      if idealVolumeScale >= 10 {
        let orderOfMagnitue = floor(log10(idealVolumeScale))
        volumeScale = idealVolumeScale - idealVolumeScale.truncatingRemainder(dividingBy: pow(10, orderOfMagnitue))
      }
    }

    volumeScrollView.unitsPerTile = Int(volumeScale)
    weightScrollView.unitsPerTile = Int(humanReadableWeightScale)
    weightScrollView.syncToUnitValue(volumeScrollView.unitValue * unitConversionFactor)
  }
}
