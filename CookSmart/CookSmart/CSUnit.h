//
//  CSUnit.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUnit : NSObject

- (id)initWithName:(NSString*)name;
- (id)initWithIndex:(NSInteger)index;
+ (NSString*)nameWithIndex:(NSInteger)index;
@property (nonatomic, strong) NSString* name;
@property (assign) float conversionFactor;
@end
