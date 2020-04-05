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
  static let TileHeight: CGFloat = 200

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
    setUpScrollView()
    contentSize = CGSize(width: bounds.size.width, height: bounds.size.height * 2)

//    addSubview(tileContainer)

    var index = 0
    for bottomTileY in stride(from: 0, to: contentSize.height / 2, by: ScaleScrollView.TileHeight) {
      let tile = ScaleTile(
        frame: CGRect(x: 0, y: bottomTileY, width: bounds.width, height: ScaleScrollView.TileHeight),
        mirror: mirror
      )
      tile.value = Float(unitsPerTile * index)
      addSubview(tile)
      index += 1
    }
  }

  private func setUpScrollView() {
    backgroundColor = UIColor.clear
    bounces = false
    isPagingEnabled = false
    alwaysBounceVertical = false
    alwaysBounceHorizontal = false
    bouncesZoom = false
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let targetContentOffset = contentSize.height / 3 // + bounds.height / 2
    if contentOffset.y > targetContentOffset {
      setContentOffset(CGPoint(x: 0, y: contentSize.height / 2), animated: false)
    }

    let topVisibleY = bounds.minY
    let bottomVisibleY = bounds.maxY
    for case let tile as ScaleTile in subviews {
      let topY = tile.frame.minY
      let bottomY = tile.frame.maxY

      // Tile is above the visible screen
      if bottomY < topVisibleY {
        tile.frame = tile.frame.offsetBy(dx: 0, dy: CGFloat(subviews.count) * ScaleScrollView.TileHeight)
        tile.value = Float(tile.frame.origin.y / ScaleScrollView.TileHeight * CGFloat(unitsPerTile))
      }
      // Tile is below the visible screen
      else if topY > bottomVisibleY {
        tile.frame = tile.frame.offsetBy(dx: 0, dy: -CGFloat(subviews.count) * ScaleScrollView.TileHeight)
        tile.value = Float(tile.frame.origin.y / ScaleScrollView.TileHeight * CGFloat(unitsPerTile))
      }
    }
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
