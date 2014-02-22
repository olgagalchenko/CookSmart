//
//  CSEditIngredientVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 2/18/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSScaleVC.h"
@class CSIngredient;

typedef void(^BlockType)(CSIngredient*);

@interface CSEditIngredientVC : UIViewController <UITextFieldDelegate, CSScaleVCDelegate>

- (id)initWithIngredient:(CSIngredient*)ingr withDoneBlock:(BlockType)done;

@end
