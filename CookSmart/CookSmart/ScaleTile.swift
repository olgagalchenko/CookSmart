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

@objc
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

  @objc
  init(frame: CGRect, mirror: Bool = false) {
    self.mirror = mirror
    super.init(frame: frame)

    setUpViews()
  }

  required init?(coder _: NSCoder) {
    fatalError()
  }

  // MARK: Public

  @objc
  public var value: Float {
    get { Float(valueLabel.text ?? "") ?? 0 }
    set {
      guard newValue >= 0 else {
        valueLabel.text = ""
        return
      }
      valueLabel.text = String(format: "%1.0f", newValue)
    }
  }

  override func draw(_: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    if mirror {
      ctx.translateBy(x: bounds.size.width / 2, y: 0)
      ctx.scaleBy(x: -1, y: 1)
      ctx.translateBy(x: -bounds.size.width / 2, y: 0)
    }

    ctx.setLineWidth(LineWidth.minor_1)
    ctx.setStrokeColor(UIColor.systemGray.cgColor)
    drawEighths(ctx)
    drawQuarters(ctx)
    ctx.setStrokeColor(UIColor.systemGray3.cgColor)
    drawThirds(ctx)
    drawSixths(ctx)

    drawWhole(ctx)
    ctx.translateBy(x: 0, y: bounds.size.height / 2)
    ctx.scaleBy(x: 1, y: -1)
    ctx.translateBy(x: 0, y: -bounds.size.height / 2)
    drawWhole(ctx)
  }

  // MARK: Private

  let valueLabel: UILabel = UILabel()
  let mirror: Bool

  private func setUpViews() {
    backgroundColor = UIColor.clear
    setUpLabel()
  }

  private func setUpLabel() {
    addSubview(valueLabel)
    valueLabel.font = Fonts.tiny
    valueLabel.translatesAutoresizingMaskIntoConstraints = false
    if mirror {
      valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Length.medium_30 / 2).isActive = true
    } else {
      valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Length.small_15).isActive = true
    }
    valueLabel.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
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

    ctx.setStrokeColor(UIColor.systemGray3.cgColor)
    let leadingFrom = CGPoint(x: 0, y: halfWidth / 2)
    let leadingTo = CGPoint(x: Length.large_40, y: halfWidth / 2)
    ctx.addLines(between: [leadingFrom, leadingTo])
    ctx.strokePath()

    ctx.setStrokeColor(UIColor.systemGray.cgColor)
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
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            TilePreviewContainer(value: 5, mirror: false)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
            TilePreviewContainer(value: 600, mirror: false)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
          }
          VStack(spacing: 0) {
            TilePreviewContainer(value: 5, mirror: true)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
            TilePreviewContainer(value: 600, mirror: true)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
          }
        }
      }
      .environment(\.colorScheme, .light)

      NavigationView {
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            TilePreviewContainer(value: 5, mirror: false)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
            TilePreviewContainer(value: 600, mirror: false)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
          }
          VStack(spacing: 0) {
            TilePreviewContainer(value: 5, mirror: true)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
            TilePreviewContainer(value: 600, mirror: true)
              .frame(width: UIScreen.main.bounds.width / 2, height: 200)
          }
        }
      }
      .environment(\.colorScheme, .dark)
    }
  }

  struct TilePreviewContainer: UIViewRepresentable {
    init(value: Float, mirror: Bool) {
      self.value = value
      self.mirror = mirror
    }

    let value: Float
    let mirror: Bool

    func makeUIView(context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) -> UIView {
      let tile = ScaleTile(frame: CGRect.zero, mirror: mirror)
      tile.value = value
      return tile
    }

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) {}

    typealias UIViewType = UIView
  }
}
