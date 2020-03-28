//
//  ScaleTile.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftUI
import UIKit

class ScaleTile: UIView {
  
  // MARK: Lifecycle
  
  init(frame: CGRect, mirror: Bool = false) {
    self.mirror = mirror
    super.init(frame: frame)
    
    setUpViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  var value: Double {
    get { Double(valueLabel.text ?? "") ?? 0 }
    set {
      valueLabel.text = String(format:"%1.0f", newValue)
    }
  }
  
  // MARK: Private
  
  let valueLabel: UILabel = UILabel()
  let mirror: Bool
  
  private func setUpViews() {
    self.backgroundColor = UIColor.clear
    addSubview(valueLabel)
    valueLabel.translatesAutoresizingMaskIntoConstraints = false
    valueLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    if mirror {
      ctx.translateBy(x: self.bounds.size.width/2, y: 0)
      ctx.scaleBy(x: -1, y: 1);
      ctx.translateBy(x: -self.bounds.size.width/2, y: 0);
    }
    
    ctx.setStrokeColor(UIColor.darkGray.cgColor)
    drawEigths(ctx)
    drawQuarters(ctx)
    drawWhole(ctx)
    ctx.setStrokeColor(UIColor.lightGray.cgColor)
    drawThirds(ctx)
    drawSixths(ctx)
  }
  
  private func drawEigths(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 8, to: self.bounds.size.height, by: bounds.size.height / 4) {
      let from = CGPoint(x: bounds.size.width, y: y)
      let to = CGPoint(x: bounds.size.width - 15, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }
  
  private func drawQuarters(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 4, to: self.bounds.size.height, by: bounds.size.height / 4) {
      let from = CGPoint(x: bounds.size.width, y: y)
      let to = CGPoint(x: bounds.size.width - 30, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }
  
  private func drawThirds(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 3, to: self.bounds.size.height, by: bounds.size.height / 3) {
      let from = CGPoint(x: 0, y: y)
      let to = CGPoint(x: 15, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }
  
  private func drawSixths(_ ctx: CGContext) {
    for y in stride(from: bounds.size.height / 6, to: bounds.size.height, by: bounds.size.height / 3) {
      let from = CGPoint(x: 0, y: y)
      let to = CGPoint(x: 30, y: y)
      ctx.addLines(between: [from, to])
    }
    ctx.strokePath()
  }
  
  private func drawWhole(_ ctx: CGContext) {
    let leadingFrom = CGPoint(x: 0, y: 0)
    let leadingTo = CGPoint(x: 40, y: 0)
    ctx.addLines(between: [leadingFrom, leadingTo])
    ctx.strokePath()
    
    let trailingFrom = CGPoint(x: bounds.size.width, y: 0)
    let trailingTo = CGPoint(x: bounds.size.width - 40, y: 0)
    ctx.addLines(between: [trailingFrom, trailingTo])
    ctx.strokePath()
  }
}

struct ScaleTilePreview: PreviewProvider {
  
  static var previews: some View {
    TilePreviewContainer()
      .frame(width: UIScreen.main.bounds.width, height: 200)
  }
  
  struct TilePreviewContainer: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) -> UIView {
      let tile = ScaleTile(frame: CGRect.zero)
      tile.value = 6
      return tile
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) {
    }
    
    typealias UIViewType = UIView
  }
}
