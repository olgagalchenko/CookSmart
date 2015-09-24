//
//  CSIngredientListViewCell.h
//  CookSmart
//
//  Created by Vova Galchenko on 9/24/15.
//  Copyright © 2015 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSIngredientListVC, CSIngredient;

@interface CSIngredientListViewCell : UITableViewCell

- (void)configureForListVC:(CSIngredientListVC *)listVC ingredient:(CSIngredient *)ingredient;

@end
