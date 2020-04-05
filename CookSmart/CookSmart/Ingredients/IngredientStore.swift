//
//  IngredientStore.swift
//  cake
//
//  Created by Alex King on 4/5/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

struct IngredientStore {
  typealias IngredientsDataType = [[String: [Ingredient]]]

  static let shared = IngredientStore()

  private init() {
    var isDirectory: ObjCBool = false
    if
      let diskIngredientsURL = IngredientStore.diskIngredientsURL,
      FileManager.default.fileExists(atPath: diskIngredientsURL.path, isDirectory: &isDirectory) {
      assert(!isDirectory.boolValue)
    } else {
      IngredientStore.copyIngredientsFromBundle()
    }
  }

  private static func copyIngredientsFromBundle() {
    guard let diskIngredientsURL = IngredientStore.diskIngredientsURL,
      let bundleIngredientsURL = IngredientStore.bundleIngredientsURL else {
      return
    }
    do {
      try FileManager.default.copyItem(at: bundleIngredientsURL, to: diskIngredientsURL)
    } catch {
      print(error)
    }
  }

  func loadIngredientsData() -> IngredientsDataType? {
    guard
      let diskIngredientsURL = IngredientStore.diskIngredientsURL else {
      return nil
    }
    do {
      let ingredientsData = try Data(contentsOf: diskIngredientsURL)
      let plistDecoder = PropertyListDecoder()
      let decoded = try plistDecoder.decode(IngredientsDataType.self, from: ingredientsData)
      return decoded
    } catch {
      print(error)
      return nil
    }
  }

  private static var diskIngredientsURL: URL? {
    guard
      var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      assertionFailure("Unable to get path to documents directory")
      return nil
    }
    documentsDirectory.appendPathComponent("ingredients.plist")
    return documentsDirectory
  }

  private static var bundleIngredientsURL: URL? {
    guard let path = Bundle.main.path(forResource: "Ingredients", ofType: "plist") else {
      return nil
    }
    return URL(fileURLWithPath: path)
  }
}
