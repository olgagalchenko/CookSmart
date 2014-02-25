//
//  CSScaleVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/14/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSScaleVC;
@protocol CSScaleVCDelegate <NSObject>
@optional
- (void)scaleVC:(CSScaleVC *)scaleVC densityDidChange:(float)changedDensity;
- (void)scaleVC:(CSScaleVC *)scaleVC didBeginChangingUnits:(BOOL)begin;
- (void)scaleVC:(CSScaleVC *)scaleVC didFinishChangingUnits:(BOOL)finish;
@end

@class CSIngredient;

@interface CSScaleVC : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) CSIngredient*         ingredient;
@property (assign, nonatomic) BOOL                  syncsScales;
@property (weak, nonatomic) id<CSScaleVCDelegate>   delegate;
- (NSDictionary *)analyticsAttributes;

@end
