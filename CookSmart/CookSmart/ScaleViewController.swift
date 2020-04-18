//
//  ScaleViewController.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI

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
  }

  // MARK: Public

  var ingredient: CSIngredient

  var densityDidChange: ((_ density: Double) -> Void)?
  var didBeginScrolling: (() -> Void)?

  // MARK: Private

//  private let volumeLabel = UILabel()
//  private let weightLabel = UILabel()
//  private let volumeUnitButton = UIButton()
//  private let weightUnitButton = UIButton()
//  private let volumeScrollView = CSScaleView()
//  private let weightScollView = CSScaleView()
//  private let scalesContainer = UIView()
  private let scaleView = ScaleView(
    unitButtonText: "Cups",
    value: 1,
    unitButtonTapped: {
      print("unit button tapped")
    }
  )

  private func setUpViews() {
//    scalesContainer.translatesAutoresizingMaskIntoConstraints = false
//    view.addSubview(scalesContainer)
//    scalesContainer.constrainToSuperview()

    let childView = UIHostingController(rootView: scaleView)
    addChild(childView)
    view.addSubview(childView.view)
    childView.view.translatesAutoresizingMaskIntoConstraints = false
    childView.view.constrainToSuperview()
    childView.didMove(toParent: self)
  }
}
