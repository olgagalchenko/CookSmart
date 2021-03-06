//
//  CSScaleView.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/24/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSScaleView;

@protocol CSScaleViewDelegate <UIScrollViewDelegate>

- (void)scaleViewTapped:(CSScaleView *)scaleView;
- (BOOL)isSnapping;

@end

@interface CSScaleView : UIScrollView <UIGestureRecognizerDelegate>

- (void)configureScaleViewWithInitialCenterValue:(float)centerValue
                                           scale:(NSUInteger)unitsPerTile
                                          mirror:(BOOL)mirror;
- (float)getCenterValue;
- (void)setCenterValue:(float)newCenterValue cancelDeceleration:(BOOL)cancelDeceleration;

@end
