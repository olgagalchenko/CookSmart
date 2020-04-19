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

  private let volumeScrollView: UnitPickerScrollView
  private let weightScrollView: UnitPickerScrollView

  @objc
  public weak var delegate: UnitPickerDelegate?

  @objc
  init(volumeUnit: CSUnit, weightUnit: CSUnit) {
    volumeScrollView = UnitPickerScrollView(units: CSUnitCollection.volumeUnits(),
                                            selectedUnit: volumeUnit)
    weightScrollView = UnitPickerScrollView(units: CSUnitCollection.weightUnits(),
                                            selectedUnit: weightUnit)
    super.init(frame: .zero)
    setupViews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let doneButton: UIButton = {
    let button = Button()
    button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    return button
  }()

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false

    addSubview(volumeScrollView)
    volumeScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    volumeScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    volumeScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    addSubview(weightScrollView)
    weightScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    weightScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    weightScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    volumeScrollView.trailingAnchor.constraint(equalTo: centerXAnchor).isActive = true
    weightScrollView.leadingAnchor.constraint(equalTo: centerXAnchor).isActive = true

    addSubview(doneButton)
    doneButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    doneButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight).isActive = true
  }

  @objc
  private func doneButtonPressed() {
    delegate?.picked(volumeUnit: volumeScrollView.currentlySelectedUnit,
                     weightUnit: weightScrollView.currentlySelectedUnit)
  }
}

// MARK: - UnitPickerScrollView

private class UnitPickerScrollView: UIView {
  private enum Constants {
    static let unitLabelHeight: CGFloat = 40
  }

  private let unitCollection: CSUnitCollection
  private var selectedIndex: UInt

  var currentlySelectedUnit: CSUnit {
    unitCollection.unit(at: selectedIndex)
  }

  init(units: CSUnitCollection, selectedUnit: CSUnit) {
    unitCollection = units
    selectedIndex = unitCollection.index(of: selectedUnit)
    super.init(frame: .zero)
    setupViews()
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

    let halfScrollViewHeight = scrollView.frame.height / 2
    let halfUnitLabelHeight = Constants.unitLabelHeight / 2
    unitStackViewTopConstraint?.constant = halfScrollViewHeight - halfUnitLabelHeight
    unitStackViewBottomConstraint?.constant = -(halfScrollViewHeight - (halfUnitLabelHeight * 3))

    let selectedIndexOffset = Constants.unitLabelHeight * CGFloat(selectedIndex)
    scrollView.contentOffset = CGPoint(x: 0, y: selectedIndexOffset)
  }

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false
    scrollView.delegate = self

    addSubview(scrollView)
    scrollView.constrainToSuperview()

    scrollView.addSubview(unitStackView)
    unitStackView.constrainToSuperview(anchors: [.leading, .trailing, .width])
    unitStackViewTopConstraint = unitStackView.topAnchor.constraint(equalTo: scrollView.topAnchor)
    unitStackViewTopConstraint?.isActive = true
    unitStackViewBottomConstraint = unitStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    unitStackViewBottomConstraint?.isActive = true

    addSubview(centerLineView)
    centerLineView.constrainToSuperview(anchors: [.centerY, .leading, .trailing])

    addUnitLabels()
  }

  private func addUnitLabels() {
    unitCollection.units
      .compactMap { $0 as? CSUnit }
      .forEach { unit in
        let unitLabel = UILabel()
        unitLabel.font = AvenirFont.regular.of(size: 15)
        unitLabel.textColor = .label
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.heightAnchor.constraint(equalToConstant: Constants.unitLabelHeight).isActive = true
        unitLabel.text = unit.name
        unitStackView.addArrangedSubview(unitLabel)
      }
  }

  private func updateSelectedIndex() {
    selectedIndex = UInt(round(scrollView.contentOffset.y / Constants.unitLabelHeight))
  }

  private func scrollToNearestLabel() {
    updateSelectedIndex()
    let yOffset = CGFloat(selectedIndex) * Constants.unitLabelHeight
    scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
  }
}

// MARK: UIScrollViewDelegate

extension UnitPickerScrollView: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollToNearestLabel()
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else { return }
    scrollToNearestLabel()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}
