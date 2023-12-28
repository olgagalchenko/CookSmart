//
//  IngredientGroup.swift
//  cake
//
//  Created by Vova Galchenko on 11/28/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

import Foundation

protocol IngredientGroup: Identifiable where ID == String {

  var name: String { get }
  var id: String { get }
  var ingredients: [Ingredient] { get }

  func filter(searchString: String) -> Self?
}

extension IngredientGroup {
  var id: String { name }
}
