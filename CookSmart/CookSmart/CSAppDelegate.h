//
//  CSAppDelegate.h
//  CookSmart
//
//  Created by Olga Galchenko on 10/8/13.
//  Copyright (c) 2013 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray* ingrData;

- (NSString*)ingredientTypeForSection:(NSInteger)section;
- (NSArray*)ingredientsForSection:(NSInteger)section;

@end