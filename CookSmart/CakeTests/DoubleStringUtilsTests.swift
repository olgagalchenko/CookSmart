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
  // MARK: humanReadableValue

  func test_humanReadableValue_aboveThreshold_roundsDown() {
    let rawValue = 66.445
    let result = rawValue.humanReadableValue
    XCTAssertEqual(result, 66)
  }

  func test_humanReadableValue_aboveThreshhold_roundsUp() {
    let rawValue = 104.849998
    let result = rawValue.humanReadableValue
    XCTAssertEqual(result, 105)
  }

  func test_humanReadableValue_belowThreshold() {
    let rawValue = 49.45
    let result = rawValue.humanReadableValue
    XCTAssertEqual(result, 49.45)
  }

  // MARK: humanReadableString

  func test_humanReadableString_aboveThreshold() {
    let rawValue = 66.445
    let result = rawValue.humanReadableString
    XCTAssertEqual(result, "66")
  }
}
