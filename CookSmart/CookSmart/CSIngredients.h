//
//  CSIngredients.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSIngredientGroup;

@interface CSIngredients : NSObject <NSFastEnumeration>

- (id)initWithArray:(NSArray*)array;

+ (CSIngredients *)sharedInstance;
- (CSIngredientGroup *)ingredientGroupAtIndex:(NSUInteger)index;
- (NSUInteger)countOfIngredientGroups;

@end
