//
//  CSRecentsIngredientGroup.h
//  CookSmart
//
//  Created by Vova Galchenko on 9/22/15.
//  Copyright © 2015 Olga Galchenko. All rights reserved.
//

#import "CSIngredientGroup.h"
#import "CSIngredients.h"

@interface CSRecentsIngredientGroup : CSIngredientGroup

+ (CSRecentsIngredientGroup *)recentsGroupWithIngredients:(NSArray *)allIngredients;

@end
