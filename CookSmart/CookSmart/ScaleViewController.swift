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

  var ingredient: CSIngredient {
    didSet {
      scalesContainer.ingredient = ingredient
    }
  }
  
  var currentVolumeUnit: CSUnit { CSUnitCollection.volumeUnits()?.unit(at: 2) ?? CSUnit() }
  var currentWeightUnit: CSUnit { CSUnitCollection.weightUnits()?.unit(at: 2) ?? CSUnit() }

  var densityDidChange: ((_ density: Double) -> Void)?
  var didBeginScrolling: (() -> Void)?

  // MARK: Private

  private let volumeUnitButton = Button()
  private let weightUnitButton = Button()
  private lazy var scalesContainer = ScalesView(ingredient: ingredient)

  private var unitConversionFactor: Float {
    return ingredient.density(withVolumeUnit: currentVolumeUnit, andWeightUnit: currentWeightUnit)
  }

  private func setUpViews() {
//    let childView = UIHostingController(rootView: scaleView)
//    addChild(childView)
//    view.addSubview(childView.view)
//    childView.view.translatesAutoresizingMaskIntoConstraints = false
//    childView.view.constrainToSuperview()
//    childView.didMove(toParent: self)

    setUpScaleViews()
    setUpUnitViews()
  }

  private func setUpUnitViews() {
    let gradientView = GradientView()
    view.addSubview(gradientView)
    gradientView.constrainToSuperview(anchors: [.leading, .top, .right], priority: .defaultHigh, shouldActivate: true)
    gradientView.heightAnchor.constraint(equalToConstant: 100).isActive = true

    gradientView.addSubview(volumeUnitButton)
    volumeUnitButton.constrainToSuperview(anchors: [.leading, .top], priority: .defaultHigh, shouldActivate: true)

    gradientView.addSubview(weightUnitButton)
    weightUnitButton.constrainToSuperview(anchors: [.trailing, .top], priority: .defaultHigh, shouldActivate: true)

    volumeUnitButton.trailingAnchor.constraint(equalTo: weightUnitButton.leadingAnchor, constant: 0).isActive = true
    volumeUnitButton.widthAnchor.constraint(equalTo: weightUnitButton.widthAnchor, multiplier: 1).isActive = true
  }

  private func setUpScaleViews() {
    scalesContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scalesContainer)
    scalesContainer.constrainToSuperview()
  }

  private func setContent() {
    volumeUnitButton.setTitle(currentVolumeUnit.name, for: .normal)
    weightUnitButton.setTitle(currentWeightUnit.name, for: .normal)
  }
}
