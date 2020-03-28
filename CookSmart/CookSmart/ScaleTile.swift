//
//  ScaleTile.swift
//  cake
//
//  Created by Olga Galchenko on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class ScaleTile: UIView {
  
  // MARK: Lifecycle
  
  init(frame: CGRect, mirror: Bool) {
    self.mirror = mirror
    super.init(frame: frame)
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
  
  override func draw(_ rect: CGRect) {
    
  }
}

struct ScaleTilePreview: PreviewProvider {
  typealias Previews = ScaleTile
  
  static var previews: some View {
      Text("Hello Medium")
  }
}
