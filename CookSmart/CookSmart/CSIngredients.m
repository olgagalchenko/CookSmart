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
        sharedInstance = [[self alloc] init];
        initialized = YES;
    }
}

- (id)init
{
    NSAssert(!initialized, @"Never create an instance of CSIngredients directly. Use the singleton.");
    if (self = [super init])
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
        NSMutableArray *tmpIngredientGroupsArray = [NSMutableArray arrayWithCapacity:[rawIngredientGroupsArray count]];
        for (NSDictionary *ingredientGroupDict in rawIngredientGroupsArray)
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

@end
