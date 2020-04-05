//
//  UnitPickerView.swift
//  cake
//
//  Created by Alex King on 4/4/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import UIKit

@objc
class UnitPickerView: UIView {
  private enum Constants {
    static let doneButtonHeight: CGFloat = 44.0
  }

  private var volumeUnit: CSUnit
  private var weightUnit: CSUnit

  @objc
  init(volumeUnit: CSUnit, weightUnit: CSUnit) {
    self.volumeUnit = volumeUnit
    self.weightUnit = weightUnit
    super.init(frame: .zero)
    setupViews()
  }

  @objc
  public weak var delegate: CSUnitPickerDelegate?

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let volumeScrollView = UnitPickerScrollView(units: CSUnitCollection.volumeUnits())
  private let weightScrollView = UnitPickerScrollView(units: CSUnitCollection.weightUnits())

  private let doneButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(Color.redLineColor, for: .normal)
    button.setTitle("Done", for: .normal)
    button.titleLabel?.font = Fonts.regular
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    return button
  }()

  private func setupViews() {
    backgroundColor = .systemBackground
    translatesAutoresizingMaskIntoConstraints = false

    addSubview(volumeScrollView)
    volumeScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    volumeScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    volumeScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    addSubview(weightScrollView)
    weightScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    weightScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    weightScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    volumeScrollView.trailingAnchor.constraint(equalTo: weightScrollView.leadingAnchor).isActive = true
    volumeScrollView.widthAnchor.constraint(equalTo: weightScrollView.widthAnchor).isActive = true

    addSubview(doneButton)
    doneButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    doneButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight).isActive = true
  }

  @objc
  private func doneButtonPressed() {
    delegate?.pickedVolumeUnit(volumeUnit, andWeightUnit: weightUnit)
  }
}

private class UnitPickerScrollView: UIView {
  private enum Constants {
    static let unitLabelHeight: CGFloat = 40
  }

  init(units: CSUnitCollection) {
    super.init(frame: .zero)
    setupViews()
    addUnitLabels(unitCollection: units)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
    return stackView
  }()

  private let centerLineView = UnitPickerCenterLineView()

  private var unitStackViewTopConstraint: NSLayoutConstraint?
  private var unitStackViewBottomConstraint: NSLayoutConstraint?

  override func layoutSubviews() {
    super.layoutSubviews()

    let scrollViewHeight = scrollView.frame.height
    unitStackViewTopConstraint?.constant = (scrollViewHeight / 2) - (Constants.unitLabelHeight / 2)
    unitStackViewBottomConstraint?.constant = -((scrollViewHeight / 2) - (Constants.unitLabelHeight * 3 / 2))
  }

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false
    scrollView.delegate = self

    addSubview(scrollView)
    scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true

    scrollView.addSubview(unitStackView)
    unitStackViewTopConstraint = unitStackView.topAnchor.constraint(equalTo: scrollView.topAnchor)
    unitStackViewTopConstraint?.isActive = true
    unitStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    unitStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    unitStackViewBottomConstraint = unitStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    unitStackViewBottomConstraint?.isActive = true
    unitStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

    addSubview(centerLineView)
    centerLineView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    centerLineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    centerLineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }

  private func addUnitLabels(unitCollection: CSUnitCollection) {
    unitCollection.units
      .compactMap { $0 as? CSUnit }
      .forEach { unit in
        let unitLabel = UILabel()
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.heightAnchor.constraint(equalToConstant: Constants.unitLabelHeight).isActive = true
        unitLabel.text = unit.name
        unitStackView.addArrangedSubview(unitLabel)
      }
  }
}

extension UnitPickerScrollView: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_: UIScrollView) {}

  func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {}
}
