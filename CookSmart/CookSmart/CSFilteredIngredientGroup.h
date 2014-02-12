//
//  CSFilteredIngredientGroup.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/12/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientGroup.h"

@interface CSFilteredIngredientGroup : CSIngredientGroup

+ (CSFilteredIngredientGroup *)filteredIngredientGroupWithIngredients:(NSArray *)ingredients name:(NSString *)groupName originalIngredientGroup:(CSIngredientGroup *)originalIngredientGroup;

@property (nonatomic, readonly) CSIngredientGroup *originalIngredientGroup;

@end
