//
//  CSUnit.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnit.h"

@interface CSUnit ()
@property (nonatomic, readwrite, strong) NSString* name;
@property (nonatomic, readwrite, assign) float conversionFactor;
@end

@implementation CSUnit
- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.name = dict[@"Name"];
        self.conversionFactor = [dict[@"Conversion Factor"] floatValue];
    }
    return self;
}

@end
