//
//  CSIngredients.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INGREDIENT_DELETE_NOTIFICATION_NAME     @"ingredient_delete_notification"

#define PREF_INGREDIENTS_CHANGED @"Ingredients changed"

@class CSIngredient;
@class CSIngredientGroup;

@interface CSIngredients : NSObject <NSFastEnumeration>

- (id)initWithIngredientGroups:(NSArray *)ingredientGroups;

+ (CSIngredients *)sharedInstance;
- (CSIngredientGroup *)ingredientGroupAtIndex:(NSUInteger)index;
- (CSIngredient*)ingredientAtGroupIndex:(NSUInteger)groupIndex andIngredientIndex:(NSUInteger)index;
- (NSUInteger)countOfIngredientGroups;
- (NSUInteger)flattenedIndexForIngredient:(CSIngredient *)passedInIngredient;
- (CSIngredient *)ingredientAtFlattenedIngredientIndex:(NSUInteger)flattenedIngredientIndex;
- (NSUInteger)flattenedIngredientIndexForGroupIndex:(NSUInteger)groupIndex ingredientIndex:(NSUInteger)index;
- (NSUInteger)flattenedCountOfIngredients;
- (NSUInteger)indexOfIngredientGroup:(CSIngredientGroup *)group;

- (BOOL)deleteIngredientAtGroupIndex:(NSUInteger)groupIndex ingredientIndex:(NSUInteger)ingredientIndex;
- (BOOL)addIngredient:(CSIngredient*)newIngr;
- (BOOL)persist;

- (void)deleteAllSavedIngredients;

@end
