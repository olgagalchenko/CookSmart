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

@interface CSEditIngredientVC ()
@property (nonatomic, strong) IBOutlet CSScaleVC* scaleVC;
@property (weak, nonatomic) IBOutlet UITextField *ingredientNameField;
@property (nonatomic, strong) CSIngredient* ingredient;
@end

@implementation CSEditIngredientVC

- (id)initWithIngredient:(CSIngredient*)ingr
{
    self = [super init];
    if (self)
    {
        if (ingr)
            self.ingredient = ingr;
        else
            self.ingredient = [[CSIngredient alloc] initWithName:@"" andDensity:150];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.ingredientNameField.text = self.ingredient.name;
    self.scaleVC.delegate = self;
    [self.view addSubview:self.scaleVC.view];
    
    self.scaleVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    self.scaleVC.syncsScales = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)cancelEdit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done:(id)sender
{
    if (!self.ingredient.name.length)
    {
        [self.ingredientNameField becomeFirstResponder];
    }
    else
    {
        [self.ingredientNameField resignFirstResponder];
        NSLog(@"PERSIST INGREDIENT: %@", self.ingredient.dictionary);
    }
}

#pragma mark - text field delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.ingredient.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
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

@end
