//
//  ConversionViewController.swift
//  cake
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

class ConversionViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  private lazy var scaleViewController = CSScaleVC(nibName: "CSScaleVC", bundle: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    addChild(scaleViewController)
    view.addSubview(scaleViewController.view)
    scaleViewController.view.translatesAutoresizingMaskIntoConstraints = false
    scaleViewController.delegate = self
  }

  private func setupViews() {
    
  }
}

extension ConversionViewController: CSScaleVCDelegate {

}
