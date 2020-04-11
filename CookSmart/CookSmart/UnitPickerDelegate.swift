//
//  UnitPickerDelegate.swift
//  cake
//
//  Created by Alex King on 4/5/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation

@objc
protocol UnitPickerDelegate: AnyObject {
  @objc(pickedVolumeUnit:weightUnit:) func picked(volumeUnit: CSUnit, weightUnit: CSUnit)
}
