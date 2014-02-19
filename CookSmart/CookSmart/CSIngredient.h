//
//  CSIngredient.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSVolumeUnit;
@class CSWeightUnit;

@interface CSIngredient : NSObject

+ (CSIngredient *)ingredientWithDictionary:(NSDictionary *)rawIngredientDictionary;
- (id)initWithName:(NSString*)name andDensity:(float)density;
- (NSDictionary *)dictionary;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) float density;

- (float)densityWithVolumeUnit:(CSVolumeUnit *)volumeUnit andWeightUnit:(CSWeightUnit *)weightUnit;
@end
