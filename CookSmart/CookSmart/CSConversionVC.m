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
#import "CSScaleView.h"
#import "CSUnit.h"
#import "CSVolumeUnit.h"
#import "CSWeightUnit.h"

@interface CSConversionVC ()

@property (nonatomic, readwrite, strong) CSIngredientGroup *ingredientGroup;
@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIButton *ingredientGroupNameButton;
@property (weak, nonatomic) IBOutlet UILabel *ingredientNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet CSScaleView *volumeScaleScrollView;
@property (weak, nonatomic) IBOutlet CSScaleView *weightScaleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (nonatomic, readwrite, assign) BOOL isSnapping;

@property (weak, nonatomic) IBOutlet UIButton *volumeUnit;
@property (weak, nonatomic) IBOutlet UIButton *weightUnit;

@property (strong, nonatomic) CSUnit* currentWeightUnit;
@property (strong, nonatomic) CSUnit* currentVolumeUnit;

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
        
        _currentWeightUnit = [[CSWeightUnit alloc] initWithIndex:0];
        _currentVolumeUnit = [[CSVolumeUnit alloc] initWithIndex:0];
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self refreshUI];
}

- (void)refreshUI
{
    if (self.ingredientIndex == 0)
        self.prevButton.enabled = NO;
    else
        self.prevButton.enabled = YES;
    
    if (self.ingredientIndex >= [self.ingredientGroup countOfIngredients]-1)
        self.nextButton.enabled = NO;
    else
        self.nextButton.enabled = YES;
    
    self.volumeUnit.tag = volume;
    self.weightUnit.tag = weight;

    CSIngredient *ingredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
    [self.ingredientGroupNameButton setTitle:[self.ingredientGroup name]
                                    forState:UIControlStateNormal];
    self.ingredientNameLabel.text = [ingredient name];
    float volumeInitialCenterValue = [self.volumeScaleScrollView getCenterValue] == 0? 2.0 : [self.volumeScaleScrollView getCenterValue];
    float volumeScale = 1.0;
    [self.volumeScaleScrollView configureScaleViewWithInitialCenterValue:volumeInitialCenterValue
                                                                   scale:volumeScale];
    
    float idealWeightScale = ingredient.density*volumeScale;
    NSUInteger humanReadableWeightScale = 1;
    if (idealWeightScale >=  10)
    {
        NSUInteger orderOfMagnitude = (NSUInteger) floor(log10(idealWeightScale));
        humanReadableWeightScale = idealWeightScale - (((NSUInteger)idealWeightScale)%(NSUInteger)pow(10, orderOfMagnitude));
    }
    
    float initialCenterValue = volumeInitialCenterValue*ingredient.density;
    [self.weightScaleScrollView configureScaleViewWithInitialCenterValue:initialCenterValue
                                                                   scale:humanReadableWeightScale];
    [self synchronizeVolumeAndWeight:self.volumeScaleScrollView cancelDeceleration:YES];
    [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
    
    
    
    [_volumeUnit setTitle:_currentVolumeUnit.name forState:UIControlStateNormal];
    [_weightUnit setTitle:_currentWeightUnit.name forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ingredientListVC:(CSIngredientListVC *)listVC selectedIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)index
{
    self.ingredientGroup = ingredientGroup;
    self.ingredientIndex = index;
    [self refreshUI];
}

- (IBAction)handlePreviousIngredientTap:(id)sender
{
    self.ingredientIndex--;
    [self refreshUI];
}

- (IBAction)handleNextIngredientTap:(id)sender
{
    self.ingredientIndex++;
    [self refreshUI];
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
    [self synchronizeVolumeAndWeight:scrollView cancelDeceleration:NO];
}

- (void)scaleViewTapped:(CSScaleView *)scaleView
{
    [self synchronizeVolumeAndWeight:self.volumeScaleScrollView cancelDeceleration:YES];
    [self synchronizeVolumeAndWeight:self.weightScaleScrollView cancelDeceleration:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self snapToHumanReadableValueOfScaleView:(CSScaleView *)scrollView];
    }
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
    }];
}

- (void)synchronizeVolumeAndWeight:(UIScrollView *)sourceOfTruth cancelDeceleration:(BOOL)cancelDeceleration
{
    if (sourceOfTruth == self.volumeScaleScrollView)
    {
        float volumeValue = [self.volumeScaleScrollView getCenterValue];
        [self.weightScaleScrollView setCenterValue:volumeValue*[[self.ingredientGroup ingredientAtIndex:self.ingredientIndex] density] cancelDeceleration:cancelDeceleration];
    }
    else if (sourceOfTruth == self.weightScaleScrollView)
    {
        float weightValue = [self.weightScaleScrollView getCenterValue];
        [self.volumeScaleScrollView setCenterValue:weightValue/[[self.ingredientGroup ingredientAtIndex:self.ingredientIndex] density] cancelDeceleration:cancelDeceleration];
    }
    self.volumeLabel.text = humanReadableValue([self.volumeScaleScrollView getCenterValue], nil);
    self.weightLabel.text = humanReadableValue([self.weightScaleScrollView getCenterValue], nil);
}

static NSDictionary *specialFractions;

static inline NSString *humanReadableValue(float rawValue, float *humanReadableValue)
{
    NSString *resultString = nil;
    if (rawValue >= 50)
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
        unitSheet = [[UIActionSheet alloc] initWithTitle:@"Volume Unit" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[CSVolumeUnit nameWithIndex:0], [CSVolumeUnit nameWithIndex:1], [CSVolumeUnit nameWithIndex:2], nil];
        unitSheet.tag = volume;
    }
    else
    {
        unitSheet = [[UIActionSheet alloc] initWithTitle:@"Weight Unit" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[CSWeightUnit nameWithIndex:0], [CSWeightUnit nameWithIndex:1], [CSWeightUnit nameWithIndex:2], nil];
        unitSheet.tag = weight;
    }
    [unitSheet showInView:self.view];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == volume)
        _currentVolumeUnit = [[CSVolumeUnit alloc] initWithIndex:buttonIndex];
    else if (actionSheet.tag == weight)
        _currentWeightUnit = [[CSWeightUnit alloc] initWithIndex:buttonIndex];
    
    [self refreshUI];
}

@end
