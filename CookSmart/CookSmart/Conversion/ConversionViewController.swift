//
//  ConversionViewController.swift
//  cake
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

class ConversionViewController: UIViewController {
  private enum Constants {
    static let ingredientButtonHeight: CGFloat = 75
  }

  private var ingredientIndex: UInt = 0

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let ingredientButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(Color.redLineColor, for: .normal)
    button.titleLabel?.font = AvenirFont.medium.of(size: 17)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(ingredientButtonPressed), for: .touchUpInside)
    return button
  }()

  private lazy var scaleViewController = ScaleViewController(ingredient: currentIngredient!, shouldSyncScales: true)

  private var currentIngredient: CSIngredient? {
    CSIngredients.sharedInstance()?.ingredient(atFlattenedIngredientIndex: ingredientIndex)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    selectIngredientAtCurrentIndex()

    _ = NotificationCenter.default.addObserver(forName: NSNotification.Name(INGREDIENT_DELETE_NOTIFICATION_NAME),
                                               object: nil,
                                               queue: nil) { [weak self] _ in
      self?.ingredientIndex = 0
      self?.selectIngredientAtCurrentIndex()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    selectIngredientAtCurrentIndex()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    markIngredientAccess()
  }

  private func setupViews() {
    view.backgroundColor = Color.background

    view.addSubview(ingredientButton)
    ingredientButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    ingredientButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    ingredientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    ingredientButton.heightAnchor.constraint(equalToConstant: Constants.ingredientButtonHeight).isActive = true

    addChild(scaleViewController)
    view.addSubview(scaleViewController.view)
    scaleViewController.view.translatesAutoresizingMaskIntoConstraints = false

    scaleViewController.view.topAnchor.constraint(equalTo: ingredientButton.bottomAnchor).isActive = true
    scaleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scaleViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scaleViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }

  private func selectIngredientAtCurrentIndex() {
    guard let ingredient = CSIngredients.sharedInstance()?.ingredient(atFlattenedIngredientIndex: ingredientIndex) else {
      return
    }
    ingredientButton.setTitle(ingredient.name, for: .normal)
    scaleViewController.ingredient = ingredient
    markIngredientAccess()
  }

  private func markIngredientAccess() {
    currentIngredient?.markAccess()
  }

  @objc
  private func ingredientButtonPressed() {
    guard let ingredientListVC = CSIngredientListVC(delegate: self) else {
      return
    }
    let ingredientListNav = UINavigationController(rootViewController: ingredientListVC)
    present(ingredientListNav, animated: true)
  }
}

extension ConversionViewController: CSIngredientListVCDelegate {
  func ingredientListVC(_ listVC: CSIngredientListVC!, selectedIngredientGroup ingredientGroupIndex: UInt, ingredientIndex index: UInt) {
    ingredientIndex = CSIngredients.sharedInstance()?.flattenedIngredientIndex(forGroupIndex: ingredientGroupIndex, ingredientIndex: index) ?? 0
    selectIngredientAtCurrentIndex()
  }
}
