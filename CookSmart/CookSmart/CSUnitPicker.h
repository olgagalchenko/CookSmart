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
@class CSUnit;
@protocol CSUnitPickerDelegate <NSObject>
- (void)unitPicker:(CSUnitPicker*)unitPicker pickedVolumeUnit:(CSUnit*)volumeUnit andWeightUnit:(CSUnit*)weightUnit;
@end

@interface CSUnitPicker : UIControl <UIScrollViewDelegate>

+ (CSUnitPicker *)unitPickerWithCurrentVolumeUnit:(CSUnit*)volUnit andWeightUnit:(CSUnit*)weightUnit;

@property (weak, nonatomic) id <CSUnitPickerDelegate> delegate;
@property (nonatomic, assign) CSScaleVCArrangement arrangement;

@end
