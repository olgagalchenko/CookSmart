//
//  ScaleView.swift
//  cake
//
//  Created by Olga Galchenko on 4/12/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import SwiftUI

struct ScaleView: View {

  var unitButtonText: String
  @State var value: Double
  var unitButtonTapped: () -> Void

  var valueLabel: some View {
    Text(value.vulgarFractionString)
  }

  var body: some View {
    ZStack {
      ScaleScrollViewRepresentable()
      VStack {
        Button(action: unitButtonTapped) {
          Text(unitButtonText)
            .font(weight: .regular, size: 20)
        }
        valueLabel
      }
    }
  }
}

struct ScalesView_Previews: PreviewProvider {
  static var previews: some View {
    HStack(spacing: 0) {
      ScaleView(unitButtonText: "Cups", value: 0.95, unitButtonTapped: {})
      ScaleView(unitButtonText: "Grams", value: 35.44, unitButtonTapped: {})
    }
  }
}
