//
//  ScaleView.swift
//  cake
//
//  Created by Olga Galchenko on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class ScaleScrollView: UIScrollView {
  static let height_200: CGFloat = 200

  @objc
  init(frame: CGRect, centerValue: Double, unitsPerTile: Int, mirror: Bool) {
    self.centerValue = centerValue
    self.unitsPerTile = unitsPerTile
    self.mirror = mirror

    super.init(frame: frame)

    setUpViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private let centerValue: Double
  private let unitsPerTile: Int
  private let mirror: Bool
  private let tileContainer = UIView()

  private func setUpViews() {
    backgroundColor = UIColor.clear
    contentSize = CGSize(width: bounds.size.width, height: bounds.size.height * 2)
//    addSubview(tileContainer)

//    tileContainer.backgroundColor = UIColor.systemBlue

    var index = 0
    for y in stride(from: 0, to: contentSize.height / 2, by: 200) {
      index += 1
      let tile = ScaleTile(
        frame: CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: bounds.width, height: 200)),
        mirror: mirror
      )
      tile.value = Float(unitsPerTile * index)
      print(tile.frame)
      addSubview(tile)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }
}

struct ScalePreview: PreviewProvider {
  static var preview: some View {
    HStack(spacing: 0) {
      ScalePreviewContainer(unitsPerTile: 1, mirror: false)
        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
      ScalePreviewContainer(unitsPerTile: 125, mirror: true)
        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
    }
  }

  static var previews: some View {
    Group {
      NavigationView {
        preview
      }.environment(\.colorScheme, .light)
      NavigationView {
        preview
      }.environment(\.sizeCategory, .extraLarge)
      NavigationView {
        preview
      }.environment(\.colorScheme, .dark)
    }
  }

  struct ScalePreviewContainer: UIViewRepresentable {
    init(unitsPerTile: Int, mirror: Bool) {
      self.unitsPerTile = unitsPerTile
      self.mirror = mirror
    }

    var unitsPerTile: Int
    var mirror: Bool

    func makeUIView(context _: UIViewRepresentableContext<ScalePreview.ScalePreviewContainer>) -> UIView {
      ScaleScrollView(
        frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height),
        centerValue: 1,
        unitsPerTile: unitsPerTile,
        mirror: mirror
      )
//      ScaleScrollView(frame: CGRect.zero, centerValue: 1, unitsPerTile: 125, mirror: false)
    }

    func updateUIView(_: UIViewType, context _: UIViewRepresentableContext<ScalePreview.ScalePreviewContainer>) {}

    typealias UIViewType = UIView
  }
}
