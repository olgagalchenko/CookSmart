//
//  DoubleUtilsTests.swift
//  cake
//
//  Created by Olga Galchenko on 4/11/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

@testable import cake
import XCTest

class DoubleSringUtilsTests: XCTestCase {
  // MARK: roundedValue

  func test_roundedValue_aboveThreshold_roundsDown() {
    let rawValue = 66.445
    let result = rawValue.roundedValue
    XCTAssertEqual(result, 66)
  }

  func test_roundedValue_aboveThreshhold_roundsUp() {
    let rawValue = 104.849998
    let result = rawValue.roundedValue
    XCTAssertEqual(result, 105)
  }

  func test_roundedValue_belowThreshold_half() {
    let rawValue = 49.45
    let result = rawValue.roundedValue
    XCTAssertEqual(result, 49.500)
  }

  // MARK: vulgarFractionString

  func test_vulgarFractionString_aboveThreshold_roundsUp() {
    let rawValue = 66.7
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "67")
  }

  func test_vulgarFractionString_aboveThreshold_roundsDown() {
    let rawValue = 66.445
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "66")
  }

  func test_vulgarFractionString_aboveThreshold() {
    let rawValue = 66.445
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "66")
  }

  func test_vulgarFractionString_belowThreshold_half() {
    let rawValue = 49.45
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "49½")
  }

  func test_vulgarFractionString_belowThreshold_zero() {
    let rawValue = 0.05
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "0")
  }

  func test_vulgarFractionString_belowThreshold_eighth() {
    let rawValue = 0.1
    let result = rawValue.vulgarFractionString
    XCTAssertEqual(result, "⅛")
  }
}
