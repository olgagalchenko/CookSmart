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

  var ingredient: CSIngredient
  var currentVolumeUnit: CSUnit { CSUnitCollection.volumeUnits()?.unit(at: 2) ?? CSUnit() }
  var currentWeightUnit: CSUnit { CSUnitCollection.weightUnits()?.unit(at: 2) ?? CSUnit() }

  var densityDidChange: ((_ density: Double) -> Void)?
  var didBeginScrolling: (() -> Void)?

  // MARK: Private

  private let volumeLabel = UILabel()
  private let weightLabel = UILabel()
  private let volumeUnitButton = UIButton()
  private let weightUnitButton = UIButton()
  private let volumeScrollView = ScaleScrollView(mirror: false)
  private let weightScrollView = ScaleScrollView(mirror: true)
  private let scalesContainer = UIView()
//  private let scaleView = ScaleView(
//    unitButtonText: "Cups",
//    value: 1,
//    unitButtonTapped: {
//      print("unit button tapped")
//    }
//  )

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
    let gradientView = GradientView(startColor: UIColor.clear, endColor: Color.background)
    view.addSubview(gradientView)
    gradientView.constrainToSuperview(anchors: [.leading, .top, .right], priority: .defaultHigh, shouldActivate: true)
    gradientView.heightAnchor.constraint(equalToConstant: 100).isActive = true

    volumeUnitButton.translatesAutoresizingMaskIntoConstraints = false
    gradientView.addSubview(volumeUnitButton)
    volumeUnitButton.constrainToSuperview(anchors: [.leading, .top], priority: .defaultHigh, shouldActivate: true)

    weightUnitButton.translatesAutoresizingMaskIntoConstraints = false
    gradientView.addSubview(weightUnitButton)
    weightUnitButton.constrainToSuperview(anchors: [.trailing, .top], priority: .defaultHigh, shouldActivate: true)

    NSLayoutConstraint(
      item: volumeUnitButton,
      attribute: .trailing,
      relatedBy: .equal,
      toItem: weightUnitButton,
      attribute: .leading,
      multiplier: 1,
      constant: 0
    ).isActive = true

    NSLayoutConstraint(
      item: volumeUnitButton,
      attribute: .width,
      relatedBy: .equal,
      toItem: weightUnitButton,
      attribute: .width,
      multiplier: 1,
      constant: 0
    ).isActive = true
  }

  private func setUpScaleViews() {
    scalesContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scalesContainer)
    scalesContainer.constrainToSuperview()

    volumeScrollView.translatesAutoresizingMaskIntoConstraints = false
    scalesContainer.addSubview(volumeScrollView)
    volumeScrollView.constrainToSuperview(
      anchors: [.top, .leading, .bottom],
      priority: .defaultHigh,
      shouldActivate: true
    )

    weightScrollView.translatesAutoresizingMaskIntoConstraints = false
    scalesContainer.addSubview(weightScrollView)
    weightScrollView.constrainToSuperview(
      anchors: [.top, .trailing, .bottom],
      priority: .defaultHigh,
      shouldActivate: true
    )

    volumeScrollView.trailingAnchor.constraint(equalTo: weightScrollView.leadingAnchor, constant: 0).isActive = true
    volumeScrollView.widthAnchor.constraint(equalTo: weightScrollView.widthAnchor, multiplier: 1).isActive = true

    volumeLabel.translatesAutoresizingMaskIntoConstraints = false
    volumeScrollView.addSubview(volumeLabel)
    volumeLabel.constrainToSuperview(anchors: [.centerX, .centerY], priority: .defaultHigh, shouldActivate: true)

    weightLabel.translatesAutoresizingMaskIntoConstraints = false
    weightScrollView.addSubview(weightLabel)
    weightLabel.constrainToSuperview(anchors: [.centerX, .centerY], priority: .defaultHigh, shouldActivate: true)
  }

  private func setContent() {
    volumeUnitButton.setTitle(currentVolumeUnit.name, for: .normal)
    weightUnitButton.setTitle(currentWeightUnit.name, for: .normal)
  }
}
