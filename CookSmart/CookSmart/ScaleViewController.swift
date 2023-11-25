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

  init(ingredient: CSIngredient,
       volumeUnit: CSUnit = CSUnitCollection.volumeUnits()?.unit(at: 2) ?? CSUnit(),
       weightUnit: CSUnit = CSUnitCollection.weightUnits()?.unit(at: 2) ?? CSUnit(),
       shouldSyncScales: Bool = true) {
    self.ingredient = ingredient
    let density = CGFloat(ingredient.density(withVolumeUnit: volumeUnit, andWeightUnit: weightUnit))
    scalesContainer = ScalesView(unitConversionFactor: density, syncScales: shouldSyncScales)
    unitPickerView = UnitPickerView(volumeUnit: volumeUnit, weightUnit: weightUnit)

    super.init(nibName: nil, bundle: nil)

    volumeUnitButton.setTitle(volumeUnit.name, for: .normal)
    weightUnitButton.setTitle(weightUnit.name, for: .normal)
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

  var ingredient: CSIngredient
  var density: CGFloat {
    get {
      scalesContainer.unitConversionFactor
    }
    set {
      scalesContainer.updateConversionFactor(newValue)
    }
  }

  // MARK: Private

  private var displayMode: DisplayMode = .scales

  private lazy var volumeUnitButton: Button = {
    let button = Button()
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Volume", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private lazy var weightUnitButton: Button = {
    let button = Button()
    button.setTitleColor(.label, for: .disabled)
    button.setTitle("Weight", for: .disabled)
    button.addTarget(self, action: #selector(toggleDisplayMode), for: .touchUpInside)
    return button
  }()

  private let scalesContainer: ScalesView
  private let unitPickerView: UnitPickerView

  private var scalesTopConstraint: NSLayoutConstraint?
  private var unitPickerBottomConstraint: NSLayoutConstraint?

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
    weightUnitButton.isEnabled = displayMode == .scales
    volumeUnitButton.isEnabled = displayMode == .scales
  }
}

extension ScaleViewController: UnitPickerDelegate {
  func picked(volumeUnit: CSUnit, weightUnit: CSUnit) {
    volumeUnitButton.setTitle(volumeUnit.name, for: .normal)
    weightUnitButton.setTitle(weightUnit.name, for: .normal)

    density = CGFloat(ingredient.density(withVolumeUnit: volumeUnit, andWeightUnit: weightUnit))
    toggleDisplayMode()
  }
}
