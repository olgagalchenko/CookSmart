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
    NSAssert(NO, @"Must implement - (id)initWithIndex:(NSInteger)index inside your CSUnit subclass.");
    return nil;
}

+ (NSString*)nameWithIndex:(NSInteger)index
{
    NSAssert(NO, @"Must implement + (NSString*)nameWithIndex:(NSInteger)index inside your CSUnit subclass.");
    return nil;
}

@end
