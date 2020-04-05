//
//  ViewControllerRepresentables.swift
//  cake
//
//  Created by Alex King on 3/29/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI

final class CSEditIngredientVCRepresentable: UIViewControllerRepresentable {
  func updateUIViewController(_: CSEditIngredientVC, context _: Context) {}

  func makeUIViewController(context _: Context) -> CSEditIngredientVC {
    CSEditIngredientVC(ingredient: nil,
                       withDoneBlock: { _ in },
                       andCancel: {})
  }
}
