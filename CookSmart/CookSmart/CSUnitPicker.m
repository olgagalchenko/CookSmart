//
//  CSUnitPicker.m
//  CookSmart
//
//  Created by Olga Galchenko on 2/25/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSUnitPicker.h"
#import "CSWeightUnit.h"
#import "CSVolumeUnit.h"
#import "CSUnitPickerCenterLineView.h"

#define UNIT_LABEL_HEIGHT       60
#define CENTER_LINE_THICKNESS   2

@interface CSUnitPicker ()
@property (weak, nonatomic) IBOutlet UIScrollView *volumeScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *weightScrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) CSVolumeUnit* volumeUnit;
@property (strong, nonatomic) CSWeightUnit* weightUnit;
@property (weak, nonatomic) CSUnitPickerCenterLineView *centerLine;
@end

@implementation CSUnitPicker

+ (CSUnitPicker *)unitPickerWithCurrentVolumeUnit:(CSVolumeUnit*)volUnit andWeightUnit:(CSWeightUnit*)weightUnit
{
    NSArray* topViews = [[NSBundle mainBundle] loadNibNamed:@"CSUnitPicker" owner:nil options:nil];
    CSUnitPicker *unitPicker = [topViews firstObject];
    if (self)
    {
        addUnitLabels(unitPicker.volumeScrollView, [CSVolumeUnit class]);
        addUnitLabels(unitPicker.weightScrollView, [CSWeightUnit class]);
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
    [self.volumeScrollView setContentSize:CGSizeMake(self.volumeScrollView.frame.size.width, self.volumeScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSVolumeUnit numUnits]-1))];
    [self.weightScrollView setContentSize:CGSizeMake(self.weightScrollView.frame.size.width, self.weightScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSWeightUnit numUnits]-1))];
    
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
    self.volumeUnit = (CSVolumeUnit *)[self centerUnitForScrollView:self.volumeScrollView];
    self.weightUnit = (CSWeightUnit *)[self centerUnitForScrollView:self.weightScrollView];
    [self.delegate unitPicker:self pickedVolumeUnit:self.volumeUnit andWeightUnit:self.weightUnit];
}

static inline void addUnitLabels(UIScrollView* view, Class unitClass)
{
    for (int i = 0; i < [unitClass numUnits]; i++)
    {
        UILabel* unitLabel = [[UILabel alloc] init];
        unitLabel.text = [unitClass nameWithIndex:i];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        unitLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:unitLabel];
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

- (Class)unitClassForScrollView:(UIScrollView *)scrollView
{
    return self.weightScrollView == scrollView? [CSWeightUnit class] : [CSVolumeUnit class];
}

- (void)snapScrollView:(UIScrollView*)scrollView toClosestUnit:(CGFloat)position
{
    CGFloat yOffset;
    CGFloat offsetFromSnap = remainder(position, UNIT_LABEL_HEIGHT);
    if (offsetFromSnap > UNIT_LABEL_HEIGHT/2)
        yOffset = position - offsetFromSnap + UNIT_LABEL_HEIGHT;
    else
        yOffset = position - offsetFromSnap;
    yOffset = MIN(MAX(0, yOffset), UNIT_LABEL_HEIGHT*([[self unitClassForScrollView:scrollView] numUnits]-1));
    [scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    NSString *unitKind = @"unknown";
    NSString *unitName = unitKind;
    if (scrollView == self.volumeScrollView)
    {
        unitKind = @"volume";
        unitName = [[self unitForScrollView:self.volumeScrollView offset:yOffset] name];
    }
    else if (scrollView == self.weightScrollView)
    {
        unitKind = @"weight";
        unitName = [[self unitForScrollView:self.volumeScrollView offset:yOffset] name];
    }
    else
    {
        CSAssertFail(@"unknown_unit_scrollview", @"CSUnitPicker should only be taking care of the weight and volume unit scroll views.");
    }
    logUserAction(@"snap_to_unit", @{@"unit_kind" : unitKind, @"unit_name" : unitName});
}

- (CSUnit *)centerUnitForScrollView:(UIScrollView *)scrollView
{
    return [self unitForScrollView:scrollView offset:scrollView.contentOffset.y];
}

- (CSUnit *)unitForScrollView:(UIScrollView *)scrollView offset:(CGFloat)offset
{
    NSInteger index = offset/UNIT_LABEL_HEIGHT;
    return [[[self unitClassForScrollView:scrollView] alloc] initWithIndex:index];
}

#pragma mark - scroll view delegate methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self snapScrollView:scrollView toClosestUnit:scrollView.contentOffset.y];
}
@end
