//
//  CSUnitPicker.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/25/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSScaleVCInternals.h"

@class CSUnitPicker;
@class CSVolumeUnit;
@class CSWeightUnit;
@protocol CSUnitPickerDelegate <NSObject>
- (void)unitPicker:(CSUnitPicker*)unitPicker pickedVolumeUnit:(CSVolumeUnit*)volumeUnit andWeightUnit:(CSWeightUnit*)weightUnit;
@end

@interface CSUnitPicker : UIControl <UIScrollViewDelegate>

- (id)initWithVolumeUnit:(CSVolumeUnit*)volUnit andWeightUnit:(CSWeightUnit*)weightUnit;

@property (weak, nonatomic) id <CSUnitPickerDelegate> delegate;
@property (nonatomic, assign) CSScaleVCArrangement arrangement;

@end
