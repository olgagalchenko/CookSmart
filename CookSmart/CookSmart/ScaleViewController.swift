//
//  ScaleViewController.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class ScaleViewController: UIViewController {

  private enum DisplayMode {
    case scales
    case unitPicker
  }

  init(ingredient: CSIngredient, shouldSyncScales: Bool = true) {
    self.ingredient = ingredient
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpViews()
    setContent()
  }

  // MARK: Public

  var ingredient: CSIngredient
  var currentVolumeUnit: CSUnit = CSUnitCollection.volumeUnits()?.unit(at: 2) ?? CSUnit()
  var currentWeightUnit: CSUnit = CSUnitCollection.weightUnits()?.unit(at: 2) ?? CSUnit()

  // MARK: Private

  private var displayMode: DisplayMode = .scales

  private let volumeUnitButton: Button = {
    let button = Button()
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Volume", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private let weightUnitButton: Button = {
    let button = Button()
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Weight", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private lazy var scalesContainer = ScalesView(unitConversionFactor: unitConversionFactor,
                                                syncScales: true)
  private lazy var unitPickerView = UnitPickerView(volumeUnit: currentVolumeUnit, weightUnit: currentWeightUnit)

  private var scalesTopConstraint: NSLayoutConstraint?
  private var unitPickerBottomConstraint: NSLayoutConstraint?

  private var unitConversionFactor: CGFloat {
    CGFloat(ingredient.density(withVolumeUnit: currentVolumeUnit, andWeightUnit: currentWeightUnit))
  }

  private func setUpViews() {
    view.clipsToBounds = true
    unitPickerView.delegate = self

    setUpScaleViews()
    setUpUnitViews()
  }

  private func setUpUnitViews() {
    let gradientView = GradientView()
    view.addSubview(gradientView)
    gradientView.constrainToSuperview(anchors: [.leading, .top, .right])
    gradientView.heightAnchor.constraint(equalToConstant: 100).isActive = true

    gradientView.addSubview(volumeUnitButton)
    volumeUnitButton.constrainToSuperview(anchors: [.leading, .top])

    gradientView.addSubview(weightUnitButton)
    weightUnitButton.constrainToSuperview(anchors: [.trailing, .top])

    volumeUnitButton.trailingAnchor.constraint(equalTo: weightUnitButton.leadingAnchor).isActive = true
    volumeUnitButton.widthAnchor.constraint(equalTo: weightUnitButton.widthAnchor).isActive = true
  }

  private func setUpScaleViews() {
    view.addSubview(scalesContainer)
    scalesContainer.constrainToSuperview(anchors: [.leading, .trailing, .height])
    scalesTopConstraint = scalesContainer.topAnchor.constraint(equalTo: view.topAnchor)
    scalesTopConstraint?.isActive = true

    view.addSubview(unitPickerView)
    unitPickerView.constrainToSuperview(anchors: [.leading, .trailing, .height])
    unitPickerBottomConstraint = unitPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    unitPickerView.topAnchor.constraint(equalTo: scalesContainer.bottomAnchor).isActive = true
  }

  private func setContent() {
    volumeUnitButton.setTitle(currentVolumeUnit.name, for: .normal)
    weightUnitButton.setTitle(currentWeightUnit.name, for: .normal)
  }

  @objc
  private func toggleDisplayMode() {
    guard let scalesTopConstraint = scalesTopConstraint,
      let unitPickerBottomConstraint = unitPickerBottomConstraint else {
      return
    }
    displayMode = (displayMode == .scales) ? .unitPicker : .scales
    UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      scalesTopConstraint.isActive = self.displayMode == .scales
      unitPickerBottomConstraint.isActive = self.displayMode == .unitPicker
      self.view.layoutIfNeeded()
    }.startAnimation()
    weightUnitButton.isEnabled = displayMode == .scales
    volumeUnitButton.isEnabled = displayMode == .scales
  }
}

extension ScaleViewController: UnitPickerDelegate {
  func picked(volumeUnit: CSUnit, weightUnit: CSUnit) {
    currentVolumeUnit = volumeUnit
    currentWeightUnit = weightUnit
    setContent()
    scalesContainer.updateConversionFactor(unitConversionFactor)
    toggleDisplayMode()
  }
}
