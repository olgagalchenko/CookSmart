//
//  CSUnit.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnit.h"

@implementation CSUnit

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self)
    {
        _name = name;
    }
    return self;
}

- (id)initWithIndex:(NSInteger)index
{
    CSAssertFail(@"unit_abstract_init", @"Must implement - (id)initWithIndex:(NSInteger)index inside your CSUnit subclass.");
    return nil;
}

+ (NSString*)nameWithIndex:(NSInteger)index
{
    CSAssertFail(@"unit_abstract_name_with_index", @"Must implement + (NSString*)nameWithIndex:(NSInteger)index inside your CSUnit subclass.");
    return nil;
}

+ (NSUInteger)numUnits
{
    CSAssertFail(@"unit_abstract_num_units", @"Must implement + (NSUInteger)numUnits inside your CSUnit subclass.");
    return 0;
}

@end
