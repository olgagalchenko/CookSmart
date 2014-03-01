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

#define UNIT_LABEL_HEIGHT 60

@interface CSUnitPicker ()
@property (weak, nonatomic) IBOutlet UIScrollView *volumeScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *weightScrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic)        CSVolumeUnit* volumeUnit;
@property (strong, nonatomic)        CSWeightUnit* weightUnit;
@end

@implementation CSUnitPicker

- (id)initWithVolumeUnit:(CSVolumeUnit*)volUnit andWeightUnit:(CSWeightUnit*)weightUnit
{
    NSArray* topViews = [[NSBundle mainBundle] loadNibNamed:@"CSUnitPicker" owner:self options:nil];
    self = [topViews firstObject];
    if (self)
    {
        addUnitLabels(self.volumeScrollView, [CSVolumeUnit class]);
        addUnitLabels(self.weightScrollView, [CSWeightUnit class]);
        
        self.volumeUnit = volUnit;
        self.weightUnit = weightUnit;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.volumeScrollView setContentSize:CGSizeMake(self.volumeScrollView.frame.size.width, self.volumeScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSVolumeUnit numUnits]-1))];
    [self.weightScrollView setContentSize:CGSizeMake(self.weightScrollView.frame.size.width, self.weightScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSWeightUnit numUnits]-1))];
    
    layoutUnitLabels(self.volumeScrollView, self.volumeUnit.name);
    layoutUnitLabels(self.weightScrollView, self.weightUnit.name);
}

- (IBAction)doneButtonPressed:(id)sender
{
    self.volumeUnit = [self centerVolumeUnit];
    self.weightUnit = [self centerWeightUnit];
    [self.delegate unitPicker:self pickedVolumeUnit:self.volumeUnit andWeightUnit:self.weightUnit];
}

static inline void addUnitLabels(UIScrollView* view, Class unitClass)
{
    for (int i = 0; i < [unitClass numUnits]; i++)
    {
        UILabel* unitLabel = [[UILabel alloc] init];
        unitLabel.text = [unitClass nameWithIndex:i];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:unitLabel];
    }
}

static inline void layoutUnitLabels(UIScrollView* view, NSString* selectedUnitName)
{
    NSUInteger selectedUnitIndex = NSNotFound;
    CGFloat yOrigin = view.frame.size.height/2 - UNIT_LABEL_HEIGHT/2;
    for (UIView* subview in [view subviews])
    {
        subview.frame = CGRectMake(0, yOrigin, view.frame.size.width, UNIT_LABEL_HEIGHT);
        yOrigin += UNIT_LABEL_HEIGHT;
        if ([subview isKindOfClass:[UILabel class]] && [((UILabel*)subview).text isEqualToString:selectedUnitName])
            selectedUnitIndex++;
    }
    
    [view setContentOffset:CGPointMake(0, selectedUnitIndex*UNIT_LABEL_HEIGHT) animated:YES];
}

- (void)snapScrollView:(UIScrollView*)scrollView toClosestUnit:(CGFloat)position
{
    CGFloat yOffset;
    CGFloat offsetFromSnap = remainder(position, UNIT_LABEL_HEIGHT);
    if (offsetFromSnap > UNIT_LABEL_HEIGHT/2)
        yOffset = position - offsetFromSnap + UNIT_LABEL_HEIGHT;
    else
        yOffset = position - offsetFromSnap;
    
    [scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
}

- (CSWeightUnit*)centerWeightUnit
{
    NSInteger index = self.weightScrollView.contentOffset.y/UNIT_LABEL_HEIGHT;
    return [[CSWeightUnit alloc] initWithIndex:index];
}

- (CSVolumeUnit*)centerVolumeUnit
{
    NSInteger index = self.volumeScrollView.contentOffset.y/UNIT_LABEL_HEIGHT;
    return [[CSVolumeUnit alloc] initWithIndex:index];

}

#pragma mark - scroll view delegate methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self snapScrollView:scrollView toClosestUnit:scrollView.contentOffset.y];
}
@end
