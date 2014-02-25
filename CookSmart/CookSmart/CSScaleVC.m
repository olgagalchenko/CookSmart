//
//  CSScaleVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 2/14/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSScaleVC.h"
#import "CSScaleView.h"
#import "CSIngredient.h"
#import "CSWeightUnit.h"
#import "CSVolumeUnit.h"

#define UNIT_LABEL_HEIGHT           44
#define UNIT_VERTICAL_PADDING       10
#define UNIT_LABEL_SPREAD           (150.0) // Unit labels will be spread over that many points

@interface CSScaleVC ()

@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIButton *volumeUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *weightUnitButton;
@property (weak, nonatomic) IBOutlet CSScaleView *volumeScaleScrollView;
@property (weak, nonatomic) IBOutlet CSScaleView *weightScaleScrollView;
@property (weak, nonatomic) IBOutlet UIView *scalesContainer;

@property (weak, nonatomic) UIPickerView *unitsPickerView;

@property (strong, nonatomic) CSWeightUnit* currentWeightUnit;
@property (strong, nonatomic) CSVolumeUnit* currentVolumeUnit;

@property (weak, nonatomic) UIView *unitLabelsContainer;
@property (weak, nonatomic) UIButton *unitChoiceDoneButton;

@property (nonatomic, readwrite, assign) BOOL isSnapping;

@end

typedef enum
{
    CSScaleVCArrangementScales,
    CSScaleVCArrangementUnitChoice,
} CSScaleVCArrangement;

@implementation CSScaleVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.syncsScales = YES;
        
        self.currentWeightUnit = [[CSWeightUnit alloc] initWithIndex:0];
        self.currentVolumeUnit = [[CSVolumeUnit alloc] initWithIndex:0];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.volumeScaleScrollView.scrollsToTop = NO;
    self.weightScaleScrollView.scrollsToTop = YES;
    self.scalesContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *unitLabelsContainer = [[UIView alloc] init];
    unitLabelsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:unitLabelsContainer
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.scalesContainer
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:unitLabelsContainer
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:unitLabelsContainer
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:unitLabelsContainer
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0];
    
    UIPickerView *unitsPickerView = [[UIPickerView alloc] init];
    unitsPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    unitsPickerView.delegate = self;
    unitsPickerView.dataSource = self;
    [unitLabelsContainer addSubview:unitsPickerView];
    self.unitsPickerView = unitsPickerView;
    
    
    UIButton *unitChoiceDoneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    unitChoiceDoneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [unitChoiceDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    unitChoiceDoneButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [unitLabelsContainer addSubview:unitChoiceDoneButton];
    [unitChoiceDoneButton addTarget:self action:@selector(commitUnitChoices:) forControlEvents:UIControlEventTouchUpInside];
    self.unitChoiceDoneButton = unitChoiceDoneButton;
    
    [self.view addSubview:unitLabelsContainer];
    [self.view addConstraints:@[top, left, height, width]];
    self.unitLabelsContainer = unitLabelsContainer;
    
    [self animateToArrangement:CSScaleVCArrangementScales];
}

- (void)setIngredient:(CSIngredient *)currIngredient
{
    _ingredient = currIngredient;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self refreshScalesUI];
    });
}

- (void)refreshScalesUI
{
#define DEFAULT_VOLUME  1.0
    float volumeInitialCenterValue = [self.volumeScaleScrollView getCenterValue] == 0? DEFAULT_VOLUME : [self.volumeScaleScrollView getCenterValue];
    float volumeScale = 1.0;
    
    float idealWeightScale = [self.ingredient densityWithVolumeUnit:self.currentVolumeUnit andWeightUnit:self.currentWeightUnit]*volumeScale;
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
        float idealVolumeScale = humanReadableWeightScale/[self.ingredient densityWithVolumeUnit:self.currentVolumeUnit andWeightUnit:self.currentWeightUnit];
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
    
    float initialCenterValue = volumeInitialCenterValue*[self.ingredient densityWithVolumeUnit:self.currentVolumeUnit andWeightUnit:self.currentWeightUnit];
    [self.weightScaleScrollView configureScaleViewWithInitialCenterValue:initialCenterValue
                                                                   scale:humanReadableWeightScale
                                                                  mirror:YES];
    [self synchronizeVolumeAndWeight:self.volumeScaleScrollView cancelDeceleration:YES];
    [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
    
    self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
    self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self synchronizeVolumeAndWeight:scrollView cancelDeceleration:NO];
    
    self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
    self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
    
    [self informDelegateOfDensityChangeIfNecessary];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // This is only called for one of the scale views, because other scrollviews have scrollsToTop = NO;
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
        [self.weightScaleScrollView setCenterValue:0 cancelDeceleration:YES];
        [self.volumeScaleScrollView setCenterValue:0 cancelDeceleration:YES];
    } completion:^(BOOL finished) {
        logUserAction(@"scroll_to_top", [self analyticsAttributes]);
    }];
    return NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
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
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
        self.isSnapping = YES;
        [scaleView setCenterValue:humanReadableFloat cancelDeceleration:YES];
        [self synchronizeVolumeAndWeight:scaleView cancelDeceleration:YES];
        self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
        self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
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
        [self informDelegateOfDensityChangeIfNecessary];
        logUserAction(valueSnapEventName, [self analyticsAttributes]);
    }];
}

- (void)synchronizeVolumeAndWeight:(UIScrollView *)sourceOfTruth cancelDeceleration:(BOOL)cancelDeceleration
{
    if (self.syncsScales)
    {
        float trueDensity = [self.ingredient densityWithVolumeUnit:self.currentVolumeUnit andWeightUnit:self.currentWeightUnit];
        if (sourceOfTruth == self.volumeScaleScrollView)
        {
            float volumeValue = [self.volumeScaleScrollView getCenterValue];
            [self.weightScaleScrollView setCenterValue:volumeValue*trueDensity
                                    cancelDeceleration:cancelDeceleration];
        }
        else if (sourceOfTruth == self.weightScaleScrollView)
        {
            float weightValue = [self.weightScaleScrollView getCenterValue];
            [self.volumeScaleScrollView setCenterValue:weightValue/trueDensity
                                    cancelDeceleration:cancelDeceleration];
        }
    }
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
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
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
        });
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
    if ([self.delegate respondsToSelector:@selector(scaleVCDidBeginChangingUnits:)])
        [self.delegate scaleVCDidBeginChangingUnits:self];
    
    logUserAction(@"begin_unit_change", [self analyticsAttributes]);
    [self animateToArrangement:CSScaleVCArrangementUnitChoice];
}

- (void)commitUnitChoices:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(scaleVCDidFinishChangingUnits:)])
        [self.delegate scaleVCDidFinishChangingUnits:self];
    
    logUserAction(@"commit_unit_change", [self analyticsAttributes]);
    [self animateToArrangement:CSScaleVCArrangementScales];
}

- (void)animateToArrangement:(CSScaleVCArrangement)arrangement
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION*2 animations:^
    {
        [self setConstraintsForArrangement:arrangement];
        [self.view layoutIfNeeded];
    }];
    self.weightUnitButton.enabled = self.volumeUnitButton.enabled = (arrangement == CSScaleVCArrangementScales);
    if (arrangement == CSScaleVCArrangementScales)
    {
        [self.weightUnitButton setTitle:self.currentWeightUnit.name forState:UIControlStateNormal];
        [self.volumeUnitButton setTitle:self.currentVolumeUnit.name forState:UIControlStateNormal];
    }
    else if (arrangement == CSScaleVCArrangementUnitChoice)
    {
        [self.weightUnitButton setTitle:@"Weight" forState:UIControlStateNormal];
        [self.volumeUnitButton setTitle:@"Volume" forState:UIControlStateNormal];
    }
    else
    {
        CSAssertFail(@"invalid_scale_vc_arrangement", @"Invalid scale VC arrangement: %d", arrangement);
    }
}

- (void)handleWeightUnitChange:(UITapGestureRecognizer *)tapRecognizer
{
    UILabel *weightUnitLabel = (UILabel *)tapRecognizer.view;
    self.currentWeightUnit = [[CSWeightUnit alloc] initWithName:weightUnitLabel.text];
    [self refreshScalesUI];
    logUserAction(@"weight_unit_change", [self analyticsAttributes]);
}

- (void)handleVolumeUnitChange:(UITapGestureRecognizer *)tapRecognizer
{
    UILabel *volumeUnitLabel = (UILabel *)tapRecognizer.view;
    self.currentVolumeUnit = [[CSVolumeUnit alloc] initWithName:volumeUnitLabel.text];
    [self refreshScalesUI];
    logUserAction(@"volume_unit_change", [self analyticsAttributes]);
}

- (void)setConstraintsForArrangement:(CSScaleVCArrangement)arrangement
{
    NSArray *constraints = [NSArray arrayWithArray:self.view.constraints];
    for (NSLayoutConstraint *constraint in constraints)
    {
        if ((constraint.firstItem == self.scalesContainer && constraint.secondItem == self.view) ||
            (constraint.firstItem == self.view && constraint.secondItem == self.scalesContainer))
        {
            [self.view removeConstraint:constraint];
        }
    }
    [self.unitLabelsContainer removeConstraints:self.unitLabelsContainer.constraints];
    
    NSLayoutConstraint *scalesTop, *scalesLeft = nil;
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0];
    switch (arrangement)
    {
        case CSScaleVCArrangementScales:
            scalesTop = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0];
            scalesLeft = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeLeft
                                                     multiplier:1.0
                                                       constant:0];
            break;
        case CSScaleVCArrangementUnitChoice:
            scalesTop = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0];
            scalesLeft = [NSLayoutConstraint constraintWithItem:self.scalesContainer
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeLeft
                                                     multiplier:1.0
                                                       constant:0];
            break;
        default:
            CSAssertFail(@"scale_vc_position", @"Invalid CSScaleVCPosition: %d", arrangement);
            break;
    }
    [self.view addConstraints:@[scalesTop, height, scalesLeft, width]];
    
    CGFloat constantVerticalOffset =    self.volumeUnitButton.bounds.size.height/2 // For the volume unit buttons at the top
                                        - UNIT_LABEL_HEIGHT/2 - UNIT_VERTICAL_PADDING/2; // For the done button at the bottom
    NSLayoutConstraint *pickerViewLeft = [NSLayoutConstraint constraintWithItem:self.unitsPickerView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.unitLabelsContainer
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0.0];
    NSLayoutConstraint *pickerViewYOriginFix = [NSLayoutConstraint constraintWithItem:self.unitsPickerView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.unitLabelsContainer
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:0.0];
    if (arrangement == CSScaleVCArrangementUnitChoice)
    {
        pickerViewYOriginFix = [NSLayoutConstraint constraintWithItem:self.unitsPickerView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.unitLabelsContainer
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:constantVerticalOffset];
    }
    NSLayoutConstraint *pickerViewWidth = [NSLayoutConstraint constraintWithItem:self.unitsPickerView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.unitLabelsContainer
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    // The pickerViewHeight is fixed
    [self.unitLabelsContainer addConstraints:@[pickerViewLeft, pickerViewWidth, pickerViewYOriginFix]];

    NSLayoutConstraint *yOriginFix = [NSLayoutConstraint constraintWithItem:self.unitChoiceDoneButton
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.unitLabelsContainer
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0];
    if (arrangement == CSScaleVCArrangementUnitChoice)
    {
        yOriginFix = [NSLayoutConstraint constraintWithItem:self.unitChoiceDoneButton
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.unitLabelsContainer
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:-UNIT_VERTICAL_PADDING];
    }
    NSLayoutConstraint *doneButtonXCenter = [NSLayoutConstraint constraintWithItem:self.unitChoiceDoneButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.unitLabelsContainer
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    NSLayoutConstraint *doneButtonWidth = [NSLayoutConstraint constraintWithItem:self.unitChoiceDoneButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.unitLabelsContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:0];
    NSLayoutConstraint *doneButtonHeight = [NSLayoutConstraint constraintWithItem:self.unitChoiceDoneButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:0
                                                                         constant:UNIT_LABEL_HEIGHT];
    [self.unitLabelsContainer addConstraints:@[yOriginFix, doneButtonHeight, doneButtonXCenter, doneButtonWidth]];
}

#pragma mark - UIPickerViewDataSource and Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2; // one for volume, one for weight
}

static inline Class unitClassForPickerViewComponent(NSInteger component)
{
    Class unitClass = nil;
    switch (component)
    {
        case 0:
            unitClass = [CSVolumeUnit class];
            break;
        case 1:
            unitClass = [CSWeightUnit class];
            break;
        default:
            CSAssertFail(@"pickerview_wrong_component", @"The units pickerview should only have two components, but we are being asked about component %d", component);
            break;
    }
    return unitClass;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [unitClassForPickerViewComponent(component) numUnits];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [unitClassForPickerViewComponent(component) nameWithIndex:row];
}

#pragma mark - Misc Helpers

- (NSDictionary *)analyticsAttributes
{
    return @{
             @"ingredient_name" : self.ingredient.name,
             @"ingredient_density" : [self.ingredient isIngredientDensityValid] ? [NSNumber numberWithFloat:self.ingredient.density] : [NSNumber numberWithFloat:FLT_MAX],
             @"volume_unit" : self.currentVolumeUnit.name,
             @"weight_unit" : self.currentWeightUnit.name,
             @"volume_value" : @([self.volumeScaleScrollView getCenterValue]),
             @"weight_value" : @([self.weightScaleScrollView getCenterValue]),
             };
}

- (void)informDelegateOfDensityChangeIfNecessary
{
    if (!self.syncsScales && self.delegate)
    {
        float currentDensity = ([self.weightScaleScrollView getCenterValue]/self.currentWeightUnit.conversionFactor)/([self.volumeScaleScrollView getCenterValue]/self.currentVolumeUnit.conversionFactor);
        if ([self.delegate respondsToSelector:@selector(scaleVC:densityDidChange:)])
            [self.delegate scaleVC:self densityDidChange:currentDensity];
    }
}

@end
