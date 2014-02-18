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

@interface CSConversionVC ()
{
    CGFloat _previousIngredientPickerDistanceToSnap;
}

@property (nonatomic, readwrite, strong) CSIngredientGroup *ingredientGroup;
@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIScrollView *ingredientPickerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *ingredientGroupNameButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, readwrite, assign) BOOL isSnapping;

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
    self.ingredientPickerScrollView.scrollsToTop = NO;
    
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
                                                              toItem:self.ingredientPickerScrollView
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

- (NSString *)nameForIngredientAtXOrigin:(CGFloat)xOrigin
{
    NSUInteger indexOfIngredient = (NSUInteger) (xOrigin/self.ingredientPickerScrollView.bounds.size.width);
    NSString *nameOfIngredient = nil;
    if (indexOfIngredient < [self.ingredientGroup countOfIngredients])
    {
        nameOfIngredient = [[self.ingredientGroup ingredientAtIndex:indexOfIngredient] name];
    }
    return nameOfIngredient;
}

- (void)refreshIngredientGroupUI
{
    [self.ingredientGroupNameButton setTitle:[self.ingredientGroup name] forState:UIControlStateNormal];
    self.ingredientPickerScrollView.contentSize = CGSizeMake(self.ingredientPickerScrollView.bounds.size.width*[self.ingredientGroup countOfIngredients], self.ingredientPickerScrollView.bounds.size.height);
    for (UIView *subview in self.ingredientPickerScrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    CGFloat initialXOffset = self.ingredientPickerScrollView.bounds.size.width*self.ingredientIndex;
    for (CGFloat x = initialXOffset; x <= initialXOffset + 2*self.ingredientPickerScrollView.bounds.size.width; x += self.ingredientPickerScrollView.bounds.size.width)
    {
        UILabel *label = createIngredientLabel();
        label.frame = CGRectMake(x, 0, self.ingredientPickerScrollView.bounds.size.width, self.ingredientPickerScrollView.bounds.size.height);
        label.text = [self nameForIngredientAtXOrigin:x];
        [self.ingredientPickerScrollView addSubview:label];
    }
    self.ingredientPickerScrollView.contentOffset = CGPointMake(initialXOffset, 0);
}



- (void)refreshButtons
{
    [self.nextButton setEnabled:self.ingredientIndex < ([self.ingredientGroup countOfIngredients] - 1)];
    [self.prevButton setEnabled:self.ingredientIndex > 0];
}

- (void)refreshScalesWithCurrentIngredient
{
    self.scaleVC.currIngredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
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
    [self refreshIngredientGroupUI];
    [self refreshButtons];
    
    [self refreshScalesWithCurrentIngredient];
}

- (IBAction)handlePreviousIngredientTap:(id)sender
{
    if (self.ingredientPickerScrollView.contentOffset.x >= self.ingredientPickerScrollView.bounds.size.width &&
        remainder(self.ingredientPickerScrollView.contentOffset.x, self.ingredientPickerScrollView.bounds.size.width) == 0.0)
        [self.ingredientPickerScrollView setContentOffset:CGPointMake(self.ingredientPickerScrollView.contentOffset.x - self.ingredientPickerScrollView.bounds.size.width, 0)
                                             animated:YES];
}

- (IBAction)handleNextIngredientTap:(id)sender
{
    if (self.ingredientPickerScrollView.contentOffset.x < self.ingredientPickerScrollView.contentSize.width - self.ingredientPickerScrollView.bounds.size.width && remainder(self.ingredientPickerScrollView.contentOffset.x, self.ingredientPickerScrollView.bounds.size.width) == 0.0)
        [self.ingredientPickerScrollView setContentOffset:CGPointMake(self.ingredientPickerScrollView.contentOffset.x + self.ingredientPickerScrollView.bounds.size.width, 0)
                                             animated:YES];
}

- (IBAction)handleIngredientGroupTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] initWithDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - scroll view delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   if (scrollView == self.ingredientPickerScrollView)
    {
        CGFloat minVisibleX = self.ingredientPickerScrollView.contentOffset.x;
        CGFloat maxVisibleX = minVisibleX + self.ingredientPickerScrollView.bounds.size.width;
        NSUInteger numLabels = self.ingredientPickerScrollView.subviews.count;
        CGFloat contentSize = self.ingredientPickerScrollView.contentSize.width;
        for (UILabel *label in self.ingredientPickerScrollView.subviews)
        {
            if (label.frame.origin.x + label.bounds.size.width < minVisibleX &&
                label.frame.origin.x + (numLabels + 1)*label.bounds.size.width <= contentSize &&
                label.frame.origin.x + numLabels*label.bounds.size.width <= maxVisibleX)
            {
                label.frame = CGRectMake(label.frame.origin.x + numLabels*label.bounds.size.width, 0, label.frame.size.width, label.frame.size.height);
                label.text = [self nameForIngredientAtXOrigin:label.frame.origin.x];
            }
            if (label.frame.origin.x > maxVisibleX &&
                label.frame.origin.x - numLabels*label.bounds.size.width >= 0 &&
                label.frame.origin.x + (1 - numLabels)*label.bounds.size.width >= minVisibleX)
            {
                label.frame = CGRectMake(label.frame.origin.x - numLabels*label.bounds.size.width, 0, label.frame.size.width, label.frame.size.height);
                label.text = [self nameForIngredientAtXOrigin:label.frame.origin.x];
            }
        }
        
        CGFloat distanceToSnap = remainder(self.ingredientPickerScrollView.contentOffset.x, self.ingredientPickerScrollView.bounds.size.width);
        CGFloat distanceToMiddle = (self.ingredientPickerScrollView.bounds.size.width/2) - fabs(distanceToSnap);
        CGFloat scaleViewAlpha = distanceToMiddle/(self.ingredientPickerScrollView.bounds.size.width/2);
        
        self.scaleVC.view.alpha = scaleViewAlpha;
        
        if (distanceToMiddle < self.ingredientPickerScrollView.bounds.size.width/4 && (_previousIngredientPickerDistanceToSnap >= 0 ^ distanceToSnap >= 0))
        {
            // Let's reflect the change of ingredient on the scale
            if (_previousIngredientPickerDistanceToSnap > 0)
            {
                self.ingredientIndex++;
            }
            else
            {
                self.ingredientIndex--;
            }
            logUserAction(@"ingredient_switch", [self analyticsAttributes]);
            [self refreshScalesWithCurrentIngredient];
            [self refreshButtons];
        }
        
        _previousIngredientPickerDistanceToSnap = distanceToSnap;
    }
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

#pragma mark - Misc Helpers

- (NSDictionary *)analyticsAttributes
{
    CSIngredient *ingredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
    return @{
             @"ingredient_group_name" : self.ingredientGroup.name,
             @"ingredient_name" : ingredient.name,
             @"ingredient_density" : [NSNumber numberWithFloat:ingredient.density],
             @"volume_value" : @([_scaleVC volumeValue]),
             @"weight_value" : @([_scaleVC weightValue]),
             };
}

@end
