//
//  UIView+Constraints.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import UIKit

public extension UIView {
  /// Constrains the specified layout anchors of this view to another view.
  ///
  /// The anchors to constrain default to `.top`, `.bottom`, `.leading`, and `.trailing`.
  @discardableResult func constrain(
    to view: UIView,
    anchors: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing],
    priority: UILayoutPriority = .defaultHigh,
    shouldActivate: Bool = true
  ) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
    assert(
      !anchors.contains(.notAnAttribute),
      "It is not valid to set up a constraint between two attributes of type .notAnAttribute"
    )

    let initialValue = [NSLayoutConstraint.Attribute: NSLayoutConstraint]()
    let constraints = anchors.reduce(initialValue) { result, anchor in
      var result = result
      let constraint = NSLayoutConstraint(
        item: self,
        attribute: anchor.ignoringMargin(),
        relatedBy: .equal,
        toItem: view,
        attribute: anchor,
        multiplier: 1,
        constant: 0
      )
      constraint.priority = priority
      result[anchor] = constraint
      return result
    }

    if shouldActivate {
      constraints.setIsActive(true)
    }

    return constraints
  }

  /// Constrains the specified layout anchors of this view to its superview.
  ///
  /// The anchors to constrain default to `.top`, `.bottom`, `.leading`, and `.trailing`.
  @discardableResult func constrainToSuperview(
    anchors: Set<NSLayoutConstraint.Attribute> = [.top, .trailing, .bottom, .leading],
    priority: UILayoutPriority = .defaultHigh,
    shouldActivate: Bool = true
  ) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
    #if DEBUG
      assert(translatesAutoresizingMaskIntoConstraints == false, "Did you forget to disable translatesAutoresizingMaskIntoConstraints?")
    #endif

    guard let superview = superview else {
      assertionFailure("Did you forget to add the view to a superview?")
      return [:]
    }
    return constrain(
      to: superview,
      anchors: anchors,
      priority: priority,
      shouldActivate: shouldActivate
    )
  }

  /// Constrains the edges of this view to another view's layout margins.
  @discardableResult func constrainToMargins(
    of view: UIView,
    priority: UILayoutPriority = .defaultHigh,
    shouldActivate: Bool = true
  ) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
    constrain(
      to: view,
      anchors: [.topMargin, .bottomMargin, .leadingMargin, .trailingMargin],
      priority: priority,
      shouldActivate: shouldActivate
    )
  }

  /// Constrains the edges of this view to its superview's layout margins.
  @discardableResult func constrainToSuperviewMargins(
    priority: UILayoutPriority = .defaultHigh,
    shouldActivate: Bool = true
  ) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
    guard let superview = superview else {
      assertionFailure("Did you forget to add the view to a superview?")
      return [:]
    }
    return constrainToMargins(of: superview, priority: priority, shouldActivate: shouldActivate)
  }
}

// MARK: Dictionary

public extension Dictionary where Value == NSLayoutConstraint {
  /// Sets the `isActive` flag of all `NSLayoutConstraint`s in the `Dictionary`
  /// to the specified value.
  func setIsActive(_ isActive: Bool) {
    let constraints = Array(values)
    if isActive {
      NSLayoutConstraint.activate(constraints)
    } else {
      NSLayoutConstraint.deactivate(constraints)
    }
  }
}

// MARK: NSLayoutAttribute

private extension NSLayoutConstraint.Attribute {
  /// Returns a layout attribute ignoring margins
  func ignoringMargin() -> NSLayoutConstraint.Attribute {
    switch self {
    case .top:
      return self
    case .bottom:
      return self
    case .leading:
      return self
    case .trailing:
      return self
    case .left:
      return self
    case .right:
      return self
    case .width:
      return self
    case .height:
      return self
    case .centerX:
      return self
    case .centerY:
      return self
    case .firstBaseline:
      return self
    case .lastBaseline:
      return self
    case .topMargin:
      return .top
    case .bottomMargin:
      return .bottom
    case .leadingMargin:
      return .leading
    case .trailingMargin:
      return .trailing
    case .leftMargin:
      return .left
    case .rightMargin:
      return .right
    case .centerXWithinMargins:
      return .centerX
    case .centerYWithinMargins:
      return .centerY
    case .notAnAttribute:
      // Handle this case and the @unknown default case the same way.
      fallthrough
    @unknown default:
      return self
    }
  }
}
