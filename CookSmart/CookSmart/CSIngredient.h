//
//  CSIngredient.h
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSUnit;

@interface CSIngredient : NSObject

+ (CSIngredient *)ingredientWithDictionary:(NSDictionary *)rawIngredientDictionary;
- (id)initWithName:(NSString*)name andDensity:(float)density;
- (NSDictionary *)dictionary;

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, assign) float density;

- (float)densityWithVolumeUnit:(CSUnit *)volumeUnit andWeightUnit:(CSUnit *)weightUnit;
- (BOOL)isIngredientDensityValid;
- (BOOL)isEqualToIngredient:(CSIngredient *)otherIngredient;

@end
