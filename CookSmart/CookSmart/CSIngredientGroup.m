//
//  CSIngredientGroup.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientGroup.h"
#import "CSIngredient.h"
#import "CSIngredientGroupInternals.h"

@interface CSIngredientGroup ()
{
    unsigned long _version;
}

@end

@implementation CSIngredientGroup

- (id)initWithDictionary:(NSDictionary *)groupDictionary
{
    if (self = [super init])
    {
        NSArray *dictionaryKeys = [groupDictionary allKeys];
        CSAssert(dictionaryKeys.count == 1, @"ingredient_group_dictionary_consistency", @"A group dictionary should contain exactly one key: the name of the group.");
        self.name = dictionaryKeys[0];
        NSMutableArray *tmpIngredients = [NSMutableArray array];
        for (NSDictionary *ingredientDictionary in [groupDictionary objectForKey:self.name])
        {
            [tmpIngredients addObject:[CSIngredient ingredientWithDictionary:ingredientDictionary]];
        }
        self.ingredients = tmpIngredients;
        self.synthetic = NO;
    }
    return self;
}

+ (CSIngredientGroup *)ingredientGroupWithDictionary:(NSDictionary *)groupDictionary
{
    return [[self alloc] initWithDictionary:groupDictionary];
}

- (CSIngredient *)ingredientAtIndex:(NSUInteger)ingredientIndex
{
    return [self.ingredients objectAtIndex:ingredientIndex];
}

- (NSUInteger)indexOfIngredient:(CSIngredient *)ingredient
{
    return [self.ingredients indexOfObject:ingredient];
}

- (NSUInteger)countOfIngredients
{
    return self.ingredients.count;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    NSUInteger count = 0;
    unsigned long countOfItemsAlreadyEnumerated = state->state;
    
    if(countOfItemsAlreadyEnumerated == 0)
	{
		// We are not tracking mutations, so we'll set state->mutationsPtr to point
        // into one of our extra values, since these values are not otherwise used
        // by the protocol.
		// If your class was mutable, you may choose to use an internal variable that
        // is updated when the class is mutated.
		// state->mutationsPtr MUST NOT be NULL and SHOULD NOT be set to self.
		state->mutationsPtr = &_version;
	}
    
    if(countOfItemsAlreadyEnumerated < [self.ingredients count])
    {
        state->itemsPtr = buffer;
        while((countOfItemsAlreadyEnumerated < [self.ingredients count]) && (count < len))
		{
			// Add the item for the next index to stackbuf.
            //
            // If you choose not to use ARC, you do not need to retain+autorelease the
            // objects placed into stackbuf.  It is the caller's responsibility to ensure we
            // are not deallocated during enumeration.
			buffer[count] = self.ingredients[countOfItemsAlreadyEnumerated];
			countOfItemsAlreadyEnumerated++;
            
            // We must return how many items are in state->itemsPtr.
			count++;
		}
    }
    else
        count = 0;
    
    // Update state->state with the new value of countOfItemsAlreadyEnumerated so that it is
    // preserved for the next invocation.
    state->state = countOfItemsAlreadyEnumerated;
    return count;
}

- (void)deleteIngredient:(CSIngredient *)ingredient
{
    _version++;
    [self.ingredients removeObject:ingredient];
}

- (void)addIngredient:(CSIngredient *)ingredient
{
    _version++;
    [self.ingredients addObject:ingredient];
}

- (void)replaceIngredientAtIndex:(NSUInteger)index withIngredient:(CSIngredient*)ingredient
{
    _version++;
    [self.ingredients replaceObjectAtIndex:index withObject:ingredient];
}

- (NSDictionary *)dictionary
{
    NSMutableArray *ingredients = [NSMutableArray arrayWithCapacity:self.ingredients.count];
    for (CSIngredient *ingredient in self.ingredients)
    {
        [ingredients addObject:[ingredient dictionary]];
    }
    return @{
             self.name : ingredients
             };
}

@end
