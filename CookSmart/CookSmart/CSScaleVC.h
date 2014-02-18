//
//  CSScaleVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/14/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSIngredient;

@interface CSScaleVC : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) CSIngredient* currIngredient;

- (NSInteger)weightValue;
- (NSInteger)volumeValue;
@end
