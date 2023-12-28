//
//  ScaleViewController.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UIKit

class ScaleViewController: UIViewController {

  static let glassHeight: CGFloat = 40

  private enum DisplayMode {
    case scales
    case unitPicker
  }

  init(density: Density,
       volumeUnit: CSUnit = CSUnitCollection.volumeUnits()?.unit(at: 2) ?? CSUnit(),
       weightUnit: CSUnit = CSUnitCollection.weightUnits()?.unit(at: 2) ?? CSUnit(),
       shouldSyncScales: Bool = true) {
    scalesView = ScalesView(
      unitConversionFactor: CGFloat(density.in(weightUnit, per: volumeUnit)),
      syncScales: shouldSyncScales
    )
    unitPickerView = UnitPickerView(volumeUnit: volumeUnit, weightUnit: weightUnit)
    self.volumeUnit = volumeUnit
    self.weightUnit = weightUnit

    currentDensity = density

    super.init(nibName: nil, bundle: nil)

    volumeUnitButton.setTitle(volumeUnit.name, for: .normal)
    weightUnitButton.setTitle(weightUnit.name, for: .normal)

    stableUnitConversionFactorRx = scalesView.stableUnitConversionFactorPublisher.sink {
      self.currentDensity = Density($0, in: self.weightUnit, per: self.volumeUnit)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpViews()
  }

  // MARK: Public

  @Published public var currentDensity: Density

  // MARK: Private

  private var stableUnitConversionFactorRx: AnyCancellable?

  private var volumeUnit: CSUnit {
    willSet {
      if !newValue.isEqual(volumeUnit) {
        scalesView.update(
          conversionFactor: CGFloat(currentDensity.in(weightUnit, per: newValue)),
          fixing: .Weight()
        )
        volumeUnitButton.setTitle(newValue.name, for: .normal)
      }
    }
  }

  private var weightUnit: CSUnit {
    willSet {
      if !newValue.isEqual(weightUnit) {
        scalesView.update(
          conversionFactor: CGFloat(currentDensity.in(newValue, per: volumeUnit)),
          fixing: .Volume()
        )
        weightUnitButton.setTitle(newValue.name, for: .normal)
      }
    }
  }

  private var displayMode: DisplayMode = .scales

  private lazy var volumeUnitButton: UIButton = {
    let button = UIButton(style: .plainButton)
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Volume", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private lazy var weightUnitButton: UIButton = {
    let button = UIButton(style: .plainButton)
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Weight", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private let scalesView: ScalesView
  private let unitPickerView: UnitPickerView

  private var scalesTopConstraint: NSLayoutConstraint?
  private var unitPickerBottomConstraint: NSLayoutConstraint?

  private func setUpViews() {
    view.clipsToBounds = true
    unitPickerView.delegate = self

    let magnifiedContainer = UIView()
    magnifiedContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(magnifiedContainer)
    magnifiedContainer.constrainToSuperview()

    setUpScaleViews(container: magnifiedContainer)
    setUpUnitViews(container: magnifiedContainer)
    setUpGlassView(viewToMagnify: magnifiedContainer)
  }

  private func setUpGlassView(viewToMagnify: UIView) {
    let glassView = CSGlassView(magnifiedView: viewToMagnify)!
    view.addSubview(glassView)
    glassView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    glassView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    glassView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    glassView.heightAnchor.constraint(equalToConstant: ScaleViewController.glassHeight).isActive = true
  }

  private func setUpUnitViews(container: UIView) {
    let gradientView = GradientView()
    container.addSubview(gradientView)
    gradientView.constrainToSuperview(anchors: [.leading, .top, .right])
    gradientView.heightAnchor.constraint(equalToConstant: 100).isActive = true

    gradientView.addSubview(volumeUnitButton)
    volumeUnitButton.constrainToSuperview(anchors: [.leading, .top])

    gradientView.addSubview(weightUnitButton)
    weightUnitButton.constrainToSuperview(anchors: [.trailing, .top])

    volumeUnitButton.trailingAnchor.constraint(equalTo: weightUnitButton.leadingAnchor).isActive = true
    volumeUnitButton.widthAnchor.constraint(equalTo: weightUnitButton.widthAnchor).isActive = true
  }

  private func setUpScaleViews(container: UIView) {
    container.addSubview(scalesView)
    scalesView.constrainToSuperview(anchors: [.leading, .trailing, .height])
    scalesTopConstraint = scalesView.topAnchor.constraint(equalTo: view.topAnchor)
    scalesTopConstraint?.isActive = true

    container.addSubview(unitPickerView)
    unitPickerView.constrainToSuperview(anchors: [.leading, .trailing, .height])
    unitPickerBottomConstraint = unitPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    unitPickerView.topAnchor.constraint(equalTo: scalesView.bottomAnchor).isActive = true
  }

  @objc
  private func toggleDisplayMode() {
    guard let scalesTopConstraint = scalesTopConstraint,
          let unitPickerBottomConstraint = unitPickerBottomConstraint
    else {
      return
    }
    displayMode = (displayMode == .scales) ? .unitPicker : .scales
    UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      scalesTopConstraint.isActive = self.displayMode == .scales
      unitPickerBottomConstraint.isActive = self.displayMode == .unitPicker
      self.view.layoutIfNeeded()
    }.startAnimation()

    let textAnimations = UIViewPropertyAnimator(duration: 0.15, curve: .linear) {
      self.weightUnitButton.alpha = 0
      self.volumeUnitButton.alpha = 0
    }
    textAnimations.addCompletion { _ in
      self.weightUnitButton.isEnabled = self.displayMode == .scales
      self.volumeUnitButton.isEnabled = self.displayMode == .scales
      UIViewPropertyAnimator(duration: 0.15, curve: .linear) {
        self.weightUnitButton.alpha = 1
        self.volumeUnitButton.alpha = 1
      }.startAnimation()
    }
    textAnimations.startAnimation()
  }
}

extension ScaleViewController: UnitPickerDelegate {
  func picked(volumeUnit: CSUnit, weightUnit: CSUnit) {
    self.volumeUnit = volumeUnit
    self.weightUnit = weightUnit
    toggleDisplayMode()
  }
}
