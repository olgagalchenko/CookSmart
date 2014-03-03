//
//  CSIngredient.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredient.h"
#import "CSUnit.h"

#define INGREDIENT_KEY_NAME     @"Name"
#define INGREDIENT_KEY_DENSITY  @"Density"

@implementation CSIngredient

- (id)initWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    return [self initWithName:rawIngredientDictionary[INGREDIENT_KEY_NAME]
                    andDensity:[rawIngredientDictionary[INGREDIENT_KEY_DENSITY] floatValue]];
}

- (id)initWithName:(NSString*)name andDensity:(float)density
{
    if (self = [super init])
    {
        self.name = name;
        self.density = density;
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

- (float)densityWithVolumeUnit:(CSUnit *)volumeUnit andWeightUnit:(CSUnit *)weightUnit
{
    return self.density*(weightUnit.conversionFactor/volumeUnit.conversionFactor);
}

- (BOOL)isIngredientDensityValid
{
    BOOL valid = NO;
    if (!isnan(self.density) && !isinf(self.density))
        return YES;
    return valid;
}

- (BOOL)isEqualToIngredient:(CSIngredient *)otherIngredient
{
    return [self.name isEqualToString:otherIngredient.name] && self.density == otherIngredient.density;
}

@end
