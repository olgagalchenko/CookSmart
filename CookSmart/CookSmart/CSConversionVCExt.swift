//
//  CSConversionVCExt.swift
//  cake
//
//  Created by Alex King on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

extension CSConversionVC {
  @objc
  func showIngredientList() {
    let ingredientListViewController = IngredientListViewController()
    present(ingredientListViewController, animated: true, completion: nil)
  }
}
