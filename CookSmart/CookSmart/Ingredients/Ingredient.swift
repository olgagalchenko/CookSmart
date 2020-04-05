//
//  Ingredient.swift
//  cake
//
//  Created by Alex King on 4/5/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

struct Ingredient: Codable {
  let name: String
  let density: Double
  let lastAccessDate: Date?

  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case density = "Density"
    case lastAccessDate = "LastAccessDate"
  }
}

extension Ingredient: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    (lhs.name == rhs.name) && (lhs.density == rhs.density)
  }
}
