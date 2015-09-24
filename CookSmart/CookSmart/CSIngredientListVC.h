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

@interface CSIngredientListVC : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>

- (id)initWithDelegate:(id<CSIngredientListVCDelegate>)delegate;
- (void)detailButtonTapped:(id)sender;

@end

@protocol CSIngredientListVCDelegate <NSObject>

- (void)ingredientListVC:(CSIngredientListVC *)listVC
 selectedIngredientGroup:(NSUInteger)ingredientGroupIndex
         ingredientIndex:(NSUInteger)index;

@end