//
//  CSWeightUnit.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSWeightUnit.h"

static const float kGramsInGram = 1;
static const float kKgsInGram = 0.001;
static const float kOuncesInGram = 0.035274;

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
            self.conversionFactor = kKgsInGram;
        else if ([self.name isEqualToString:kOunces])
            self.conversionFactor = kOuncesInGram;
        else
            CSAssertFail(@"weight_unit_init", @"Bad unit.");
    }
    return self;
}

- (id)initWithIndex:(NSInteger)index
{
    NSString* unitName = [CSWeightUnit nameWithIndex:index];
    CSAssert(unitName != nil, @"weight_unit_init_with_index", @"Bad unit.");
    self = [self initWithName:unitName];
    return self;
}

+ (NSString*)nameWithIndex:(NSInteger)index
{
    NSString* unitName = nil;
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
