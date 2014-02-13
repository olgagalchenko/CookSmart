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
@property (weak, nonatomic) IBOutlet CSScaleView *volumeScaleScrollView;
@property (weak, nonatomic) IBOutlet CSScaleView *weightScaleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIView *midlineView;
@property (weak, nonatomic) IBOutlet UIButton *volumeUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *weightUnitButton;

@property (nonatomic, readwrite, assign) BOOL isSnapping;

@property (strong, nonatomic) CSWeightUnit* currentWeightUnit;
@property (strong, nonatomic) CSVolumeUnit* currentVolumeUnit;

@end

enum units
{
    volume = 0,
    weight = 1
};

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
        
        self.currentWeightUnit = [[CSWeightUnit alloc] initWithIndex:0];
        self.currentVolumeUnit = [[CSVolumeUnit alloc] initWithIndex:0];
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
    self.volumeScaleScrollView.scrollsToTop = NO;
    self.weightScaleScrollView.scrollsToTop = YES;
    self.volumeUnitButton.tag = volume;
    self.weightUnitButton.tag = weight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    logViewChange(@"conversion", [self analyticsAttributes]);
}

#pragma mark -

static inline float density(CSIngredient *ingredient, CSVolumeUnit *volumeUnit, CSWeightUnit *weightUnit)
{
    return ingredient.density*(weightUnit.conversionFactor/volumeUnit.conversionFactor);
}

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

- (void)refreshScalesUI
{
    [self refreshButtons];
    CSIngredient *ingredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
#define DEFAULT_VOLUME  1.0
    float volumeInitialCenterValue = [self.volumeScaleScrollView getCenterValue] == 0? DEFAULT_VOLUME : [self.volumeScaleScrollView getCenterValue];
    float volumeScale = 1.0;
    
    float idealWeightScale = density(ingredient, self.currentVolumeUnit, self.currentWeightUnit)*volumeScale;
    NSUInteger humanReadableWeightScale = 1;
    if (idealWeightScale >=  5 && idealWeightScale < 10)
    {
        humanReadableWeightScale = 5;
    }
    else if (idealWeightScale >= 10)
    {
        NSUInteger orderOfMagnitude = (NSUInteger) floor(log10(idealWeightScale));
        humanReadableWeightScale = idealWeightScale - (((NSUInteger)idealWeightScale)%(NSUInteger)pow(10, orderOfMagnitude));
    }
    else
    {
        float idealVolumeScale = humanReadableWeightScale/density(ingredient, self.currentVolumeUnit, self.currentWeightUnit);
        volumeScale = 1;
        if (idealVolumeScale >= 5 && idealVolumeScale < 10)
        {
            volumeScale = 5;
        }
        else if (idealVolumeScale >= 10)
        {
            NSUInteger orderOfMagnitude = (NSUInteger) floor(log10(idealVolumeScale));
            volumeScale = idealVolumeScale - (((NSUInteger)idealVolumeScale)%(NSUInteger)pow(10, orderOfMagnitude));
        }
    }
    
    [self.volumeScaleScrollView configureScaleViewWithInitialCenterValue:volumeInitialCenterValue
                                                                   scale:volumeScale
                                                                  mirror:NO];
    
    float initialCenterValue = volumeInitialCenterValue*density(ingredient, self.currentVolumeUnit, self.currentWeightUnit);
    [self.weightScaleScrollView configureScaleViewWithInitialCenterValue:initialCenterValue
                                                                   scale:humanReadableWeightScale
                                                                  mirror:YES];
    [self synchronizeVolumeAndWeight:self.volumeScaleScrollView cancelDeceleration:YES];
    [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
    
    [self.volumeUnitButton setTitle:self.currentVolumeUnit.name forState:UIControlStateNormal];
    [self.weightUnitButton setTitle:self.currentWeightUnit.name forState:UIControlStateNormal];
}

- (void)refreshButtons
{
    [self.nextButton setEnabled:self.ingredientIndex < ([self.ingredientGroup countOfIngredients] - 1)];
    [self.prevButton setEnabled:self.ingredientIndex > 0];
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
    [self refreshScalesUI];
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollViewIsAScaleView(scrollView))
    {
        [self synchronizeVolumeAndWeight:scrollView cancelDeceleration:NO];
    }
    else if (scrollView == self.ingredientPickerScrollView)
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
        self.volumeScaleScrollView.alpha = scaleViewAlpha;
        self.weightScaleScrollView.alpha = scaleViewAlpha;
        self.volumeLabel.alpha = scaleViewAlpha;
        self.weightLabel.alpha = scaleViewAlpha;
        self.midlineView.alpha = scaleViewAlpha;

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
            [self refreshScalesUI];
        }
        
        _previousIngredientPickerDistanceToSnap = distanceToSnap;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && scrollViewIsAScaleView(scrollView))
    {
        [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // This is only called for one of the scale views, because other scrollviews have scrollsToTop = NO;
    [UIView animateWithDuration:.2 animations:^{
        [self.weightScaleScrollView setCenterValue:0 cancelDeceleration:YES];
        [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
    } completion:^(BOOL finished) {
        logUserAction(@"scroll_to_top", [self analyticsAttributes]);
    }];
    return NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollViewIsAScaleView(scrollView))
        [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
}

static inline BOOL scrollViewIsAScaleView(UIScrollView *scrollView)
{
    return [scrollView isKindOfClass:[CSScaleView class]];
}


- (void)scaleViewTapped:(CSScaleView *)scaleView
{
    [self synchronizeVolumeAndWeight:self.volumeScaleScrollView cancelDeceleration:YES];
    [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
}

- (void)snapToHumanReadableValueOfScaleView:(CSScaleView *)scaleView
{
    float humanReadableFloat = 0;
    humanReadableValue([scaleView getCenterValue], &humanReadableFloat);
    [UIView animateWithDuration:.2 animations:^{
        self.isSnapping = YES;
        [scaleView setCenterValue:humanReadableFloat cancelDeceleration:YES];
        [self synchronizeVolumeAndWeight:scaleView cancelDeceleration:YES];
    } completion:^(BOOL finished) {
        self.isSnapping = NO;
        NSString *valueSnapEventName = @"value_snap_unknown";
        if (scaleView == self.weightScaleScrollView)
        {
            valueSnapEventName = @"value_snap_weight";
        }
        else if (scaleView == self.volumeScaleScrollView)
        {
            valueSnapEventName = @"value_snap_volume";
        }
        logUserAction(valueSnapEventName, [self analyticsAttributes]);
    }];
}

- (void)synchronizeVolumeAndWeight:(UIScrollView *)sourceOfTruth cancelDeceleration:(BOOL)cancelDeceleration
{
    density([self.ingredientGroup ingredientAtIndex:self.ingredientIndex], self.currentVolumeUnit, self.currentWeightUnit);
    if (sourceOfTruth == self.volumeScaleScrollView)
    {
        float volumeValue = [self.volumeScaleScrollView getCenterValue];
        [self.weightScaleScrollView setCenterValue:volumeValue*density([self.ingredientGroup ingredientAtIndex:self.ingredientIndex], self.currentVolumeUnit, self.currentWeightUnit)
                                cancelDeceleration:cancelDeceleration];
    }
    else if (sourceOfTruth == self.weightScaleScrollView)
    {
        float weightValue = [self.weightScaleScrollView getCenterValue];
        [self.volumeScaleScrollView setCenterValue:weightValue/density([self.ingredientGroup ingredientAtIndex:self.ingredientIndex], self.currentVolumeUnit, self.currentWeightUnit)
                                cancelDeceleration:cancelDeceleration];
    }
    self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
    self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
}

static NSDictionary *specialFractions;

static inline NSString *humanReadableValue(float rawValue, float *humanReadableValue)
{
    NSString *resultString = nil;
#define THRESHOLD_FOR_SHOWING_FRACTIONS     50
    if (rawValue >= THRESHOLD_FOR_SHOWING_FRACTIONS)
    {
        float winningValue = round(rawValue);
        resultString = [NSString stringWithFormat:@"%1.0f", winningValue];
        if (humanReadableValue)
        {
            *humanReadableValue = winningValue;
        }
    }
    else
    {
        if (!specialFractions)
        {
            specialFractions = @{
                                 @0.125 : @"\u215B",
                                 @0.250 : @"\u00BC",
                                 @0.333 : @"\u2153",
                                 @0.375 : @"\u215C",
                                 @0.500 : @"\u00BD",
                                 @0.625 : @"\u215D",
                                 @0.666 : @"\u2154",
                                 @0.750 : @"\u00BE",
                                 @0.875 : @"\u215E",
                                 @1.0 : @"",
                                 [NSNull null] : @""
                                };
        }
        id winningKey = [NSNull null];
        int wholeNumber = (int)floor(rawValue);
        float actualFraction = rawValue - wholeNumber;
        float winningDifference = actualFraction;
        for (id number in specialFractions.allKeys)
        {
            if ([number respondsToSelector:@selector(floatValue)] &&
                winningDifference > fabs([number floatValue] - actualFraction))
            {
                winningDifference = fabs([number floatValue] - actualFraction);
                winningKey = number;
            }
        }
        float fractionValue = 0;
        if ([winningKey respondsToSelector:@selector(isEqualToNumber:)] &&
            [winningKey isEqualToNumber:@1.0])
        {
            wholeNumber++;
            fractionValue = 0;
        }
        else if (winningKey == [NSNull null])
        {
            fractionValue = 0;
        }
        else
        {
            fractionValue = [winningKey floatValue];
        }
        if (humanReadableValue)
        {
            *humanReadableValue = wholeNumber + fractionValue;
        }
        NSString *fractionString = [specialFractions objectForKey:winningKey];
        resultString = [NSString stringWithFormat:@"%@%@", (wholeNumber || winningKey == [NSNull null])?
                        [NSString stringWithFormat:@"%d", wholeNumber] : @"",
                        fractionString];
    }
    return resultString;
}

#pragma mark - unit change

- (IBAction)handleUnitTouch:(id)sender
{
    UIActionSheet* unitSheet;
    if (((UILabel*)sender).tag == volume)
    {
        unitSheet = [[UIActionSheet alloc] initWithTitle:@"Volume Unit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[CSVolumeUnit nameWithIndex:0], [CSVolumeUnit nameWithIndex:1], [CSVolumeUnit nameWithIndex:2], nil];
        unitSheet.tag = volume;
    }
    else
    {
        unitSheet = [[UIActionSheet alloc] initWithTitle:@"Weight Unit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[CSWeightUnit nameWithIndex:0], [CSWeightUnit nameWithIndex:1], [CSWeightUnit nameWithIndex:2], nil];
        unitSheet.tag = weight;
    }
    [unitSheet showInView:self.view];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3)
        return;
    
    if (actionSheet.tag == volume)
    {
        self.currentVolumeUnit = [[CSVolumeUnit alloc] initWithIndex:buttonIndex];
        logUserAction(@"volume_unit_change", [self analyticsAttributes]);
    }
    else if (actionSheet.tag == weight)
    {
        self.currentWeightUnit = [[CSWeightUnit alloc] initWithIndex:buttonIndex];
        logUserAction(@"weight_unit_change", [self analyticsAttributes]);
    }
    [self refreshScalesUI];
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
             @"volume_unit" : self.currentVolumeUnit.name,
             @"weight_unit" : self.currentWeightUnit.name,
             @"volume_value" : @([self.volumeScaleScrollView getCenterValue]),
             @"weight_value" : @([self.weightScaleScrollView getCenterValue]),
             };
}

@end
