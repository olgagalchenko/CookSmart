//
//  ScaleViewController.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

class ScaleViewController: UIViewController {
  init(ingredient: CSIngredient, shouldSyncScales: Bool = true) {
    self.ingredient = ingredient
    super.init(nibName: nil, bundle: nil)

    setUpViews()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  var ingredient: CSIngredient

  var densityDidChange: ((_ density: Double) -> Void)?
  var didBeginScrolling: (() -> Void)?

  // MARK: Private

  private let volumeLabel = UILabel()
  private let weightLabel = UILabel()
  private let volumeUnitButton = UIButton()
  private let weightUnitButton = UIButton()
  private let volumeScrollView = CSScaleView()
  private let weightScollView = CSScaleView()
  private let scalesContainer = UIView()

  private func setUpViews() {
    scalesContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scalesContainer)
    scalesContainer.constrainToSuperview()
  }
}
