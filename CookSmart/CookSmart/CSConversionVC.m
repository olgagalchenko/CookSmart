//
//  CSConversionVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSConversionVC.h"
#import "CSIngredients.h"
#import "CSIngredientListVC.h"
#import "CSIngredientGroup.h"
#import "CSIngredient.h"
#import "CSScaleView.h"
#import "CSUnit.h"
#import "CSVolumeUnit.h"
#import "CSWeightUnit.h"
#import "CSScaleVC.h"

#define CHOOSE_UNITS_TEXT @"Choose Units"

@interface CSConversionVC ()
{
    CGFloat _previousIngredientPickerDistanceToSnap;
}

@property (nonatomic, readwrite, strong) CSIngredientGroup *ingredientGroup;
@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIButton *ingredientNameButton;

@property (strong, nonatomic) IBOutlet CSScaleVC* scaleVC;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ingredientDeleted:)
                                                     name:INGREDIENT_DELETE_NOTIFICATION_NAME
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle Management

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self selectIngredientGroup:self.ingredientGroup ingredientIndex:self.ingredientIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.scaleVC];
    [self.view addSubview:self.scaleVC.view];
    self.scaleVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.scaleVC.delegate = self;
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
                                                              toItem:self.ingredientNameButton
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:10];
    [self.view addConstraints:@[bottom, left, right, top]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    logViewChange(@"conversion", [self analyticsAttributes]);
}

#pragma mark -

static inline UILabel *createIngredientLabel()
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = BACKGROUND_COLOR;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)refreshIngredientNameUI
{
    [self.ingredientNameButton setTitle:[self.ingredientGroup ingredientAtIndex:self.ingredientIndex].name forState:UIControlStateNormal];
}

- (void)refreshScalesWithCurrentIngredient
{
    self.scaleVC.ingredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
}

- (void)ingredientListVC:(CSIngredientListVC *)listVC selectedIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)index
{
    CSIngredient *ingredient = [ingredientGroup ingredientAtIndex:index];
    logUserAction(@"ingredient_select", @{
                                          @"ingredient_group_name" : ingredientGroup.name,
                                          @"ingredient_name" : ingredient.name,
                                          @"ingredient_density" : [NSNumber numberWithFloat:ingredient.density],
                                          });
    [self selectIngredientGroup:ingredientGroup ingredientIndex:index];
}

- (void)selectIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)index
{
    self.ingredientGroup = ingredientGroup;
    self.ingredientIndex = index;
    [self refreshIngredientNameUI];
    [self refreshScalesWithCurrentIngredient];
}

- (IBAction)handleIngredientGroupTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] initWithDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)ingredientDeleted:(NSNotification *)notification
{
    // When an ingredient is deleted, our index into the ingredient group might change.
    // In the future we might want to put a better solution for this, but for now, we'll
    // just select the very first ingredient of the very first ingredient group and be done
    // with it.
    
    if ([[CSIngredients sharedInstance] countOfIngredientGroups] > 0)
    {
        [self selectIngredientGroup:[[CSIngredients sharedInstance] ingredientGroupAtIndex:0] ingredientIndex:0];
    }
    else
    {
        [self selectIngredientGroup:nil ingredientIndex:0];
    }
}

#pragma mark - scaleVC delegate methods
- (void)scaleVCDidBeginChangingUnits:(CSScaleVC*)scaleVC
{
    self.ingredientNameButton.enabled = NO;
    
    [self.ingredientNameButton setTitle:CHOOSE_UNITS_TEXT forState:UIControlStateNormal];
}

- (void)scaleVCDidFinishChangingUnits:(CSScaleVC *)scaleVC
{
    self.ingredientNameButton.enabled = YES;
    
    [self refreshIngredientNameUI];
}

#pragma mark - Misc Helpers

- (NSDictionary *)analyticsAttributes
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.scaleVC analyticsAttributes]];
    [dict setObject:self.ingredientGroup.name forKey:@"ingredient_group_name"];
    return dict;
}

@end
