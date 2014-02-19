//
//  CSEditIngredientVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/18/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSIngredient;

@interface CSEditIngredientVC : UIViewController <UITextFieldDelegate>

- (id)initWithIngredient:(CSIngredient*)ingr;
@end
