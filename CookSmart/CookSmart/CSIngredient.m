//
//  CSIngredient.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredient.h"

#define INGREDIENT_KEY_NAME     @"Name"
#define INGREDIENT_KEY_DENSITY  @"Density"

@interface CSIngredient()

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, assign) float density;

@end

@implementation CSIngredient

- (id)initWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    if ((self = [super init]))
    {
        self.name = rawIngredientDictionary[INGREDIENT_KEY_NAME];
        self.density = [rawIngredientDictionary[INGREDIENT_KEY_DENSITY] floatValue];
    }
    return self;
}

+ (CSIngredient *)ingredientWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    return [[self alloc] initWithDictionary:rawIngredientDictionary];
}

- (NSDictionary *)dictionary
{
    return @{
             INGREDIENT_KEY_NAME : self.name,
             INGREDIENT_KEY_DENSITY : [NSNumber numberWithFloat:self.density],
             };
}

@end
