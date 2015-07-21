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
#import "CSUnitCollection.h"
#import "CSScaleVC.h"

#define CHOOSE_UNITS_TEXT @"Choose Units"

@interface CSConversionVC ()

@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIScrollView *ingredientPickerScrollView;

@property (strong, nonatomic) IBOutlet CSScaleVC* scaleVC;

@end

@implementation CSConversionVC

- (id)initWithIngredientGroupIndex:(NSUInteger)ingredientGroupIndex ingredientIndex:(NSUInteger)ingredientIndex
{
    self = [super initWithNibName:@"CSConversionVC" bundle:nil];
    if (self)
    {
        self.ingredientIndex = [[CSIngredients sharedInstance] flattenedIngredientIndexForGroupIndex:ingredientGroupIndex ingredientIndex:ingredientIndex];
        
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
                                                              toItem:self.ingredientPickerScrollView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:10];
    [self.view addConstraints:@[bottom, left, right, top]];
    self.ingredientPickerScrollView.scrollsToTop = NO;
    self.ingredientPickerScrollView.showsHorizontalScrollIndicator = NO;
    self.ingredientPickerScrollView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self selectIngredientAtIndex:self.ingredientIndex];
    logViewChange(@"conversion", [self.scaleVC analyticsAttributes]);
}

#pragma mark - Ingredient Picker

- (NSString *)nameForIngredientAtXOrigin:(CGFloat)xOrigin
{
    NSUInteger indexOfIngredient = (NSUInteger) (xOrigin/self.ingredientPickerScrollView.bounds.size.width);
    NSString *nameOfIngredient = nil;
    if (indexOfIngredient < [[CSIngredients sharedInstance] flattenedCountOfIngredients])
    {
        nameOfIngredient = [[[CSIngredients sharedInstance] ingredientAtFlattenedIngredientIndex:indexOfIngredient] name];
    }
    return nameOfIngredient;
}

- (void)refreshIngredientNameUI
{
    self.ingredientPickerScrollView.contentSize = CGSizeMake(self.ingredientPickerScrollView.bounds.size.width*[[CSIngredients sharedInstance] flattenedCountOfIngredients],
                                                             self.ingredientPickerScrollView.bounds.size.height);
    for (UIView *subview in self.ingredientPickerScrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    CGFloat initialXOffset = self.ingredientPickerScrollView.bounds.size.width*self.ingredientIndex;
    for (CGFloat xOrigin = initialXOffset; xOrigin <= initialXOffset + 2*self.ingredientPickerScrollView.bounds.size.width; xOrigin += self.ingredientPickerScrollView.bounds.size.width)
    {
        UIButton *ingredientButton = [UIButton buttonWithType:UIButtonTypeSystem];
        ingredientButton.frame = CGRectMake(xOrigin, 0, self.ingredientPickerScrollView.bounds.size.width, self.ingredientPickerScrollView.bounds.size.height);
        [ingredientButton setTitle:[self nameForIngredientAtXOrigin:xOrigin] forState:UIControlStateNormal];
        ingredientButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:MAJOR_BUTTON_FONT_SIZE];
        [ingredientButton setTitleColor:RED_LINE_COLOR forState:UIControlStateNormal];
        [ingredientButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [ingredientButton addTarget:self action:@selector(handleIngredientTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.ingredientPickerScrollView addSubview:ingredientButton];
    }
    self.ingredientPickerScrollView.contentOffset = CGPointMake(initialXOffset, 0);
}

- (void)handleIngredientTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] initWithDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CSAssert(scrollView == self.ingredientPickerScrollView, @"conversion_vc_wrong_scrollview_delegate",
             @"CSConversionVC doesn't expect to be delegate of a scrollview other than its ingredientPickerScrollView");
    CGFloat minVisibleX = self.ingredientPickerScrollView.contentOffset.x;
    CGFloat maxVisibleX = minVisibleX + self.ingredientPickerScrollView.bounds.size.width;
    NSUInteger numSubviews = self.ingredientPickerScrollView.subviews.count;
    CGFloat contentSize = self.ingredientPickerScrollView.contentSize.width;
    for (UIButton *button in self.ingredientPickerScrollView.subviews)
    {
        if (button.frame.origin.x + button.bounds.size.width < minVisibleX &&
            button.frame.origin.x + (numSubviews + 1)*button.bounds.size.width <= contentSize &&
            button.frame.origin.x + numSubviews*button.bounds.size.width)
        {
            button.frame = CGRectMake(button.frame.origin.x + numSubviews*button.bounds.size.width, 0, button.frame.size.width, button.frame.size.height);
            [button setTitle:[self nameForIngredientAtXOrigin:button.frame.origin.x] forState:UIControlStateNormal];
        }
        if (button.frame.origin.x > maxVisibleX &&
            button.frame.origin.x - numSubviews*button.bounds.size.width >= 0 &&
            button.frame.origin.x + (1 - numSubviews)*button.bounds.size.width >= minVisibleX)
        {
            button.frame = CGRectMake(button.frame.origin.x - numSubviews*button.bounds.size.width, 0, button.frame.size.width, button.frame.size.height);
            [button setTitle:[self nameForIngredientAtXOrigin:button.frame.origin.x] forState:UIControlStateNormal];
        }
    }
    
    CGFloat distanceToSnap = remainder(self.ingredientPickerScrollView.contentOffset.x, self.ingredientPickerScrollView.bounds.size.width);
    CGFloat distanceToMiddle = (self.ingredientPickerScrollView.bounds.size.width/2) - fabs(distanceToSnap);
    CGFloat scaleViewAlpha = distanceToMiddle/(self.ingredientPickerScrollView.bounds.size.width/2);
    [self.scaleVC setScalesAlpha:scaleViewAlpha];
    
    NSUInteger projectedIndex = (int)round(self.ingredientPickerScrollView.contentOffset.x/self.ingredientPickerScrollView.bounds.size.width);
    projectedIndex = MIN(MAX(0, projectedIndex), self.ingredientPickerScrollView.contentSize.width/self.ingredientPickerScrollView.bounds.size.width - 1);
    if (projectedIndex != self.ingredientIndex)
    {
        self.ingredientIndex = projectedIndex;
        [self refreshScalesWithCurrentIngredient];
        logUserAction(@"ingredient_switch", [self.scaleVC analyticsAttributes]);
    }
}

#pragma mark - CSIngredientListVCDelegate

- (void)ingredientListVC:(CSIngredientListVC *)listVC selectedIngredientGroup:(NSUInteger)ingredientGroupIndex ingredientIndex:(NSUInteger)index
{
    CSIngredientGroup *ingredientGroup = [[CSIngredients sharedInstance] ingredientGroupAtIndex:ingredientGroupIndex];
    CSIngredient *ingredient = [ingredientGroup ingredientAtIndex:index];
    logUserAction(@"ingredient_select", @{
                                          @"ingredient_group_name" : ingredientGroup.name,
                                          @"ingredient_name" : ingredient.name,
                                          @"ingredient_density" : [NSNumber numberWithFloat:ingredient.density],
                                          });
    [self selectIngredientAtIndex:[[CSIngredients sharedInstance] flattenedIngredientIndexForGroupIndex:ingredientGroupIndex ingredientIndex:index]];
}

- (void)selectIngredientAtIndex:(NSUInteger)ingredientIndex
{
    self.ingredientIndex = ingredientIndex;
    [self refreshIngredientNameUI];
    [self refreshScalesWithCurrentIngredient];
}

- (void)refreshScalesWithCurrentIngredient
{
    self.scaleVC.ingredient = [[CSIngredients sharedInstance] ingredientAtFlattenedIngredientIndex:self.ingredientIndex];
}

#pragma mark - Notifications

- (void)ingredientDeleted:(NSNotification *)notification
{
    // When an ingredient is deleted, our index into the ingredient group might change.
    // In the future we might want to put a better solution for this, but for now, we'll
    // just select the very first ingredient of the very first ingredient group and be done
    // with it.
    [self selectIngredientAtIndex:0];
}

#pragma mark - scaleVC delegate methods

- (void)scaleVCDidBeginChangingUnits:(CSScaleVC*)scaleVC
{
    [self iterateOverIngredientButtons:^(UIButton *ingredientButton) {
            ingredientButton.enabled = NO;
            [ingredientButton setTitle:CHOOSE_UNITS_TEXT forState:UIControlStateNormal];
    }];
    [self.ingredientPickerScrollView setScrollEnabled:NO];
}

- (void)scaleVCDidFinishChangingUnits:(CSScaleVC *)scaleVC
{
    [self iterateOverIngredientButtons:^(UIButton *ingredientButton) {
        ingredientButton.enabled = YES;
        [ingredientButton setTitle:[self nameForIngredientAtXOrigin:ingredientButton.frame.origin.x] forState:UIControlStateNormal];
    }];
    [self.ingredientPickerScrollView setScrollEnabled:YES];
}

- (void)iterateOverIngredientButtons:(void (^)(UIButton *))work
{
    for (UIButton *ingredientButton in self.ingredientPickerScrollView.subviews)
    {
        if ([ingredientButton isKindOfClass:[UIButton class]])
        {
            work(ingredientButton);
        }
    }
}

@end
