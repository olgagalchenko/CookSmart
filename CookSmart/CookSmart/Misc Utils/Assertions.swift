//
//  Assertions.swift
//  cake
//
//  Created by Vova Galchenko on 11/25/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

func assertAndLogOnFailure(
  _ assertion: Bool,
  _ message: @autoclosure () -> String,
  file: StaticString = #file,
  line: UInt = #line
) {
  guard assertion else {
    logAndFailAssertion(message(), file: file, line: line)
  }
}

func logAndFailAssertion(
  _ message: @autoclosure () -> String,
  _ error: Error? = nil,
  file: StaticString = #file,
  line: UInt = #line
) -> Never {
  logIssue("assert_fail", [
    "src_location": "\(file):\(line)",
    "assert_msg": message(),
    "error_description": error?.localizedDescription ?? "none",
  ])
  preconditionFailure(message(), file: file, line: line)
}
