//
//  CSWeightUnit.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSWeightUnit.h"

static const float kGramsInGram = 1;
static const float kGramsInKg = 100;
static const float kGramsInOunce = 28.3495;

static NSString* kGrams = @"Grams";
static NSString* kKilograms = @"Kilograms";
static NSString* kOunces = @"Ounces";

@implementation CSWeightUnit
- (id)initWithName:(NSString*)name
{
    self = [super initWithName:name];
    if (self)
    {
        if ([self.name isEqualToString:kGrams])
            self.conversionFactor = kGramsInGram;
        else if ([self.name isEqualToString:kKilograms])
            self.conversionFactor = kGramsInKg;
        else if ([self.name isEqualToString:kOunces])
            self.conversionFactor = kGramsInOunce;
        else
            NSAssert(NO, @"Bad unit.");
    }
    return self;
}

- (id) initWithIndex:(NSInteger)index
{
    NSString* unitName = [CSWeightUnit nameWithIndex:index];
    NSAssert(unitName, @"Bad unit.");
    self = [self initWithName:unitName];
    return self;
}

+ (NSString*)nameWithIndex:(NSInteger)index
{
    NSString* unitName;
    switch (index) {
        case 0:
            unitName = kGrams;
            break;
        case 1:
            unitName = kKilograms;
            break;
        case 2:
            unitName = kOunces;
            break;
        default:
            break;
    }
    
    return unitName;
}
@end
