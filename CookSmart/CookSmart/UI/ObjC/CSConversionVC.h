//
//  CSConversionVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSScaleView.h"
#import "CSScaleVC.h"

@interface CSConversionVC : UIViewController <CSScaleVCDelegate, UIScrollViewDelegate>

- (id)initWithIngredientGroupIndex:(NSUInteger)ingredientGroupIndex ingredientIndex:(NSUInteger)ingredientIndex;

@end
