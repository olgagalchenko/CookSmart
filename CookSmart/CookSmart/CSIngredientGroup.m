//
//  CSIngredientGroup.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientGroup.h"
#import "CSIngredient.h"

@interface CSIngredientGroup()

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSArray *ingredients;

@end

@implementation CSIngredientGroup

- (id)initWithDictionary:(NSDictionary *)groupDictionary
{
    if (self = [super init])
    {
        NSArray *dictionaryKeys = [groupDictionary allKeys];
        NSAssert(dictionaryKeys.count == 1, @"A group dictionary should contain exactly one key: the name of the group.");
        self.name = dictionaryKeys[0];
        NSMutableArray *tmpIngredients = [NSMutableArray array];
        for (NSDictionary *ingredientDictionary in [groupDictionary objectForKey:self.name])
        {
            [tmpIngredients addObject:[CSIngredient ingredientWithDictionary:ingredientDictionary]];
        }
        self.ingredients = [NSMutableArray arrayWithArray:tmpIngredients];
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
		state->mutationsPtr = &state->extra[0];
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

@end
