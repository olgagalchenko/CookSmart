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

    override func draw(_: CGRect) {}
}

struct ScaleTilePreview: PreviewProvider {
    static var previews: some View {
        TilePreviewContainer()
    }

    struct TilePreviewContainer: UIViewRepresentable {
        func makeUIView(context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) -> UIView {
            ScaleTile(frame: CGRect.zero, mirror: true)
        }

        func updateUIView(_: UIView, context _: UIViewRepresentableContext<ScaleTilePreview.TilePreviewContainer>) {}

        typealias UIViewType = UIView
    }
}
