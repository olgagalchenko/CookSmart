//
//  EditIngredientViewController.swift
//  cake
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

class EditIngredientViewController: UIViewController {

  private enum EditingMode {
    case edit
    case add
  }

  private let ingredient: CSIngredient
  private let editingMode: EditingMode
  private lazy var density: Float = ingredient.density

  @objc
  public init(ingredient: CSIngredient? = nil) {
    if let ingredient = ingredient {
      self.ingredient = ingredient
      editingMode = .edit
    } else {
      self.ingredient = CSIngredient(name: "",
                                     density: 150,
                                     lastAccessDate: Date())
      editingMode = .add
    }
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private let ingredientNameField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.returnKeyType = .done
    textField.textAlignment = .center
    textField.placeholder = "Ingredient Name"
    textField.autocapitalizationType = .words
    textField.font = AvenirFont.medium.of(size: 20)
    textField.textColor = .label
    textField.tintColor = Color.redLineColor
    return textField
  }()

  private lazy var scaleViewController = ScaleViewController(ingredient: ingredient, shouldSyncScales: false)

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    addBarButtonItems()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if ingredient.name.isEmpty {
      ingredientNameField.becomeFirstResponder()
    }
  }

  private func setupViews() {
    view.backgroundColor = Color.background

    ingredientNameField.text = ingredient.name
    ingredientNameField.delegate = self
    view.addSubview(ingredientNameField)
    ingredientNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    ingredientNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    ingredientNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    ingredientNameField.heightAnchor.constraint(equalToConstant: 70).isActive = true

    addChild(scaleViewController)
    view.addSubview(scaleViewController.view)
    scaleViewController.view.translatesAutoresizingMaskIntoConstraints = false

    scaleViewController.view.topAnchor.constraint(equalTo: ingredientNameField.bottomAnchor).isActive = true
    scaleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scaleViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scaleViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }

  private func addBarButtonItems() {
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                       target: self,
                                       action: #selector(cancelButtonPressed))
    cancelButton.tintColor = Color.redLineColor
    navigationItem.leftBarButtonItem = cancelButton

    let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(doneButtonPressed))
    doneButton.tintColor = Color.redLineColor
    navigationItem.rightBarButtonItem = doneButton
  }

  @objc
  private func cancelButtonPressed() {
    navigationController?.popViewController(animated: true)
  }

  @objc
  private func doneButtonPressed() {
    guard let ingredientName = ingredientNameField.text, !ingredientName.isEmpty else {
      ingredientNameField.becomeFirstResponder()
      return
    }

    guard densityIsValid else {
      displayInvalidDensityAlert()
      logUserAction("ingredient_persist_fail", analyticsDictionary)
      return
    }

    updateIngredient()
    switch editingMode {
    case .add:
      CSIngredients.sharedInstance()?.add(ingredient)
    case .edit:
      CSIngredients.sharedInstance()?.persist()
    }

    navigationController?.popViewController(animated: true)
  }

  private func updateIngredient() {
    ingredient.name = ingredientNameField.text
    ingredient.density = density
    ingredient.markAccess()
  }

  private func displayInvalidDensityAlert() {
    let alertController = UIAlertController(title: "Error",
                                            message: "Choose a weight greater than 0.",
                                            preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK",
                                 style: .default,
                                 handler: nil)
    alertController.addAction(okAction)
    present(alertController, animated: true)
  }

  private var densityIsValid: Bool {
    !density.isNaN
      && !density.isInfinite
      && !density.isZero
  }
}

// MARK: UITextFieldDelegate

extension EditIngredientViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    ingredientNameField.resignFirstResponder()
    return true
  }
}

// MARK: CSScaleVCDelegate

extension EditIngredientViewController: CSScaleVCDelegate {

  func scaleVC(_ scaleVC: CSScaleVC!, densityDidChange changedDensity: Float) {
    density = changedDensity
  }

  func scaleVCWillBeginHandlingInteraction(_ scaleVC: CSScaleVC!) {
    ingredientNameField.resignFirstResponder()
  }
}

// MARK: Analytics

extension EditIngredientViewController {
  private var analyticsDictionary: [String: Any] {
    let ingredientName = ingredientNameField.text ?? ingredient.name ?? ""
    let ingredientDensity = densityIsValid ? density : Float.infinity
    return [
      "ingredient_name": ingredientName,
      "ingredient_density": ingredientDensity,
    ]
  }
}
