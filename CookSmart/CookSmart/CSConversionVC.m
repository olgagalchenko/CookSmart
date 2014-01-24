//
//  CSConversionVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSConversionVC.h"
#import "CSIngredientListVC.h"
#import "CSAppDelegate.h"
@interface CSConversionVC ()

@end

@implementation CSConversionVC

static CSConversionVC *sharedConversionVC = nil;

- (id)initWithIndexPath:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:@"CSConversionVC" bundle:nil];
    if (self)
    {
        delegate = (CSAppDelegate*)[[UIApplication sharedApplication] delegate];
        indexPathToIngr = indexPath;
        sharedConversionVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews
{
    _ingrNameItem.title = [[delegate ingredientsForSection:indexPathToIngr.section][indexPathToIngr.row] objectForKey:@"Name"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onIngrTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

+ (CSConversionVC*)conversionVC
{
    assert(sharedConversionVC != nil);
    return sharedConversionVC;
}

- (void)changeIngredientTo:(NSIndexPath*)indexPath
{
    indexPathToIngr = indexPath;
}
@end
