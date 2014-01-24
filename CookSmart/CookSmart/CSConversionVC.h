//
//  CSConversionVC.h
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSConversionVC.h"

@class CSAppDelegate;
@interface CSConversionVC : UIViewController
{
    CSAppDelegate*  delegate;
    NSIndexPath*    indexPathToIngr;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ingrNameItem;

- (id)initWithIndexPath:(NSIndexPath *)indexPath;
+ (CSConversionVC*)conversionVC;
- (void)changeIngredientTo:(NSIndexPath*)indexPath;
@end
