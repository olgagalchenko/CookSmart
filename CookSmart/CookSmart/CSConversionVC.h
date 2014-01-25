//
//  CSConversionVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSIngredientListVC.h"
#import "CSScaleView.h"

@class CSIngredientGroup;

@interface CSConversionVC : UIViewController <CSIngredientListVCDelegate, CSScaleViewDelegate>

- (id)initWithIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)ingredientIndex;

@end
