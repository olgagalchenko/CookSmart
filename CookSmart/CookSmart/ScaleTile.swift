//
//  ScaleTile.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import CoreGraphics
import Foundation
import SwiftUI
import UIKit

class ScaleTile: UIView {
  private enum Length {
    static let small_15: CGFloat = 15
    static let medium_30: CGFloat = 30
    static let large_40: CGFloat = 40
  }

  private enum LineWidth {
    static let minor_1: CGFloat = 1
    static let major_2: CGFloat = 2
  }

  // MARK: Lifecycle

  init(frame: CGRect, mirror: Bool = false) {
    self.mirror = mirror
    super.init(frame: frame)

    setUpViews()
  }

  required init?(coder _: NSCoder) {
    fatalError()
  }

  var value: Double {
    get { Double(valueLabel.text ?? "") ?? 0 }
    set {
      valueLabel.text = String(format: "%1.0f", newValue)
    }
  }

  // MARK: Private

  let valueLabel: UILabel = UILabel()
  let mirror: Bool

  private func setUpViews() {
    backgroundColor = UIColor.clear
    addSubview(valueLabel)
    valueLabel.translatesAutoresizingMaskIntoConstraints = false
    valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  override func draw(_: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    if mirror {
      ctx.translateBy(x: bounds.size.width / 2, y: 0)
      ctx.scaleBy(x: -1, y: 1)
      ctx.translateBy(x: -bounds.size.width / 2, y: 0)
    }

    ctx.setLineWidth(LineWidth.minor_1)
    ctx.setStrokeColor(UIColor.darkGray.cgColor)
    drawEighths(ctx)
    drawQuarters(ctx)
    ctx.setStrokeColor(UIColor.lightGray.cgColor)
    drawThirds(ctx)
    drawSixths(ctx)

    drawWhole(ctx)
    ctx.translateBy(x: 0, y: bounds.size.height / 2)
    ctx.scaleBy(x: 1, y: -1)
    ctx.translateBy(x: 0, y: -bounds.size.height / 2)
    drawWhole(ctx)
  }

  private func drawEighths(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 8, to: bounds.size.height, by: bounds.size.height / 4) {
      let from = CGPoint(x: bounds.size.width, y: y)
      let to = CGPoint(x: bounds.size.width - Length.small_15, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }

  private func drawQuarters(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 4, to: bounds.size.height, by: bounds.size.height / 4) {
      let from = CGPoint(x: bounds.size.width, y: y)
      let to = CGPoint(x: bounds.size.width - Length.medium_30, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }

  private func drawThirds(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 3, to: bounds.size.height, by: bounds.size.height / 3) {
      let from = CGPoint(x: 0, y: y)
      let to = CGPoint(x: Length.small_15, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }

  private func drawSixths(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 6, to: bounds.size.height, by: bounds.size.height / 3) {
      let from = CGPoint(x: 0, y: y)
      let to = CGPoint(x: Length.medium_30, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }

  private func drawWhole(_ ctx: CGContext) {
    let halfWidth = LineWidth.major_2 / 2
    ctx.setLineWidth(halfWidth)

    ctx.setStrokeColor(UIColor.lightGray.cgColor)
    let leadingFrom = CGPoint(x: 0, y: halfWidth / 2)
    let leadingTo = CGPoint(x: Length.large_40, y: halfWidth / 2)
    ctx.addLines(between: [leadingFrom, leadingTo])
    ctx.strokePath()

    ctx.setStrokeColor(UIColor.darkGray.cgColor)
    let trailingFrom = CGPoint(x: bounds.size.width, y: halfWidth / 2)
    let trailingTo = CGPoint(x: bounds.size.width - Length.large_40, y: halfWidth / 2)
    ctx.addLines(between: [trailingFrom, trailingTo])
    ctx.strokePath()
  }
}

struct ScaleTilePreview: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationView {
        VStack(spacing: 0) {
          TilePreviewContainer()
            .frame(width: UIScreen.main.bounds.width, height: 200)
          TilePreviewContainer()
            .frame(width: UIScreen.main.bounds.width, height: 200)
        }
      }
      .environment(\.colorScheme, .light)
      NavigationView {
        VStack(spacing: 0) {
          TilePreviewContainer()
            .frame(width: UIScreen.main.bounds.width, height: 200)
          TilePreviewContainer()
            .frame(width: UIScreen.main.bounds.width, height: 200)
        }
      }
      .environment(\.colorScheme, .dark)
    }
  }

  struct TilePreviewContainer: UIViewRepresentable {
    func makeUIView(context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) -> UIView {
      let tile = ScaleTile(frame: CGRect.zero)
      tile.value = 6
      return tile
    }

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) {}

    typealias UIViewType = UIView
  }
}
