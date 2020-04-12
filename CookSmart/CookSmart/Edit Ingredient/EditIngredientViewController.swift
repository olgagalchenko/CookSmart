//
//  EditIngredientViewController.swift
//  cake
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

class EditIngredientViewController: UIViewController {

  private let ingredient: CSIngredient

  public init(ingredient: CSIngredient? = nil) {
    self.ingredient = ingredient ?? CSIngredient(name: "",
                                                 density: 150,
                                                 lastAccessDate: Date())
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
    return textField
  }()

  private let scaleViewController = CSScaleVC(nibName: "CSScaleVC", bundle: nil)

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

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  private func setupViews() {
    view.backgroundColor = Color.background

    ingredientNameField.delegate = self
    view.addSubview(ingredientNameField)
    ingredientNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    ingredientNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    ingredientNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    ingredientNameField.heightAnchor.constraint(equalToConstant: 70).isActive = true

    addChild(scaleViewController)
    view.addSubview(scaleViewController.view)
    scaleViewController.view.translatesAutoresizingMaskIntoConstraints = false
    scaleViewController.syncsScales = false
    scaleViewController.delegate = self

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

  }
}

extension EditIngredientViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    ingredientNameField.resignFirstResponder()
    return true
  }
}

extension EditIngredientViewController: CSScaleVCDelegate {

  func scaleVC(_ scaleVC: CSScaleVC!, densityDidChange changedDensity: Float) {
    ingredient.density = changedDensity
  }

  func scaleVCWillBeginHandlingInteraction(_ scaleVC: CSScaleVC!) {
    ingredientNameField.resignFirstResponder()
  }

}
