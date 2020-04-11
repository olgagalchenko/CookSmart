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
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_humanReadbleValue_aboveThreshold() throws {
    let value = 66.445
    let string = value.humanReadableValue
    XCTAssertEqual(string, "")
  }
}
