//
//  CSIngredients.m
//  CookSmart
//
//  Created by Vova Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredients.h"
#import "CSIngredientGroup.h"

@interface CSIngredients()

@property (nonatomic, readwrite, strong) NSArray *ingredientGroups;

@end

@implementation CSIngredients

static CSIngredients *sharedInstance;
static BOOL initialized = NO;

static inline NSString *pathToIngredientsOnDisk()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSCAssert([paths count] > 0, @"Unable to get the path to the documents directory.");
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"ingredients.plist"];
}

+ (void)initialize
{
    if(!initialized)
    {
        BOOL ingredientsIsDir = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathToIngredientsOnDisk() isDirectory:&ingredientsIsDir])
        {
            NSAssert(!ingredientsIsDir, @"The ingredients file's place is taken by a directory.");
        }
        else
        {
            // This is the first time we're launching the app.
            // Let's move the ingredients file from the app bundle to our sandbox.
            NSError *copyError = nil;
            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Ingredients" ofType:@"plist"]
                                                    toPath:pathToIngredientsOnDisk()
                                                     error:&copyError];
            NSAssert(copyError == nil, @"Error occurred while copying the ingredients file to the sandbox.");
        }
        NSArray *rawIngredientGroupsArray = [NSArray arrayWithContentsOfFile:pathToIngredientsOnDisk()];
        
        sharedInstance = [[self alloc] initWithArray:rawIngredientGroupsArray];
        initialized = YES;
    }
}

- (id)initWithArray:(NSArray*)array
{
    if (self = [super init])
    {
        
        NSMutableArray *tmpIngredientGroupsArray = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *ingredientGroupDict in array)
        {
            [tmpIngredientGroupsArray addObject:[CSIngredientGroup ingredientGroupWithDictionary:ingredientGroupDict]];
        }
        self.ingredientGroups = [NSArray arrayWithArray:tmpIngredientGroupsArray];
    }
    return self;
}

+ (CSIngredients *)sharedInstance
{
    NSAssert(sharedInstance != nil, @"Something went wrong with the singleton.");
    return sharedInstance;
}

- (CSIngredientGroup *)ingredientGroupAtIndex:(NSUInteger)index
{
    CSIngredientGroup *group = [self.ingredientGroups objectAtIndex:index];
    return group;
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
		state->mutationsPtr = &state->extra[0];
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

@end
