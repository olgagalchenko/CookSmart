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

  @Published private(set) var unitValue: CGFloat = 1

  var unitText: AnyPublisher<String?, Never> {
    publisher(for: \.contentOffset)
      .map { _ in
        Double(self.virtualContentYOffset * self.unitsPerPoint).vulgarFractionString
      }
      .eraseToAnyPublisher()
  }

  init(unitsPerTile: Int = 1,
       mirror: Bool = false) {
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

  var unitsPerTile: Int {
    didSet {
      assert(unitsPerTile > 0, "Units per tile must be greater than zero")
      pointsPerUnit = ScaleScrollView.TileHeight / CGFloat(unitsPerTile)
      unitsPerPoint = 1 / pointsPerUnit
    }
  }

  // MARK: Private

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

    syncToUnitValue(unitValue)
  }

  func syncToUnitValue(_ unitValue: CGFloat) {
    delegate = nil
    setContentOffset(CGPoint(x: 0, y: pointsPerUnit * unitValue - accumulatedOffset), animated: false)
    delegate = self
  }

  private func updateCenterValue(_ newCenterValue: CGFloat, notifyDelegate: Bool = false, animated: Bool = false) {
    if !notifyDelegate { delegate = nil }
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
    delegate = self
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let newYOffset = getNewYOffset()
    if yOffset != newYOffset {
      let yOffsetDelta = yOffset - newYOffset
      delegate = nil
      contentOffset = CGPoint(x: 0, y: newYOffset)
      delegate = self
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

  private func snapToHumanReadableValue() {
    let humanReadableValue = CGFloat(Double(unitValue).roundedValue)
    updateCenterValue(humanReadableValue, notifyDelegate: true, animated: true)
  }
}

// MARK: UIScrollViewDelegate

extension ScaleScrollView: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    unitValue = virtualContentYOffset * unitsPerPoint
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else {
      return
    }
    snapToHumanReadableValue()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    snapToHumanReadableValue()
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
        unitsPerTile: unitsPerTile,
        mirror: mirror
      )
    }

    func updateUIView(_: UIViewType, context _: UIViewRepresentableContext<ScalePreview.ScalePreviewContainer>) {}

    typealias UIViewType = UIView
  }
}
