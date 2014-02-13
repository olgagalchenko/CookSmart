//
//  CSIngredientGroupInternals.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/12/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#ifndef CookSmart_CSIngredientGroupInternals_h
#define CookSmart_CSIngredientGroupInternals_h

@interface CSIngredientGroup()

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSMutableArray *ingredients;

@end

#endif
