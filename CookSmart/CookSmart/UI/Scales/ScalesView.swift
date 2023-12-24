//
//  ScalesView.swift
//  cake
//
//  Created by Alex King on 4/18/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine

class ScalesView: UIView {

  enum Mode {
    case sync
    case edit
  }

  private var unitConversionFactor: CGFloat = 1

  let stableUnitConversionFactorPublisher: AnyPublisher<Float, Never>

  private let mode: Mode

  init(unitConversionFactor: CGFloat,
       syncScales: Bool = true) {
    mode = syncScales ? .sync : .edit
    stableUnitConversionFactorPublisher = Publishers.CombineLatest(
      volumeScrollView.stableUnitValuePublisher,
      weightScrollView.stableUnitValuePublisher
    )
    .map { volumeUnitValue, weightUnitValue in weightUnitValue / volumeUnitValue }
    .eraseToAnyPublisher()

    super.init(frame: .zero)

    clearsContextBeforeDrawing = true
    self.unitConversionFactor = unitConversionFactor
    contentMode = .scaleToFill
    autoresizesSubviews = true
    translatesAutoresizingMaskIntoConstraints = false
    insetsLayoutMarginsFromSafeArea = false

    setupViews()
    syncScaleViews(fixedDimension: .Volume(1))
    setUpSubscribers()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  func update(conversionFactor: CGFloat, fixing dimension: ConstantDimension) {
    unitConversionFactor = conversionFactor
    syncScaleViews(fixedDimension: dimension)
  }

  private let volumeScrollView = ScaleScrollView()
  private let weightScrollView = ScaleScrollView(unitsPerTile: 100, mirror: true)
  private let volumeLabel = UILabel(style: .coreContent)
  private let weightLabel = UILabel(style: .coreContent)
  private let volumeCenterLine = CenterLineView()
  private let weightCenterLine = CenterLineView()

  private var subscriptions: [AnyCancellable] = []

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
    volumeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    volumeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    addSubview(weightLabel)
    weightLabel.constrain(to: weightScrollView, anchors: [.centerX, .centerY])
    weightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    weightLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    addSubview(volumeCenterLine)
    volumeCenterLine.constrain(to: volumeScrollView, anchors: [.centerY, .leading, .trailing])
    addSubview(weightCenterLine)
    weightCenterLine.constrain(to: weightScrollView, anchors: [.centerY, .leading, .trailing])
  }

  private func setUpSubscribers() {
    switch mode {
    case .edit:
      subscriptions.append(
        Publishers.CombineLatest(volumeScrollView.$unitValue, weightScrollView.$unitValue)
          .sink {
            self.unitConversionFactor = $0.1 / $0.0
          }
      )
    case .sync:
      subscriptions.append(
        volumeScrollView.$unitValue
          .filter { _ in self.mode == .sync }
          .sink { volumeValue in
            self.weightScrollView.syncTo(unitValue: volumeValue * self.unitConversionFactor)
          }
      )

      subscriptions.append(
        weightScrollView.$unitValue
          .filter { _ in self.mode == .sync }
          .sink { weightValue in
            self.volumeScrollView.syncTo(unitValue: weightValue / self.unitConversionFactor)
          }
      )
    }

    subscriptions.append(contentsOf: [
      volumeScrollView.$unitValue
        .sink { self.volumeLabel.text = Double($0).humanReabableString },
      weightScrollView.$unitValue
        .sink { self.weightLabel.text = Double($0).humanReabableString },
    ])
  }

  private func syncScaleViews(fixedDimension: ConstantDimension) {
    var volumeScale: CGFloat = 1

    let idealWeightScale = unitConversionFactor
    var weightScale: CGFloat = 1
    if idealWeightScale >= 10 {
      let orderOfMagnitude = floor(log10(idealWeightScale))
      weightScale = idealWeightScale - idealWeightScale.truncatingRemainder(dividingBy: pow(10, orderOfMagnitude))
    } else {
      let idealVolumeScale = 1 / unitConversionFactor
      if idealVolumeScale >= 10 {
        let orderOfMagnitude = floor(log10(idealVolumeScale))
        volumeScale = idealVolumeScale - idealVolumeScale.truncatingRemainder(dividingBy: pow(10, orderOfMagnitude))
      }
    }

    let scaleValueSpecs: [(ScaleScrollView, CGFloat)]
    switch fixedDimension {
    case let .Weight(constantUnits: constantWeight):
      scaleValueSpecs = [
        (weightScrollView, constantWeight.map { CGFloat($0) } ?? weightScrollView.unitValue),
        (volumeScrollView, (
          constantWeight.map { CGFloat($0) } ?? weightScrollView.unitValue
        ) / unitConversionFactor),
      ]
    case let .Volume(constantUnits: constantVolume):
      scaleValueSpecs = [
        (volumeScrollView, constantVolume.map { CGFloat($0) } ?? volumeScrollView.unitValue),
        (weightScrollView, (
          constantVolume.map { CGFloat($0) } ?? volumeScrollView.unitValue
        ) * unitConversionFactor),
      ]
    }

    volumeScrollView.unitsPerTile = Int(volumeScale)
    weightScrollView.unitsPerTile = Int(weightScale)

    DispatchQueue.main.async {
      scaleValueSpecs.forEach { scaleScrollView, unitValue in
        scaleScrollView.syncTo(unitValue: unitValue)
      }
    }
  }
}

enum ConstantDimension {
  case Weight(_ constantUnits: Float? = nil)
  case Volume(_ constantUnits: Float? = nil)
}
