//
//  ScaleView.swift
//  cake
//
//  Created by Olga Galchenko on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UIKit

class ScaleScrollView: UIScrollView {
  static let TileHeight: CGFloat = 200

  @Published private(set) var unitValue: CGFloat = 0

  @objc
  init(centerValue: Double = 1,
       unitsPerTile: Int = 1,
       mirror: Bool = false) {
    self.centerValue = centerValue
    self.unitsPerTile = unitsPerTile
    self.mirror = mirror

    pointsPerUnit = ScaleScrollView.TileHeight / CGFloat(unitsPerTile)
    unitsPerPoint = 1 / pointsPerUnit

    super.init(frame: .zero)

    setUpViews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  override var bounds: CGRect {
    didSet {
      if bounds.size != oldValue.size {
        updateContentSize()
      }
    }
  }

  // MARK: Private

  private let centerValue: Double
  var unitsPerTile: Int {
    didSet {
      assert(unitsPerTile > 0, "Units per tile must be greater than zero")
      pointsPerUnit = ScaleScrollView.TileHeight / CGFloat(unitsPerTile)
      unitsPerPoint = 1 / pointsPerUnit
    }
  }

  private let mirror: Bool
  private let tileContainer = UIView()

  private var unitsPerPoint: CGFloat
  private var pointsPerUnit: CGFloat
  private var accumulatedOffset: CGFloat = 0

  private func setUpViews() {
    translatesAutoresizingMaskIntoConstraints = false
    setUpScrollView()

    addSubview(tileContainer)

    updateContentSize()
  }

  private func setUpScrollView() {
    backgroundColor = Color.background
    bounces = false
    isPagingEnabled = false
    alwaysBounceVertical = false
    alwaysBounceHorizontal = false
    bouncesZoom = false
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false

    delegate = self
  }

  private func updateContentSize() {
    contentSize = CGSize(width: bounds.size.width, height: bounds.size.height * 10)

    tileContainer.subviews.forEach { $0.removeFromSuperview() }

    var index = 0
    var actualCenter: CGFloat = 0
    for bottomTileY in stride(from: 0,
                              to: contentSize.height / 2,
                              by: ScaleScrollView.TileHeight) {
      let tile = ScaleTile(
        frame: CGRect(x: 0, y: bottomTileY, width: bounds.width, height: ScaleScrollView.TileHeight),
        mirror: mirror
      )

      tile.value = Float(unitsPerTile * index)
      tileContainer.addSubview(tile)
      if tile.frame.contains(CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)) {
        actualCenter = CGFloat(tile.value) + CGFloat(unitsPerPoint) * (bounds.size.height / 2 - tile.frame.origin.y)
      }
      index += 1
    }

    accumulatedOffset = actualCenter * pointsPerUnit

    setNeedsLayout()
    layoutIfNeeded()

    updateCenterValue(CGFloat(centerValue))
  }

  func updateCenterValue(_ newCenterValue: CGFloat) {
    contentOffset = CGPoint(x: 0, y: pointsPerUnit * newCenterValue - accumulatedOffset)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let newYOffset = getNewYOffset()
    if yOffset != newYOffset {
      let yOffsetDelta = yOffset - newYOffset
      contentOffset = CGPoint(x: 0, y: newYOffset)
      tileContainer.center = CGPoint(x: tileContainer.center.x, y: tileContainer.center.y - yOffsetDelta)
      accumulatedOffset += yOffsetDelta
    }

    updateTileFrames()
  }

  private func updateTileFrames() {
    let visibleBounds = convert(bounds, to: tileContainer)
    let minVisibleY = visibleBounds.minY
    let maxVisibleY = visibleBounds.maxY

    for case let tile as ScaleTile in tileContainer.subviews {
      let tileMinY = tile.frame.minY
      let tileMaxY = tile.frame.maxY

      let totalTileHeight = CGFloat(tileContainer.subviews.count) * ScaleScrollView.TileHeight
      // Tile is above the visible screen
      if tileMinY > maxVisibleY {
        let visibleDelta = tileMinY - maxVisibleY
        let decreaseFactor = ceil(visibleDelta / totalTileHeight) * totalTileHeight
        tile.frame = tile.frame.offsetBy(dx: 0, dy: -decreaseFactor)
      }
      // Tile is below the visible screen
      else if tileMaxY < minVisibleY {
        let visibleDelta = minVisibleY - tileMaxY
        let increaseFactor = ceil(visibleDelta / totalTileHeight) * totalTileHeight
        tile.frame = tile.frame.offsetBy(dx: 0, dy: increaseFactor)
      }

      tile.value = Float(tile.frame.origin.y * unitsPerPoint)
    }
  }
}

// MARK: UIScrollViewDelegate

extension ScaleScrollView: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    unitValue = virtualContentYOffset * unitsPerPoint
  }
}

// MARK: Helpers

private extension ScaleScrollView {
  private var targetContentYOffset: CGFloat {
    (contentSize.height - bounds.size.height) / 2
  }

  private var virtualContentYOffset: CGFloat {
    contentOffset.y + accumulatedOffset
  }

  private var yOffset: CGFloat {
    contentOffset.y
  }

  private func getNewYOffset() -> CGFloat {
    let maxYOffset = targetContentYOffset + bounds.size.height
    let minYOffset = targetContentYOffset - bounds.size.height
    if yOffset > maxYOffset || (yOffset < minYOffset && accumulatedOffset > 0) {
      return min(targetContentYOffset, yOffset + accumulatedOffset)
    }
    return yOffset
  }
}

// MARK: - ScalePreview

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
        centerValue: 1,
        unitsPerTile: unitsPerTile,
        mirror: mirror
      )
    }

    func updateUIView(_: UIViewType, context _: UIViewRepresentableContext<ScalePreview.ScalePreviewContainer>) {}

    typealias UIViewType = UIView
  }
}
