//
//  CSIngredientsExt.swift
//  cake
//
//  Created by Alex King on 3/29/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

extension CSIngredient: Identifiable {
  public var id: String { name }
}

extension CSIngredientGroup: Identifiable {
  public var id: String { name }
}

extension CSIngredientGroup {
  var ingredients: [CSIngredient] {
    (0 ..< countOfIngredients()).map { ingredient(at: $0) }
  }
}

extension CSIngredients {
  var ingredientList: [CSIngredientGroup] {
    let groups: [CSIngredientGroup] = (0 ..< countOfIngredientGroups()).map { ingredientGroup(at: $0) }
    return groups
  }
}
