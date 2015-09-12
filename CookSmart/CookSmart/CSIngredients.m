 //
//  CSIngredients.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredients.h"
#import "CSIngredientGroup.h"
#import "CSFilteredIngredientGroup.h"
#import "CSIngredient.h"

#define CUSTOM_GROUP_NAME @"Custom"
#define RECENTLY_USED_NAME @"Recently Used"

@interface CSIngredients()
{
    unsigned long _version;
}

@property (nonatomic, readwrite, strong) NSMutableArray *ingredientGroups;

@end

@implementation CSIngredients

static CSIngredients *sharedInstance;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ingredientsIsDir = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathToIngredientsOnDisk() isDirectory:&ingredientsIsDir])
        {
            CSAssert(!ingredientsIsDir, @"ingredients_file_is_directory", @"The ingredients file's place is taken by a directory.");
        }
        else
        {
            // This is the first time we're launching the app.
            // Let's move the ingredients file from the app bundle to our sandbox.
            [CSIngredients copyIngredientsFromBundle];
        }
        sharedInstance = [[self alloc] initWithPlistOnDisk];
    });
}

+ (void)copyIngredientsFromBundle
{
    NSError *copyError = nil;
    [[NSFileManager defaultManager] copyItemAtPath:pathToIngredientsInBundle()
                                            toPath:pathToIngredientsOnDisk()
                                             error:&copyError];
    CSAssert(copyError == nil, @"ingredients_file_copy", @"Error occurred while copying the ingredients file to the sandbox.");
}

- (id)initWithPlistOnDisk
{
    NSArray *rawIngredientGroupsArray = [NSArray arrayWithContentsOfFile:pathToIngredientsOnDisk()];
    NSMutableArray *tmpIngredientGroupsArray = [NSMutableArray arrayWithCapacity:[rawIngredientGroupsArray count]];
    for (NSDictionary *ingredientGroupDict in rawIngredientGroupsArray)
    {
        [tmpIngredientGroupsArray addObject:[CSIngredientGroup ingredientGroupWithDictionary:ingredientGroupDict]];
    }
    return [self initWithIngredientGroups:[NSArray arrayWithArray:tmpIngredientGroupsArray]];
}

- (id)initWithIngredientGroups:(NSArray *)ingredientGroups
{
    if (self = [super init])
    {
        self.ingredientGroups = [NSMutableArray arrayWithArray:ingredientGroups];
    }
    return self;
}

+ (CSIngredients *)sharedInstance
{
    CSAssert(sharedInstance != nil, @"ingredients_singleton_guard", @"Something went wrong with the singleton.");
    return sharedInstance;
}

- (CSIngredientGroup *)ingredientGroupAtIndex:(NSUInteger)index
{
    CSIngredientGroup *group = [self.ingredientGroups objectAtIndex:index];
    return group;
}

- (CSIngredientGroup*)lastIngredientGroup
{
    CSIngredientGroup* group = [self.ingredientGroups lastObject];
    return group;
}

- (CSIngredientGroup *)customIngredientGroup
{
    if (![[self lastIngredientGroup].name isEqualToString:CUSTOM_GROUP_NAME])
    {
        //need to create it
        [self.ingredientGroups addObject:[CSIngredientGroup ingredientGroupWithDictionary:@{CUSTOM_GROUP_NAME:@[]}]];
    }
    return [self lastIngredientGroup];
}

- (CSIngredientGroup *)recentlyUsedIngredientGroup
{
    CSIngredientGroup *group = [self ingredientGroupAtIndex:0];
    if (![group.name isEqualToString:RECENTLY_USED_NAME])
    {
        //need to create it
        group = [CSIngredientGroup ingredientGroupWithDictionary:@{RECENTLY_USED_NAME:@[]}];
        [self.ingredientGroups insertObject:group atIndex:0];
    }
    return group;
}

- (CSIngredient*)ingredientAtGroupIndex:(NSUInteger)groupIndex andIngredientIndex:(NSUInteger)index
{
    CSIngredient* returnIngr = nil;
    if (groupIndex < [self countOfIngredientGroups])
    {
        CSIngredientGroup* group = [self ingredientGroupAtIndex:groupIndex];
        if (index < [group countOfIngredients])
            returnIngr = [group ingredientAtIndex:index];
    }
    
    return returnIngr;
}

- (NSUInteger)indexOfIngredientGroup:(CSIngredientGroup *)group
{
    NSUInteger index = NSNotFound;
    for (int i = 0; i < self.countOfIngredientGroups; i++)
    {
        if ([self ingredientGroupAtIndex:i] == group)
        {
            index = i;
        }
    }
    return index;
}

- (NSUInteger)flattenedIndexForIngredient:(CSIngredient *)passedInIngredient
{
    NSUInteger result = 0;
    for (CSIngredientGroup *group in self)
    {
        for (CSIngredient *ingredient in group)
        {
            if ([ingredient isEqualToIngredient:passedInIngredient])
            {
                return result;
            }
            result++;
        }
    }
    return NSNotFound;
}

- (CSIngredient *)ingredientAtFlattenedIngredientIndex:(NSUInteger)flattenedIngredientIndex
{
    NSUInteger ingredientIndex = flattenedIngredientIndex;
    NSUInteger groupIndex = 0;
    while (ingredientIndex > ([[self ingredientGroupAtIndex:groupIndex] countOfIngredients] - 1))
    {
        ingredientIndex -= [[self ingredientGroupAtIndex:groupIndex] countOfIngredients];
        groupIndex++;
    }
    return [[self ingredientGroupAtIndex:groupIndex] ingredientAtIndex:ingredientIndex];
}

- (NSUInteger)flattenedIngredientIndexForGroupIndex:(NSUInteger)groupIndex ingredientIndex:(NSUInteger)index
{
    NSUInteger flattenedIngredientIndex = index;
    for (NSUInteger i = 0; i < groupIndex; i++)
    {
        flattenedIngredientIndex += [[self ingredientGroupAtIndex:i] countOfIngredients];
    }
    return flattenedIngredientIndex;
}

- (NSUInteger)flattenedCountOfIngredients
{
    NSUInteger numIngredients = 0;
    for (CSIngredientGroup *group in self)
    {
        numIngredients += [group countOfIngredients];
    }
    return numIngredients;
}

- (NSUInteger)countOfIngredientGroups
{
    return self.ingredientGroups.count;
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
    
    if(countOfItemsAlreadyEnumerated < [self.ingredientGroups count])
    {
        state->itemsPtr = buffer;
        while((countOfItemsAlreadyEnumerated < [self.ingredientGroups count]) && (count < len))
		{
			// Add the item for the next index to stackbuf.
            //
            // If you choose not to use ARC, you do not need to retain+autorelease the
            // objects placed into stackbuf.  It is the caller's responsibility to ensure we
            // are not deallocated during enumeration.
			buffer[count] = self.ingredientGroups[countOfItemsAlreadyEnumerated];
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

#pragma mark - actions on list

- (BOOL)addToRecentlyUsed:(CSIngredient *)ingredient
{
    _version++; //mutation protection for fast enumeration
    
    CSIngredientGroup *recentlyUsedGroup = [self recentlyUsedIngredientGroup];
    [recentlyUsedGroup addRecentlyUsedIngredient:ingredient];
    
    return [sharedInstance persist];
}

- (BOOL)deleteIngredientAtGroupIndex:(NSUInteger)groupIndex ingredientIndex:(NSUInteger)ingredientIndex
{
    _version++; //mutation protection for fast enumeration
    
    CSIngredientGroup *ingrGroup = [self ingredientGroupAtIndex:groupIndex];
    CSIngredient *ingredient = [ingrGroup ingredientAtIndex:ingredientIndex];
    [ingrGroup deleteIngredient:ingredient];
    if ([ingrGroup countOfIngredients] <= 0)
    {
        [self.ingredientGroups removeObject:ingrGroup];
    }
    if ([ingrGroup respondsToSelector:@selector(originalIngredientGroup)] &&
        (ingrGroup = [ingrGroup performSelector:@selector(originalIngredientGroup) withObject:nil]) &&
        [ingrGroup countOfIngredients] <= 0)
    {
        [sharedInstance.ingredientGroups removeObject:ingrGroup];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:INGREDIENT_DELETE_NOTIFICATION_NAME object:ingredient];
    return [sharedInstance persist];
}

- (BOOL)addIngredient:(CSIngredient*)newIngr
{
    _version++;
    
    CSIngredientGroup* ingrGroup = [self customIngredientGroup];
    [ingrGroup addIngredient:newIngr];
    
    return [sharedInstance persist];
}

- (BOOL)persist
{
    NSMutableArray *groupsToSerialize = [NSMutableArray arrayWithCapacity:self.ingredientGroups.count];
    for (CSIngredientGroup *group in self.ingredientGroups)
    {
        [groupsToSerialize addObject:[group dictionary]];
    }
    BOOL success = [groupsToSerialize writeToFile:pathToIngredientsOnDisk() atomically:YES];
    if (!success)
    {
        NSLog(@"FAILED TO WRITE FILE: %s", strerror(errno));
    }
    return success;
}

- (void)deleteAllSavedIngredients
{
    sharedInstance = nil;
    
    NSError* err;
    [[NSFileManager defaultManager] removeItemAtPath:pathToIngredientsOnDisk() error:&err];
    
    CSAssert(err == nil, @"csingredients_remove_ingredients_saved_on_disk", @"Resetting ingredients to defaults");
    
    [CSIngredients copyIngredientsFromBundle];
    sharedInstance = [[CSIngredients alloc] initWithPlistOnDisk];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:INGREDIENT_DELETE_NOTIFICATION_NAME object:nil];
}

@end
