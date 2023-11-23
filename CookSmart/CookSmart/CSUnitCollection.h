//
//  CSUnitCollection.h
//  CookSmart
//
//  Created by Olga Galchenko on 3/1/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSUnit;

@interface CSUnitCollection : NSObject
+ (CSUnitCollection*)volumeUnits;
+ (CSUnitCollection*)weightUnits;

- (CSUnit*)unitAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfUnit:(CSUnit*)unit;
- (NSUInteger)countOfUnits;
@end
