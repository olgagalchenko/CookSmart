//
//  CSIngredients.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INGREDIENT_DELETE_NOTIFICATION_NAME     @"ingredient_delete_notification"

@class CSIngredient;
@class CSIngredientGroup;

static inline NSString *pathToIngredientsOnDisk()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSCAssert([paths count] > 0, @"Unable to get the path to the documents directory.");
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"ingredients.plist"];
}

static inline NSString *pathToIngredientsInBundle()
{
    return [[NSBundle mainBundle] pathForResource:@"Ingredients" ofType:@"plist"];
}

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
