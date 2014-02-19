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

@interface CSScaleVC ()

@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIButton *volumeUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *weightUnitButton;
@property (weak, nonatomic) IBOutlet CSScaleView *volumeScaleScrollView;
@property (weak, nonatomic) IBOutlet CSScaleView *weightScaleScrollView;

@property (strong, nonatomic) CSWeightUnit* currentWeightUnit;
@property (strong, nonatomic) CSVolumeUnit* currentVolumeUnit;

@property (nonatomic, readwrite, assign) BOOL isSnapping;

@end

enum units
{
    volume = 0,
    weight = 1
};

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
    self.volumeUnitButton.tag = volume;
    self.weightUnitButton.tag = weight;
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
    
    [self.volumeUnitButton setTitle:self.currentVolumeUnit.name forState:UIControlStateNormal];
    [self.weightUnitButton setTitle:self.currentWeightUnit.name forState:UIControlStateNormal];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self synchronizeVolumeAndWeight:scrollView cancelDeceleration:NO];
    
    self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
    self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
    
    [self informDelegateOfScaleChangeIfNecessary];
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
    [UIView animateWithDuration:.2 animations:^{
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
        [self informDelegateOfScaleChangeIfNecessary];
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

#pragma mark - Misc Helpers

- (NSDictionary *)analyticsAttributes
{
    return @{
             @"ingredient_name" : self.ingredient.name,
             @"ingredient_density" : [NSNumber numberWithFloat:self.ingredient.density],
             @"volume_unit" : self.currentVolumeUnit.name,
             @"weight_unit" : self.currentWeightUnit.name,
             @"volume_value" : @([self.volumeScaleScrollView getCenterValue]),
             @"weight_value" : @([self.weightScaleScrollView getCenterValue]),
             };
}

- (void)informDelegateOfScaleChangeIfNecessary
{
    if (!self.syncsScales && self.delegate)
    {
        float currentDensity = ([self.weightScaleScrollView getCenterValue]/self.currentWeightUnit.conversionFactor)/([self.volumeScaleScrollView getCenterValue]/self.currentVolumeUnit.conversionFactor);
        [self.delegate scaleVC:self densityDidChange:currentDensity];
    }
}


@end
