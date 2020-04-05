//
//  IngredientGroup.swift
//  cake
//
//  Created by Alex King on 4/5/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

struct IngredientGroup {
  let name: String
  let ingredients: [Ingredient]
}

extension IngredientGroup: Identifiable {
  var id: String {
    return name
  }
}
