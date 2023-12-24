//
//  CSTextStyle.swift
//  cake
//
//  Created by Vova Galchenko on 12/3/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Enforce at build time that no text styling is done outside of CSTextStyle
struct CSTextStyle {
  let font: UIFont
  let color: CSColor
  let backgroundColor: CSColor

  init(font: UIFont, color: CSColor, backgroundColor: CSColor = .clear) {
    self.font = font
    self.color = color
    self.backgroundColor = backgroundColor
  }

  static let heading = CSTextStyle(font: CSFont.heading, color: .contentText)
  static let subheading = CSTextStyle(font: CSFont.subheading, color: .subheadingText)
  static let minorContent = CSTextStyle(font: CSFont.minorContent, color: .contentText)
  static let supportingContent = CSTextStyle(font: CSFont.supportingContent, color: .contentText)
  static let coreContent = CSTextStyle(font: CSFont.coreContent, color: .contentText)
  static let plainButton = CSTextStyle(font: CSFont.coreContent, color: .accent)
  static let actionButton = CSTextStyle(font: CSFont.emphasizedContent, color: .accent)
}

struct CSTextStyleViewModifier: ViewModifier {
  let csTextStyle: CSTextStyle

  func body(content: Content) -> some View {
    content
      .font(Font(csTextStyle.font))
      .foregroundStyle(csTextStyle.color.asSwiftUIColor())
      .backgroundStyle(csTextStyle.backgroundColor.asSwiftUIColor())
  }
}

extension Text {
  func csTextStyle(_ style: CSTextStyle) -> some View {
    modifier(CSTextStyleViewModifier(csTextStyle: style))
  }
}

extension Button {
  func csTextStyle(_ style: CSTextStyle) -> some View {
    modifier(CSTextStyleViewModifier(csTextStyle: style))
  }
}

extension UITextField {
  func applyTextStyle(_ textStyle: CSTextStyle) {
    font = textStyle.font
    textColor = textStyle.color.asUIColor()
  }
}

extension UIButton {
  convenience init(style: CSTextStyle) {
    self.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    applyTextStyle(style)
  }

  func applyTextStyle(_ style: CSTextStyle) {
    setTitleColor(style.color.asUIColor(), for: .normal)
    titleLabel?.font = style.font
  }
}

extension UILabel {
  convenience init(style: CSTextStyle) {
    self.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    applyStyle(style)
  }

  func applyStyle(_ style: CSTextStyle) {
    textColor = style.color.asUIColor()
    font = style.font
  }
}

private enum CSFont {
  // TODO: We should be using UIFontMetrics to automatically scale fonts depending on user settings
  static let heading = AvenirFont.demiBold.of(size: 20)
  static let subheading = AvenirFont.demiBold.of(size: 15)
  static let minorContent = AvenirFont.condensedMedium.of(size: 12)
  static let supportingContent = AvenirFont.regular.of(size: 15)
  static let coreContent = AvenirFont.regular.of(size: 17)
  static let emphasizedContent = AvenirFont.demiBold.of(size: 17)
}

private enum AvenirFont: String {
  case condensedMedium = "AvenirNextCondensed-Medium"
  case regular = "AvenirNext-Regular"
  case medium = "AvenirNext-Medium"
  case demiBold = "AvenirNext-DemiBold"

  public func of(size: CGFloat) -> UIFont {
    UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
  }
}
