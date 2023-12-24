//
//  CSUnitCollection.m
//  CookSmart
//
//  Created by Olga Galchenko on 3/1/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnitCollection.h"
#import "CSUnit.h"

@interface CSUnitCollection ()

@end

@implementation CSUnitCollection

static CSUnitCollection* volumeUnits;
static CSUnitCollection* weightUnits;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        volumeUnits = [[self alloc] initWithPlistName:@"VolumeUnits"];
        weightUnits = [[self alloc] initWithPlistName:@"WeightUnits"];
    });
}

- (id)initWithPlistName:(NSString*)plist
{
    self = [super init];
    if (self)
    {
        NSMutableArray* mutableArrayOfUnits = [NSMutableArray array];
        NSArray* unitsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
        for (NSDictionary* unitDict in unitsArray)
        {
            CSUnit* unit = [[CSUnit alloc] initWithDictionary:unitDict];
            [mutableArrayOfUnits addObject:unit];
        }
        
        self.units = mutableArrayOfUnits;
    }
    return self;
}

+ (CSUnitCollection*)volumeUnits
{
    return volumeUnits;
}

+ (CSUnitCollection*)weightUnits
{
    return weightUnits;
}

- (CSUnit*)unitAtIndex:(NSUInteger)index
{
    return [self.units objectAtIndex:index];
}

- (NSUInteger)indexOfUnit:(CSUnit*)unit
{
    return [self.units indexOfObject:unit];
}

- (NSUInteger)countOfUnits
{
    return [self.units count];
}

@end
