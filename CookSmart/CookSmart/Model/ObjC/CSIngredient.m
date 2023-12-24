//
//  CSIngredient.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredient.h"
#import "CSUnit.h"
#import "CSSharedConstants.h"

@interface CSIngredient()

@property (nonatomic, readwrite, strong) NSDate *lastAccessDate;

@end

@implementation CSIngredient

- (id)initWithDictionary:(NSDictionary *)rawIngredientDictionary
{
    return [self initWithName:rawIngredientDictionary[IngredientKeyName]
                      density:[rawIngredientDictionary[IngredientKeyDensity] floatValue]
               lastAccessDate:rawIngredientDictionary[IngredientKeyLastAccessDate]];
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
        IngredientKeyName : self.name,
        IngredientKeyDensity : [NSNumber numberWithFloat:self.density],
    }];
    if (self.lastAccessDate) {
        [dict setObject:self.lastAccessDate forKey:IngredientKeyLastAccessDate];
    }
    return dict;
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
