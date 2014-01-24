//
//  CSConversionVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSConversionVC.h"
#import "CSIngredientListVC.h"
#import "CSIngredientGroup.h"
#import "CSIngredient.h"

@interface CSConversionVC ()

@property (nonatomic, readwrite, strong) CSIngredientGroup *ingredientGroup;
@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ingredientNameBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation CSConversionVC

static CSConversionVC *sharedConversionVC = nil;

- (id)initWithIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)ingredientIndex
{
    self = [super initWithNibName:@"CSConversionVC" bundle:nil];
    if (self)
    {
        self.ingredientGroup = ingredientGroup;
        self.ingredientIndex = ingredientIndex;
        sharedConversionVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshUI];
}

- (void)refreshUI
{
    self.navigationItem.title = self.ingredientGroup.name;
    self.ingredientNameBarButtonItem.title = [[self.ingredientGroup ingredientAtIndex:self.ingredientIndex] name];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List"] style:UIBarButtonItemStylePlain target:self action:@selector(onIngrTap:)];
    
    if (_ingredientIndex == 0)
        _prevButton.enabled = NO;
    else
        _prevButton.enabled = YES;
    
    if (_ingredientIndex >= [_ingredientGroup countOfIngredients]-1)
        _nextButton.enabled = NO;
    else
        _nextButton.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onIngrTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] initWithDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)ingredientListVC:(CSIngredientListVC *)listVC selectedIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)index
{
    self.ingredientGroup = ingredientGroup;
    self.ingredientIndex = index;
    [self refreshUI];
}

- (IBAction)onPrevIngrTap:(id)sender
{
    _ingredientIndex--;
    [self refreshUI];
}

- (IBAction)onNextIngrTap:(id)sender
{
    _ingredientIndex++;
    [self refreshUI];
}

@end
