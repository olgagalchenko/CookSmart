//
//  CSIngredients.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INGREDIENT_DELETE_NOTIFICATION_NAME     @"ingredient_delete_notification"
#define INGREDIENT_ADD_NOTIFICATION_NAME        @"ingredient_add_notification"
@class CSIngredient;
@class CSIngredientGroup;

@interface CSIngredients : NSObject <NSFastEnumeration>

- (id)initWithIngredientGroups:(NSArray *)ingredientGroups;

+ (CSIngredients *)sharedInstance;
- (CSIngredientGroup *)ingredientGroupAtIndex:(NSUInteger)index;
- (CSIngredient*)ingredientAtGroupIndex:(NSUInteger)groupIndex andIngredientIndex:(NSUInteger)index;
- (NSUInteger)countOfIngredientGroups;

- (BOOL)deleteIngredientAtGroupIndex:(NSUInteger)groupIndex ingredientIndex:(NSUInteger)ingredientIndex;
- (BOOL)addIngredient:(CSIngredient*)newIngr;
- (BOOL)editIngredient:(CSIngredient*)modifiedIngr;
@end
