//
//  RecentsIngredientGroup.swift
//  cake
//
//  Created by Vova Galchenko on 11/28/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

struct RecentsIngredientGroup: IngredientGroup {
  let name: String
  let ingredients: [Ingredient]
  private static let maxNumRecents = 5

  init(storedIngredientGroups: [StoredIngredientGroup]) {
    name = "Recents"
    ingredients = storedIngredientGroups
      .flatMap(\.ingredients)
      .filter { $0.lastAccessDate != nil }
      .sorted { $0.lastAccessDate! > $1.lastAccessDate! }
      .prefix(RecentsIngredientGroup.maxNumRecents)
      .map { $0 } // <- this is to turn ArraySlice into Array
  }

  func filter(searchString: String) -> RecentsIngredientGroup? {
    nil
  }
}
