//
//  CSFilteredIngredientGroup.m
//  CookSmart
//
//  Created by Vova Galchenko on 2/12/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSFilteredIngredientGroup.h"
#import "CSIngredientGroupInternals.h"

@interface CSFilteredIngredientGroup()

@property (nonatomic, readwrite, strong) CSIngredientGroup *originalIngredientGroup;

@end

@implementation CSFilteredIngredientGroup

- (id)initWithIngredients:(NSArray *)ingredients name:(NSString *)groupName originalIngredientGroup:(CSIngredientGroup *)originalIngredientGroup
{
    if (self = [super init])
    {
        self.ingredients = [NSMutableArray arrayWithArray:ingredients];
        self.name = groupName;
        self.originalIngredientGroup = originalIngredientGroup;
        self.synthetic = NO;
    }
    return self;
}

+ (CSFilteredIngredientGroup *)filteredIngredientGroupWithIngredients:(NSArray *)ingredients name:(NSString *)groupName originalIngredientGroup:(CSIngredientGroup *)originalIngredientGroup
{
    return [[self alloc] initWithIngredients:ingredients name:groupName originalIngredientGroup:originalIngredientGroup];
}

- (void)deleteIngredient:(CSIngredient *)ingredient
{
    [super deleteIngredient:ingredient];
    [self.originalIngredientGroup deleteIngredient:ingredient];
}

@end
