//
//  StoredIngredientGroup.swift
//  cake
//
//  Created by Vova Galchenko on 11/25/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

struct StoredIngredientGroup: IngredientGroup, Codable {

  let name: String
  var ingredients: [Ingredient]
  var id: String { name }

  // The custom decoder / encoder implementation below is unfortunately necessary, because of the weird way
  // we encode ingredient groups. Instead of static keys, such as "name" and "ingredients", we actually encode them
  // as something like [String: [Ingredient]]
  init(from decoder: Decoder) throws {
    let topLevelContainer = try decoder.singleValueContainer()
    let ingrGroupDict = try topLevelContainer.decode([String: [Ingredient]].self)
    assertAndLogOnFailure(ingrGroupDict.count == 1, "Trying to deserialize an incorrectly formatted ingredient group")
    name = ingrGroupDict.keys.first!
    ingredients = ingrGroupDict.values.first!
  }

  init(name: String, ingredients: [Ingredient]) {
    self.name = name
    self.ingredients = ingredients
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode([name: ingredients])
  }

  func filter(searchString: String) -> StoredIngredientGroup? {
    let filteredIngredients = ingredients.filter { $0.matches(searchString) }
    if filteredIngredients.isEmpty {
      return nil
    } else {
      return StoredIngredientGroup(name: name, ingredients: filteredIngredients)
    }
  }
}
