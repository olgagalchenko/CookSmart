//
//  CSVolumeUnit.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSVolumeUnit.h"

static const float kCupsInCup = 1;
static const float kTbspInCup = 100;
static const float kTspInCup = 28.3495;

static NSString* kCups = @"Cups";
static NSString* kTablespoons = @"Tablespoons";
static NSString* kTeaspoons = @"Teaspoons";

@implementation CSVolumeUnit
- (id)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self)
    {
        if ([self.name isEqualToString:kCups])
            self.conversionFactor = kCupsInCup;
        else if ([self.name isEqualToString:kTablespoons])
            self.conversionFactor = kTbspInCup;
        else if ([self.name isEqualToString:kTeaspoons])
            self.conversionFactor = kTspInCup;
        else
            NSAssert(NO, @"Bad unit.");
    }
    return self;
}

- (id)initWithIndex:(NSInteger)index
{
    NSString* unitName = [CSVolumeUnit nameWithIndex:index];
    NSAssert(unitName, @"Bad unit.");
    self = [self initWithName:unitName];
    return self;
}

+ (NSString*)nameWithIndex:(NSInteger)index
{
    NSString* unitName;
    switch (index) {
        case 0:
            unitName = kCups;
            break;
        case 1:
            unitName = kTablespoons;
            break;
        case 2:
            unitName = kTeaspoons;
            break;
        default:
            break;
    }
    return unitName;
}
@end
