//
//  Ingredient.swift
//  cake
//
//  Created by Vova Galchenko on 11/25/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

struct Ingredient: Codable, Identifiable, Equatable {
  let id: UUID
  let name: String
  let density: Density
  var lastAccessDate: Date?

  init(id: UUID, name: String, density: Density, lastAccessDate: Date? = nil) {
    self.id = id
    self.name = name
    self.density = density
    self.lastAccessDate = lastAccessDate
  }

  init(name: String, density: Density, lastAccessDate: Date? = nil) {
    assertAndLogOnFailure(
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
      "This initializer is only here for test purposes"
    )
    id = UUID()
    self.name = name
    self.density = density
    self.lastAccessDate = lastAccessDate
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case density
    case lastAccessDate

    // TODO: get rid of this once @objc interop is no longer necessary
    var rawValue: String {
      switch self {
      case .id: return "Id"
      case .name: return IngredientKeyName
      case .density: return IngredientKeyDensity
      case .lastAccessDate: return IngredientKeyLastAccessDate
      }
    }
  }

  // Custom decoder to handle the case where the id isn't present.
  // This is going to be in case of apps with old data.
  // For now, I'm also not going to bother creating ids in the app bundle either.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = if let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id) {
      decodedId
    } else {
      UUID()
    }
    name = try container.decode(String.self, forKey: .name)
    density = try container.decode(Density.self, forKey: .density)
    lastAccessDate = try container.decodeIfPresent(Date.self, forKey: .lastAccessDate)
  }

  func matches(_ searchString: String) -> Bool {
    name.range(of: searchString, options: .caseInsensitive) != nil
  }

  // TODO: Remove this objc interop utility when it's no longer necessary
  func toDictionary() -> [String: Any] {
    let baseDict = [
      CodingKeys.name.stringValue: name,
      CodingKeys.density.stringValue: density.canonical,
    ] as [String: Any]
    let date: [String: Any] = if lastAccessDate == nil {
      [:]
    } else {
      [CodingKeys.lastAccessDate.stringValue: lastAccessDate!]
    }
    return baseDict.merging(date, uniquingKeysWith: { _, x in x })
  }
}
