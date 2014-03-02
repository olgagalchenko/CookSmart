//
//  CSUnit.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/27/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUnit : NSObject

- (id)initWithDictionary:(NSDictionary*)dict;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) float conversionFactor;
@end
