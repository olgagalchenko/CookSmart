//
//  CSScaleVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/14/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSUnitPicker.h"

@class CSScaleVC;
@protocol CSScaleVCDelegate <NSObject>
@optional
- (void)scaleVCDidBeginChangingUnits:(CSScaleVC*)scaleVC;
- (void)scaleVCDidFinishChangingUnits:(CSScaleVC*)scaleVC;
- (void)scaleVC:(CSScaleVC *)scaleVC densityDidChange:(float)changedDensity;
- (void)scaleVCWillBeginHandlingInteraction:(CSScaleVC*)scaleVC;
@end

@class CSIngredient;
@interface CSScaleVC : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, CSUnitPickerDelegate>

@property (strong, nonatomic) CSIngredient*         ingredient;
@property (assign, nonatomic) BOOL                  syncsScales;
@property (weak, nonatomic) id<CSScaleVCDelegate>   delegate;

@property (strong, nonatomic) CSUnit* currentWeightUnit;
@property (strong, nonatomic) CSUnit* currentVolumeUnit;

- (NSDictionary *)analyticsAttributes;
- (void)setScalesAlpha:(CGFloat)newScaleViewAlpha;
@end
