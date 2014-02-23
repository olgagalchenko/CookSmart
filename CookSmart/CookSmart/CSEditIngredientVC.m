//
//  CSEditIngredientVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 2/18/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSEditIngredientVC.h"
#import "CSScaleVC.h"
#import "CSIngredient.h"
#import "CSIngredients.h"

@interface CSEditIngredientVC ()
@property (nonatomic, strong) IBOutlet CSScaleVC* scaleVC;
@property (weak, nonatomic) IBOutlet UITextField *ingredientNameField;
@property (nonatomic, strong) CSIngredient* ingredient;

@property (nonatomic, copy) void (^doneBlock) (CSIngredient* newIngr);
@property (nonatomic, copy) void (^cancelBlock) (void);
@end

@implementation CSEditIngredientVC

- (id)initWithIngredient:(CSIngredient*)ingr withDoneBlock:(void (^)(CSIngredient*))done andCancelBlock:(void (^)(void))cancel
{
    self = [super init];
    if (self)
    {
        if (ingr)
            self.ingredient = ingr;
        else
            self.ingredient = [[CSIngredient alloc] initWithName:@"" andDensity:150];
        
        self.doneBlock = done;
        self.cancelBlock = cancel;
    }
    return self;
}

- (void)dealloc
{
    self.scaleVC.delegate = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scaleVC.ingredient = self.ingredient;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    logViewChange(@"edit_ingredient", [self analyticsDictionary]);
    [self.ingredientNameField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    self.ingredientNameField.translatesAutoresizingMaskIntoConstraints = NO;
    self.ingredientNameField.text = self.ingredient.name;
    
    [self addChildViewController:self.scaleVC];
    self.scaleVC.delegate = self;
    self.scaleVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scaleVC.view];
    self.scaleVC.syncsScales = NO;
    
    NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:self.scaleVC.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0];
    NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:self.scaleVC.view
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0];
    NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:self.scaleVC.view
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0];
    NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:self.scaleVC.view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.ingredientNameField
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:10];
    [self.view addConstraints:@[bottom, left, right, top]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)cancelEdit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    logUserAction(@"ingredient_edit_cancelled", [self analyticsDictionary]);
    
    if (self.cancelBlock != nil)
        self.cancelBlock();
}

- (void)done:(id)sender
{
    if (!self.ingredient.name.length)
    {
        [self.ingredientNameField becomeFirstResponder];
    }
    else if (![self.ingredient isIngredientDensityValid])
    {
        UIAlertView* densityError = [[UIAlertView alloc] initWithTitle:@"Invalid density" message:@"wow. such dense. much error." delegate:nil cancelButtonTitle:@"OK, I'll fix it." otherButtonTitles: nil];
        [densityError show];
    }
    else
    {
        [self.ingredientNameField resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.doneBlock != nil)
            self.doneBlock(self.ingredient);
        logUserAction(@"ingredient_persisted", [self analyticsDictionary]);
    }
}

#pragma mark - text field delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.ingredient.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    logUserAction(@"ingredient_name_change", [self analyticsDictionary]);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.ingredientNameField resignFirstResponder];
    return YES;
}

#pragma mark - CSScaleVCDelegate methods
- (void)scaleVC:(CSScaleVC *)scaleVC densityDidChange:(float)changedDensity
{
    self.ingredient.density = changedDensity;
}

#pragma mark - Misc. Helpers
- (NSDictionary *)analyticsDictionary
{
    return @{
             @"ingredient_name": self.ingredient.name,
             @"ingredient_density" : [self.ingredient isIngredientDensityValid]? @(self.ingredient.density) : @(FLT_MAX),
             };
}

@end
