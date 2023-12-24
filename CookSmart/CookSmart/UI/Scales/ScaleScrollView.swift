//
//  ScaleScrollView.swift
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

  @Published private(set) var unitValue: CGFloat

  private let stableUnitValueSubject = PassthroughSubject<Float, Never>()
  let stableUnitValuePublisher: AnyPublisher<Float, Never>

  init(unitsPerTile: Int = 1, mirror: Bool = false) {
    self.unitsPerTile = unitsPerTile
    self.mirror = mirror

    pointsPerUnit = ScaleScrollView.TileHeight / CGFloat(unitsPerTile)
    unitsPerPoint = 1 / pointsPerUnit

    unitValue = 1

    stableUnitValuePublisher = stableUnitValueSubject.eraseToAnyPublisher()

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
        createTiles()
      }
    }
  }

  var unitsPerTile: Int {
    didSet {
      assert(unitsPerTile > 0, "Units per tile must be greater than zero")
      pointsPerUnit = ScaleScrollView.TileHeight / CGFloat(unitsPerTile)
      unitsPerPoint = 1 / pointsPerUnit
    }
  }

  override var contentOffset: CGPoint {
    didSet {
      unitValue = virtualContentYOffset * unitsPerPoint
    }
  }

  // MARK: Private

  private let mirror: Bool
  private let tileContainer = UIView()

  private var unitsPerPoint: CGFloat
  private var pointsPerUnit: CGFloat
  private var accumulatedOffset: CGFloat = 0 {
    didSet {
      unitValue = virtualContentYOffset * unitsPerPoint
    }
  }

  private func setUpViews() {
    translatesAutoresizingMaskIntoConstraints = false
    setUpScrollView()

    addSubview(tileContainer)

    createTiles()
  }

  private func setUpScrollView() {
    backgroundColor = CSColor.background.asUIColor()
    bounces = false
    isPagingEnabled = false
    alwaysBounceVertical = false
    alwaysBounceHorizontal = false
    bouncesZoom = false
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false

    delegate = self
  }

  private func createTiles() {
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
    unitValue = virtualContentYOffset * unitsPerPoint

    setNeedsLayout()
  }

  func syncTo(unitValue: CGFloat) {
    contentOffset = CGPoint(x: 0, y: pointsPerUnit * unitValue - accumulatedOffset)
    stableUnitValueSubject.send(Float(unitValue))
  }

  private func updateCenterValue(_ newCenterValue: CGFloat, animated: Bool = false) {
    let updateContentOffset = {
      self.contentOffset = CGPoint(x: 0, y: self.pointsPerUnit * newCenterValue - self.accumulatedOffset)
    }
    if animated {
      UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
        updateContentOffset()
      }.startAnimation()
    } else {
      updateContentOffset()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let newYOffset = getNewYOffset()
    if contentOffset.y != newYOffset {
      let yOffsetDelta = contentOffset.y - newYOffset
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

  private func handleScrollCompletion() {
    let roundedValue = CGFloat(Double(virtualContentYOffset * unitsPerPoint).roundedValue)
    updateCenterValue(roundedValue, animated: true)
    stableUnitValueSubject.send(Float(roundedValue))
  }
}

// MARK: UIScrollViewDelegate

extension ScaleScrollView: UIScrollViewDelegate {

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else {
      return
    }
    handleScrollCompletion()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    handleScrollCompletion()
  }

  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    false
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

  private func getNewYOffset() -> CGFloat {
    let maxYOffset = targetContentYOffset + bounds.size.height
    let minYOffset = targetContentYOffset - bounds.size.height
    if contentOffset.y > maxYOffset || (contentOffset.y < minYOffset && accumulatedOffset > 0) {
      return min(targetContentYOffset, contentOffset.y + accumulatedOffset)
    }
    return contentOffset.y
  }
}
