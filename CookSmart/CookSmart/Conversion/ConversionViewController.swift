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
  private var ingredientIndex: UInt = 0

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let ingredientLabel: UILabel = {
    let label = UILabel()
    label.textColor = Color.redLineColor
    label.font = Fonts.regular?.withSize(20)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let ingredientLabelContainer = UIView()

  private let scaleViewController = CSScaleVC(nibName: "CSScaleVC", bundle: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    selectIngredientAtCurrentIndex()
  }

  private func setupViews() {
    view.backgroundColor = .systemBackground

    ingredientLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(ingredientLabelContainer)
    ingredientLabelContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    ingredientLabelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    ingredientLabelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    ingredientLabelContainer.heightAnchor.constraint(equalToConstant: 70).isActive = true

    ingredientLabelContainer.addSubview(ingredientLabel)
    ingredientLabel.centerYAnchor.constraint(equalTo: ingredientLabelContainer.centerYAnchor).isActive = true
    ingredientLabel.centerXAnchor.constraint(equalTo: ingredientLabelContainer.centerXAnchor).isActive = true
    ingredientLabel.leadingAnchor.constraint(greaterThanOrEqualTo: ingredientLabelContainer.leadingAnchor, constant: 15).isActive = true

    addChild(scaleViewController)
    view.addSubview(scaleViewController.view)
    scaleViewController.view.translatesAutoresizingMaskIntoConstraints = false
    scaleViewController.delegate = self

    scaleViewController.view.topAnchor.constraint(equalTo: ingredientLabelContainer.bottomAnchor).isActive = true
    scaleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scaleViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scaleViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }

  private func selectIngredientAtCurrentIndex() {
    let ingredient = CSIngredients.sharedInstance()?.ingredient(atFlattenedIngredientIndex: ingredientIndex)
    ingredientLabel.text = ingredient?.name
    scaleViewController.ingredient = ingredient
  }
}

extension ConversionViewController: CSScaleVCDelegate {}
