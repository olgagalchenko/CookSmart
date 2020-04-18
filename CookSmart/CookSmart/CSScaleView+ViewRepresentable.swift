//
//  CSScaleView+ViewRepresentable.swift
//  cake
//
//  Created by Olga Galchenko on 4/12/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import SwiftUI

struct ScaleScrollView: UIViewRepresentable {
  func makeUIView(context: Context) -> CSScaleView {
    let scrollView = CSScaleView()
    scrollView.configureScaleView(withInitialCenterValue: 1, scale: 1, mirror: false)
    scrollView.layoutSubviews()
    return scrollView
  }

  func updateUIView(_ scaleView: CSScaleView, context: Context) {
//    scaleView.configureScaleView(withInitialCenterValue: 1, scale: 1, mirror: false)
//    scaleView.layoutSubviews()
  }
}

struct ScaleScrollView_Previews: PreviewProvider {
  static var previews: some View {
    ScaleScrollView()
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
}
