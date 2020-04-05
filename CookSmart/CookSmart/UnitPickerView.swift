//
//  UnitPickerView.swift
//  cake
//
//  Created by Alex King on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

class UnitPickerViewController: UIViewController {
  private enum Constants {
    static let doneButtonHeight: CGFloat = 44.0
  }

  private var volumeUnit: CSUnit
  private var weightUnit: CSUnit

  init(volumeUnit: CSUnit, weightUnit: CSUnit) {
    self.volumeUnit = volumeUnit
    self.weightUnit = weightUnit
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  private let volumeScrollView = UnitPickerScrollView(title: "Volume", units: CSUnitCollection.volumeUnits())
  private let weightScrollView = UnitPickerScrollView(title: "Weight", units: CSUnitCollection.weightUnits())

  private let doneButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(Color.redLineColor, for: .normal)
    button.setTitle("Done", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    return button
  }()

  private func setupViews() {
    title = "Choose Units"
    view.backgroundColor = .systemBackground

    view.addSubview(doneButton)
    doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight).isActive = true

    view.addSubview(volumeScrollView)
    volumeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    volumeScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    volumeScrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor).isActive = true

    view.addSubview(weightScrollView)
    weightScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    weightScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    weightScrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor).isActive = true

    volumeScrollView.trailingAnchor.constraint(equalTo: weightScrollView.leadingAnchor).isActive = true
    volumeScrollView.widthAnchor.constraint(equalTo: weightScrollView.widthAnchor).isActive = true
  }

  @objc
  private func doneButtonPressed() {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}

private class UnitPickerScrollView: UIView {
  init(title: String, units: CSUnitCollection) {
    super.init(frame: .zero)
    setupViews()
    addUnitLabels(unitCollection: units)
    titleLabel.text = title
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.scrollsToTop = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    scrollView.alwaysBounceHorizontal = false
    return scrollView
  }()

  private let unitStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    return stackView
  }()

  private let topGradientView = GradientView(startColor: .systemBackground, endColor: .clear)

  private var unitStackViewTopConstraint: NSLayoutConstraint?
  private var unitStackViewBottomConstraint: NSLayoutConstraint?

  override func layoutSubviews() {
    super.layoutSubviews()

    let scrollViewHeight = scrollView.frame.height
    unitStackViewTopConstraint?.constant = scrollViewHeight / 2
    unitStackViewBottomConstraint?.constant = -(scrollViewHeight / 2)
  }

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false

    addSubview(scrollView)
    scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    scrollView.addSubview(unitStackView)
    unitStackViewTopConstraint = unitStackView.topAnchor.constraint(equalTo: scrollView.topAnchor)
    unitStackViewTopConstraint?.isActive = true
    unitStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    unitStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    unitStackViewBottomConstraint = unitStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    unitStackViewBottomConstraint?.isActive = true
    unitStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

    addSubview(topGradientView)
    topGradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    topGradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    topGradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    topGradientView.isHidden = true

    addSubview(titleLabel)
    titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
    titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    topGradientView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 2.0).isActive = true
    scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
  }

  private func addUnitLabels(unitCollection: CSUnitCollection) {
    unitCollection.units
      .compactMap { $0 as? CSUnit }
      .forEach { unit in
        print(unit.name ?? "")
        let unitLabel = UILabel()
        unitLabel.text = unit.name
        unitStackView.addArrangedSubview(unitLabel)
      }
  }
}

extension UnitPickerScrollView: UIScrollViewDelegate {}
