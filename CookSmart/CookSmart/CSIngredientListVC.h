//
//  CSIngredientListVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSIngredientGroup;
@protocol CSIngredientListVCDelegate;

@interface CSIngredientListVC : UITableViewController

- (id)initWithDelegate:(id<CSIngredientListVCDelegate>)delegate;

@end

@protocol CSIngredientListVCDelegate <NSObject>

- (void)ingredientListVC:(CSIngredientListVC *)listVC
 selectedIngredientGroup:(CSIngredientGroup *)ingredientGroup
         ingredientIndex:(NSUInteger)index;

@end