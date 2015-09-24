//
//  CSIngredient.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredient.h"
#import "CSUnit.h"

#define INGREDIENT_KEY_NAME             @"Name"
#define INGREDIENT_KEY_DENSITY          @"Density"
#define INGREDIENT_KEY_LAST_ACCESS_DATE @"LastAccessDate"

@interface CSIngredient()

@property (nonatomic, readwrite, strong) NSDate *lastAccessDate;

@end

@implementation CSIngredient

- (id)initWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    return [self initWithName:rawIngredientDictionary[INGREDIENT_KEY_NAME]
                      density:[rawIngredientDictionary[INGREDIENT_KEY_DENSITY] floatValue]
               lastAccessDate:rawIngredientDictionary[INGREDIENT_KEY_LAST_ACCESS_DATE]];
}

- (id)initWithName:(NSString*)name density:(float)density lastAccessDate:(NSDate *)lastAccessDate
{
    if (self = [super init])
    {
        self.name = name;
        self.density = density;
        self.lastAccessDate = lastAccessDate;
    }
    return self;
}

+ (CSIngredient *)ingredientWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    return [[self alloc] initWithDictionary:rawIngredientDictionary];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: @{
        INGREDIENT_KEY_NAME : self.name,
        INGREDIENT_KEY_DENSITY : [NSNumber numberWithFloat:self.density],
    }];
    if (self.lastAccessDate) {
        [dict setObject:self.lastAccessDate forKey:INGREDIENT_KEY_LAST_ACCESS_DATE];
    }
    return dict;
}

- (NSDictionary *)dictionaryForAnalytics
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self dictionary]];
    dict[INGREDIENT_KEY_LAST_ACCESS_DATE] = [dict[INGREDIENT_KEY_LAST_ACCESS_DATE] description];
    return dict;
}

- (float)densityWithVolumeUnit:(CSUnit *)volumeUnit andWeightUnit:(CSUnit *)weightUnit
{
    return self.density*(weightUnit.conversionFactor/volumeUnit.conversionFactor);
}

- (void)markAccess
{
    self.lastAccessDate = [NSDate date];
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
