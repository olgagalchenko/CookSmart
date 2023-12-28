//
//  IngredientsStore.swift
//  cake
//
//  Created by Vova Galchenko on 11/25/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

// TODO: Add thorough testing
@objc class IngredientsStore: NSObject, ObservableObject {
  @objc static let shared = IngredientsStore()
  @Published private(set) var storedIngredientGroups: [StoredIngredientGroup] {
    didSet {
      // If the setting of this var is part of a locked critical section,
      // which should always be the case, so will be the execution of didSet.
      let encoder = PropertyListEncoder()
      encoder.outputFormat = .xml
      do {
        let data = try encoder.encode(storedIngredientGroups)
        try data.write(to: IngredientsStore.diskIngredientsURL)
      } catch {
        logAndFailAssertion("Failed to write ingredient groups to disk", error)
      }
    }
  }

  var ingredientGroups: [any IngredientGroup] {
    let stored = storedIngredientGroups
    return [RecentsIngredientGroup(storedIngredientGroups: stored)] + stored
  }

  var flatIngredients: [Ingredient] {
    ingredientGroups.flatMap(\.ingredients)
  }

  var ingredientRefs: [Ingredient.ID: IngredientRef] {
    storedIngredientGroups.enumerated().flatMap { groupIndex, group in
      group.ingredients.enumerated().map { ($1.id, IngredientRef(storedIngredientGroupIndex: groupIndex, ingredientIndex: $0)) }
    }.reduce(into: [Ingredient.ID: IngredientRef]()) { $0[$1.0] = $1.1 }
  }

  subscript(flattenedIndex: Array.Index) -> Ingredient {
    flatIngredients[flattenedIndex]
  }

  subscript(groupIndex: Array.Index, ingredientIndex: Array.Index) -> Ingredient {
    ingredientGroups[groupIndex].ingredients[ingredientIndex]
  }

  subscript(safeFlattenedIndex flattenedIndex: Array.Index) -> Ingredient? {
    let ingrs = flatIngredients
    if ingrs.indices.contains(flattenedIndex) {
      return ingrs[flattenedIndex]
    } else {
      return nil
    }
  }

  subscript(ingredientId: Ingredient.ID) -> Ingredient? {
    get {
      withIngredientGroupsSourceLock {
        if let ingrRef = ingredientRefs[ingredientId],
           storedIngredientGroups.indices.contains(ingrRef.storedIngredientGroupIndex) &&
           storedIngredientGroups[ingrRef.storedIngredientGroupIndex].ingredients.indices.contains(ingrRef.ingredientIndex) {
          storedIngredientGroups[ingrRef.storedIngredientGroupIndex].ingredients[ingrRef.ingredientIndex]
        } else {
          nil
        }
      }
    }

    set {
      withIngredientGroupsSourceLock {
        if let ingrRef = ingredientRefs[ingredientId],
           storedIngredientGroups.indices.contains(ingrRef.storedIngredientGroupIndex) &&
           storedIngredientGroups[ingrRef.storedIngredientGroupIndex].ingredients.indices.contains(ingrRef.ingredientIndex) {
          if let ingrToSet = newValue {
            storedIngredientGroups[ingrRef.storedIngredientGroupIndex].ingredients[ingrRef.ingredientIndex] = ingrToSet
          } else {
            // Ingredient deletion was requested
            storedIngredientGroups[ingrRef.storedIngredientGroupIndex].ingredients.remove(at: ingrRef.ingredientIndex)
          }
        } else if let newIngredient = newValue {
          if storedIngredientGroups.last!.name != "Custom" {
            storedIngredientGroups.append(StoredIngredientGroup(name: "Custom", ingredients: []))
          }
          storedIngredientGroups[storedIngredientGroups.endIndex - 1].ingredients.append(newIngredient)
        }
      }
      // If there's no ingredient by that id and a nil newValue is passed in, that means a deletion
      // of an ingredient that doesn't exist was requested. There's nothing to do.
    }
  }

  override private init() {
    storedIngredientGroups = IngredientsStore.readDataFromDisk()
  }

  private static func readDataFromDisk() -> [StoredIngredientGroup] {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: IngredientsStore.diskIngredientsURL.path, isDirectory: &isDir) {
      assertAndLogOnFailure(!isDir.boolValue, "The ingredients file's place is taken by a directory")
    } else {
      IngredientsStore.copyIngredientsFromBundle()
    }

    do {
      let ingredientsData = try Data(contentsOf: IngredientsStore.diskIngredientsURL)
      return try PropertyListDecoder().decode([StoredIngredientGroup].self, from: ingredientsData)
    } catch {
      logAndFailAssertion("Unable to read the ingredients plist", error)
    }
  }

  init(testData: [StoredIngredientGroup]) {
    assertAndLogOnFailure(
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
      "This initializer is only here for test purposes"
    )
    storedIngredientGroups = testData
  }

  // Just a convenience function – the same can be accomplished via subscript
  public func upsert(_ ingredient: Ingredient) {
    self[ingredient.id] = ingredient
  }

  public func delete(ingredientsWithIds ingredientIds: [Ingredient.ID]) {
    withIngredientGroupsSourceLock {
      ingredientIds.forEach { self[$0] = nil }
    }
  }

  public func resetToDefault() {
    withIngredientGroupsSourceLock {
      do {
        try FileManager.default.removeItem(at: IngredientsStore.diskIngredientsURL)
      } catch {
        logAndFailAssertion("Failed to remove the ingredients from disk as part of reset", error)
      }
      storedIngredientGroups = IngredientsStore.readDataFromDisk()
    }
  }

  func flattenedForIngredient(withId id: Ingredient.ID) -> Int {
    flatIngredients.firstIndex { $0.id == id }!
  }

  private func flattenedIndexFor(groupIndex: Int, ingredientIndex: Int) -> Int {
    ingredientGroups.prefix(groupIndex).reduce(0) { $0 + $1.ingredients.count } + ingredientIndex
  }

  private let ingredientGroupsSourceLock = NSRecursiveLock()
  private func withIngredientGroupsSourceLock<T>(_ closure: () -> T) -> T {
    ingredientGroupsSourceLock.lock()
    defer { ingredientGroupsSourceLock.unlock() }
    return closure()
  }

  private static func copyIngredientsFromBundle() {
    do {
      try FileManager.default.copyItem(at: bundleIngredientsURL, to: diskIngredientsURL)
    } catch {
      logAndFailAssertion("Unable to copy the ingredients plist from the app bundle", error)
    }
  }

  private static var diskIngredientsURL: URL {
    guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      logAndFailAssertion("Unable to get the path to the documents directory")
    }
    if #available(iOS 16.0, *) {
      return documentDir.appending(path: "ingredients.plist")
    } else {
      return documentDir.appendingPathComponent("ingredients.plist")
    }
  }

  private static var bundleIngredientsURL: URL {
    guard let url = Bundle.main.url(forResource: "Ingredients", withExtension: "plist") else {
      logAndFailAssertion("Unable to find the ingredients plist in the app bundle")
    }
    return url
  }

  // MARK: ObjC Interop Cruft

  @objc func markAccessOfIngredientAtFlattenedIndex(_ flattenedIndex: Array.Index) {
    withIngredientGroupsSourceLock {
      if let existingIngredient = self[safeFlattenedIndex: flattenedIndex] {
        self[existingIngredient.id] = Ingredient(
          id: existingIngredient.id,
          name: existingIngredient.name,
          density: existingIngredient.density,
          lastAccessDate: Date()
        )
      }
    }
  }

  @objc func ingredientNameAtFlattenedIndex(_ flattenedIndex: Int) -> String? {
    self[safeFlattenedIndex: flattenedIndex]?.name
  }

  @objc func flattenedCountOfIngredients() -> Int {
    flatIngredients.count
  }

  @objc func ingredientAnalyticsDictForIngredientAtFlattenedIndex(_ flattenedIndex: Int) -> [String: Any] {
    let ingr = flatIngredients[flattenedIndex]
    return [
      "ingredient_name": ingr.name,
      "ingredient_density": ingr.density.analyticsRepresentation,
      "ingredient_id": ingr.id.uuidString,
    ]
  }

  @objc func flattenedIndexForGroupIndex(_ groupIndex: Int, ingredientIndex: Int) -> Int {
    flattenedIndexFor(groupIndex: groupIndex, ingredientIndex: ingredientIndex)
  }

  @objc func ingredientDictAtFlattenedIndex(_ flattenedIndex: Int) -> [String: Any] {
    self[flattenedIndex].toDictionary()
  }
}

struct IngredientRef {
  let storedIngredientGroupIndex: Int
  let ingredientIndex: Int
}
