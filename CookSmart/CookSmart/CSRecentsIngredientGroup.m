//
//  CSRecentsIngredientGroup.m
//  CookSmart
//
//  Created by Vova Galchenko on 9/22/15.
//  Copyright © 2015 Olga Galchenko. All rights reserved.
//

#import "CSRecentsIngredientGroup.h"
#import "CSIngredientGroupInternals.h"
#import "CSIngredient.h"

#define MAX_NUM_RECENTS     5

@implementation CSRecentsIngredientGroup

- (id)initWithIngredients:(NSArray *)allIngredients
{
    if (self = [super init])
    {
        self.name = @"Recents";
        NSArray *accessedIngredients = [allIngredients filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CSIngredient * _Nonnull evaluatedIngr, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedIngr.lastAccessDate != nil;
        }]];
        NSArray *sortedAccessedIngredients = [accessedIngredients sortedArrayUsingComparator:^NSComparisonResult(CSIngredient * _Nonnull ingr1, CSIngredient *  _Nonnull ingr2) {
            return [ingr2.lastAccessDate compare:ingr1.lastAccessDate];
        }];
        NSArray *topAccessedIngredients = [sortedAccessedIngredients subarrayWithRange:NSMakeRange(0, MIN(MAX_NUM_RECENTS, sortedAccessedIngredients.count))];
        self.ingredients = [NSMutableArray arrayWithArray:topAccessedIngredients];
        self.synthetic = YES;
    }
    return self;
}

+ (CSRecentsIngredientGroup *)recentsGroupWithIngredients:(NSArray *)allIngredients;
{
    return [[self alloc] initWithIngredients: allIngredients];
}
                                                                                    
- (void)deleteIngredient:(CSIngredient *)ingredient
{
    CSAssertFail(@"recent_ingr_delete", @"Manipulating recent ingredients is not allowed. Attempted deletion of %@", ingredient);
}
- (void)addIngredient:(CSIngredient*)ingredient
{
    CSAssertFail(@"recent_ingr_add", @"Manipulating recent ingredients is not allowed. Attempted addition of %@", ingredient);
}

- (void)replaceIngredientAtIndex:(NSUInteger)index withIngredient:(CSIngredient*)ingredient
{
    CSAssertFail(@"recent_ingr_replace", @"Manipulating recent ingredients is not allowed. Attempted replacement.");
}

@end
