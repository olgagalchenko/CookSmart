//
//  Ingredients.swift
//  cake
//
//  Created by Alex King on 4/5/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

struct Ingredients {
  static let shared = Ingredients()

  private(set) var ingredientGroups: [IngredientGroup]

  private init() {
    guard let ingredientsData = IngredientStore.shared.loadIngredientsData() else {
      ingredientGroups = []
      return
    }
    ingredientGroups = Ingredients.makeIngredientGroups(data: ingredientsData)
  }

  private static func makeIngredientGroups(data: IngredientStore.IngredientsDataType) -> [IngredientGroup] {
    data.flatMap {
      $0.map { IngredientGroup(name: $0, ingredients: $1) }
    }
  }
}
