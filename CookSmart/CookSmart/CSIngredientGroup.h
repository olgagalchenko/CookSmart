//
//  CSIngredientGroup.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSIngredient;

@interface CSIngredientGroup : NSObject

+ (CSIngredientGroup *)ingredientGroupWithDictionary:(NSDictionary *)groupDictionary;
- (CSIngredient *)ingredientAtIndex:(NSUInteger)ingredientIndex;
- (NSUInteger)countOfIngredients;

@property (nonatomic, readonly) NSString *name;

@end