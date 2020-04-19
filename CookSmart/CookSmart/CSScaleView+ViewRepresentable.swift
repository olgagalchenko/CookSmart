//
//  CSScaleView+ViewRepresentable.swift
//  cake
//
//  Created by Olga Galchenko on 4/12/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import SwiftUI

struct ScaleScrollViewRepresentable: UIViewRepresentable {
  func makeUIView(context: Context) -> ScaleScrollView {
    ScaleScrollView()
  }

  func updateUIView(_ scaleView: ScaleScrollView, context: Context) {}
}

struct ScaleScrollView_Previews: PreviewProvider {
  static var previews: some View {
    ScaleScrollViewRepresentable()
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
}
