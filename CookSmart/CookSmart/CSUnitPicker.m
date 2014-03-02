//
//  CSUnitPicker.m
//  CookSmart
//
//  Created by Olga Galchenko on 2/25/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnitPicker.h"
#import "CSUnit.h"
#import "CSUnitPickerCenterLineView.h"
#import "CSUnitCollection.h"

#define UNIT_LABEL_HEIGHT       40
#define CENTER_LINE_THICKNESS   2

@interface CSUnitPicker ()
@property (weak, nonatomic) IBOutlet UIScrollView *volumeScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *weightScrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) CSUnit* volumeUnit;
@property (strong, nonatomic) CSUnit* weightUnit;
@property (weak, nonatomic) CSUnitPickerCenterLineView *centerLine;
@end

@implementation CSUnitPicker

+ (CSUnitPicker *)unitPickerWithCurrentVolumeUnit:(CSUnit*)volUnit andWeightUnit:(CSUnit*)weightUnit
{
    NSArray* topViews = [[NSBundle mainBundle] loadNibNamed:@"CSUnitPicker" owner:nil options:nil];
    CSUnitPicker *unitPicker = [topViews firstObject];
    if (unitPicker)
    {
        unitPicker.volumeScrollView.scrollsToTop = NO;
        unitPicker.weightScrollView.scrollsToTop = NO;
        addUnitLabels(unitPicker.volumeScrollView, [CSUnitCollection volumeUnits], unitPicker, @selector(unitTapped:));
        addUnitLabels(unitPicker.weightScrollView, [CSUnitCollection weightUnits], unitPicker, @selector(unitTapped:));
        CSUnitPickerCenterLineView *centerLine = [[CSUnitPickerCenterLineView alloc] init];
        centerLine.translatesAutoresizingMaskIntoConstraints = NO;
        [unitPicker insertSubview:centerLine atIndex:0];
        unitPicker.centerLine = centerLine;
        
        unitPicker.volumeUnit = volUnit;
        unitPicker.weightUnit = weightUnit;
    }
    return unitPicker;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.volumeScrollView setContentSize:CGSizeMake(self.volumeScrollView.frame.size.width, self.volumeScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([[CSUnitCollection volumeUnits] countOfUnits]-1))];
    [self.weightScrollView setContentSize:CGSizeMake(self.weightScrollView.frame.size.width, self.weightScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([[CSUnitCollection weightUnits] countOfUnits]-1))];
    
    layoutUnitLabels(self.volumeScrollView, self.volumeUnit.name, self.arrangement);
    layoutUnitLabels(self.weightScrollView, self.weightUnit.name, self.arrangement);
    self.centerLine.frame = CGRectMake(0, (self.arrangement == CSScaleVCArrangementScales)? (UNIT_LABEL_HEIGHT - CENTER_LINE_THICKNESS)/2 : (self.bounds.size.height - CENTER_LINE_THICKNESS)/2,
                                       self.bounds.size.width, CENTER_LINE_THICKNESS);
}

- (void)setArrangement:(CSScaleVCArrangement)arrangement
{
    CSAssert([[NSThread currentThread] isMainThread], @"unit_picker_arrangement_main_thread",
             @"You must set the CSUnitPicker's arrangement on the main thread.");
    _arrangement = arrangement;
    [self setNeedsLayout];
}

- (IBAction)doneButtonPressed:(id)sender
{
    self.volumeUnit = [self centerUnitForScrollView:self.volumeScrollView];
    self.weightUnit = [self centerUnitForScrollView:self.weightScrollView];
    [self.delegate unitPicker:self pickedVolumeUnit:self.volumeUnit andWeightUnit:self.weightUnit];
}

static inline void addUnitLabels(UIScrollView* view, CSUnitCollection* unitCollection, id gestureTarget, SEL gestureSelector)
{
    for (int i = 0; i < [unitCollection countOfUnits]; i++)
    {
        UILabel* unitLabel = [[UILabel alloc] init];
        unitLabel.text = [unitCollection unitAtIndex:i].name;
        unitLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        unitLabel.backgroundColor = [UIColor clearColor];
        unitLabel.userInteractionEnabled = YES;
        [view addSubview:unitLabel];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:gestureTarget action:gestureSelector];
        tapRecognizer.numberOfTapsRequired = 1;
        [unitLabel addGestureRecognizer:tapRecognizer];
    }
}

static inline void layoutUnitLabels(UIScrollView* view, NSString* selectedUnitName, CSScaleVCArrangement arrangement)
{
    NSUInteger selectedUnitIndex = NSNotFound;
    CGFloat yOrigin = view.bounds.size.height/2 - UNIT_LABEL_HEIGHT/2;
    for (int i = 0; i < view.subviews.count; i++)
    {
        UIView *subview = view.subviews[i];
        if (arrangement == CSScaleVCArrangementScales)
            subview.frame = CGRectMake(0, 0, view.bounds.size.width, UNIT_LABEL_HEIGHT);
        else if (arrangement == CSScaleVCArrangementUnitChoice)
            subview.frame = CGRectMake(0, yOrigin, view.bounds.size.width, UNIT_LABEL_HEIGHT);
        else
            CSAssertFail(@"unit_picker_invalid_arrangement", @"Only the Scales and UnitChoice arrangements are supported by CSUnitPicker. You've provided %d", arrangement);
        yOrigin += UNIT_LABEL_HEIGHT;
        if ([subview isKindOfClass:[UILabel class]] && [((UILabel*)subview).text isEqualToString:selectedUnitName])
            selectedUnitIndex = i;
    }
    
    [view setContentOffset:CGPointMake(0, (arrangement == CSScaleVCArrangementScales)? 0 : selectedUnitIndex*UNIT_LABEL_HEIGHT) animated:YES];
}

- (CSUnitCollection*)unitCollectionForScrollView:(UIScrollView *)scrollView
{
    return self.weightScrollView == scrollView? [CSUnitCollection weightUnits] : [CSUnitCollection volumeUnits];
}

- (void)snapScrollViewToClosestUnit:(UIScrollView*)scrollView
{
    CGFloat yOffset;
    CGFloat currentYPosition = scrollView.contentOffset.y;
    CGFloat offsetFromSnap = remainder(currentYPosition, UNIT_LABEL_HEIGHT);
    if (offsetFromSnap > UNIT_LABEL_HEIGHT/2)
        yOffset = currentYPosition - offsetFromSnap + UNIT_LABEL_HEIGHT;
    else
        yOffset = currentYPosition - offsetFromSnap;
    yOffset = MIN(MAX(0, yOffset), UNIT_LABEL_HEIGHT*([[self unitCollectionForScrollView:scrollView] countOfUnits]-1));
    [scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    logUserAction(@"snap_to_unit", [self analyticsDictionaryForScrollView:scrollView contentYOffset:yOffset]);
}

- (CSUnit *)centerUnitForScrollView:(UIScrollView *)scrollView
{
    return [self unitForScrollView:scrollView offset:scrollView.contentOffset.y];
}

- (CSUnit *)unitForScrollView:(UIScrollView *)scrollView offset:(CGFloat)offset
{
    NSInteger index = offset/UNIT_LABEL_HEIGHT;
    return [[self unitCollectionForScrollView:scrollView] unitAtIndex:index];
}

#pragma mark - scroll view delegate methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self snapScrollViewToClosestUnit:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self snapScrollViewToClosestUnit:scrollView];
}

- (void)unitTapped:(UITapGestureRecognizer *)tapRecognizer
{
    UIView *touchedUnitView = tapRecognizer.view;
    UIScrollView *scrollView = (UIScrollView *)touchedUnitView.superview;
    NSUInteger indexOfTouchedUnit = [scrollView.subviews indexOfObject:touchedUnitView];
    [scrollView setContentOffset:CGPointMake(0, indexOfTouchedUnit*UNIT_LABEL_HEIGHT) animated:YES];
    logUserAction(@"unit_tap", [self analyticsDictionaryForScrollView:scrollView contentYOffset:indexOfTouchedUnit*UNIT_LABEL_HEIGHT]);
}

#pragma mark - Misc. Helpers

- (NSDictionary *)analyticsDictionaryForScrollView:(UIScrollView *)scrollView contentYOffset:(CGFloat)contentYOffset
{
    NSString *unitKind = @"unknown";
    NSString *unitName = unitKind;
    CSUnit *unit;
    float unitConversionFactor = 0;
    if (scrollView == self.volumeScrollView)
    {
        unitKind = @"volume";
        unit = [self unitForScrollView:self.volumeScrollView offset:contentYOffset];
    }
    else if (scrollView == self.weightScrollView)
    {
        unitKind = @"weight";
        unit = [self unitForScrollView:self.weightScrollView offset:contentYOffset];
    }
    else
    {
        CSAssertFail(@"unknown_unit_scrollview", @"CSUnitPicker should only be taking care of the weight and volume unit scroll views.");
    }
    unitConversionFactor = unit.conversionFactor;
    unitName = unit.name;
    return @{
             @"unit_kind" : unitKind,
             @"unit_name" : unitName,
             @"unit_conversion_factor" : @(unitConversionFactor)
             };
}

@end
