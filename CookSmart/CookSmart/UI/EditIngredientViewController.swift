//
//  EditIngredientViewController.swift
//  cake
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine

class EditIngredientViewController: UIViewController {

  private enum EditingMode {
    case edit
    case add
  }

  private let inputIngredient: Ingredient?
  private weak var delegate: EditIngredientViewControllerDelegate?
  private var densityRx: AnyCancellable?

  public init(ingredient: Ingredient? = nil, delegate: EditIngredientViewControllerDelegate?) {
    inputIngredient = ingredient
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)

    ingredientNameField.delegate = self

    DispatchQueue.main.async {
      self.densityRx = self.scaleViewController.$currentDensity.sink {
        self.notifyDelegate(withNewDensity: $0)
      }
    }
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
    textField.applyTextStyle(.heading)
    return textField
  }()

  private lazy var scaleViewController = ScaleViewController(
    density: inputIngredient?.density ?? Density(inGramsPerCup: 150),
    shouldSyncScales: false
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (inputIngredient?.name ?? "").isEmpty {
      ingredientNameField.becomeFirstResponder()
    }
  }

  private func setupViews() {
    view.backgroundColor = CSColor.background.asUIColor()

    ingredientNameField.text = inputIngredient?.name ?? ""
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

  private func notifyDelegate(
    withNewIngredientName ingredientName: String? = nil,
    withNewDensity density: Density? = nil
  ) {
    delegate?.editViewControllerDidGenerate(
      ingredient: Ingredient(
        id: inputIngredient?.id ?? UUID(),
        name:
        ingredientName ??
          ingredientNameField.text.flatMap { $0 == "" ? nil : $0 } ??
          inputIngredient?.name ?? "",
        density: density ?? scaleViewController.currentDensity,
        lastAccessDate: Date()
      )
    )
  }
}

// MARK: UITextFieldDelegate

extension EditIngredientViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    ingredientNameField.resignFirstResponder()
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let oldText: NSString = (textField.text ?? "") as NSString
    let newText = oldText.replacingCharacters(in: range, with: string) as String
    notifyDelegate(withNewIngredientName: newText)
    return true
  }
}

// MARK: Analytics

extension EditIngredientViewController {
  private var analyticsDictionary: [String: Any] {
    let ingredientName = ingredientNameField.text ?? inputIngredient?.name ?? ""
    return [
      "ingredient_name": ingredientName,
      "ingredient_density": scaleViewController.currentDensity.analyticsRepresentation,
    ]
  }
}

protocol EditIngredientViewControllerDelegate: AnyObject {
  func editViewControllerDidGenerate(ingredient: Ingredient)
}
