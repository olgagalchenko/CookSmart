//
//  CSIngredientGroup.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientGroup.h"
#import "CSIngredient.h"

@interface CSIngredientGroup()

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSArray *ingredients;

@end

@implementation CSIngredientGroup

- (id)initWithDictionary:(NSDictionary *)groupDictionary
{
    if (self = [super init])
    {
        NSArray *dictionaryKeys = [groupDictionary allKeys];
        NSAssert(dictionaryKeys.count == 1, @"A group dictionary should contain exactly one key: the name of the group.");
        self.name = dictionaryKeys[0];
        NSMutableArray *tmpIngredients = [NSMutableArray array];
        for (NSDictionary *ingredientDictionary in [groupDictionary objectForKey:self.name])
        {
            [tmpIngredients addObject:[CSIngredient ingredientWithDictionary:ingredientDictionary]];
        }
        self.ingredients = [NSMutableArray arrayWithArray:tmpIngredients];
    }
    return self;
}

+ (CSIngredientGroup *)ingredientGroupWithDictionary:(NSDictionary *)groupDictionary
{
    return [[self alloc] initWithDictionary:groupDictionary];
}

- (CSIngredient *)ingredientAtIndex:(NSUInteger)ingredientIndex
{
    return [self.ingredients objectAtIndex:ingredientIndex];
}

- (NSUInteger)countOfIngredients
{
    return self.ingredients.count;
}

@end
