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
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation CSUnitPicker

- (id)init
{
    NSArray* topViews = [[NSBundle mainBundle] loadNibNamed:@"CSUnitPicker" owner:self options:nil];
    self = [topViews firstObject];
    if (self)
    {
        addUnitLabels(self.volumeScrollView, [CSVolumeUnit class]);
        addUnitLabels(self.weightScrollView, [CSWeightUnit class]);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.volumeScrollView setContentSize:CGSizeMake(self.volumeScrollView.frame.size.width, self.volumeScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSVolumeUnit numUnits]-1))];
    [self.weightScrollView setContentSize:CGSizeMake(self.weightScrollView.frame.size.width, self.weightScrollView.frame.size.height + UNIT_LABEL_HEIGHT*([CSWeightUnit numUnits]-1))];
    
    resizeUnitLabels(self.volumeScrollView);
    resizeUnitLabels(self.weightScrollView);
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self.delegate unitPicker:self pickedVolumeUnit:nil andWeightUnit:nil];
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

static inline void resizeUnitLabels(UIScrollView* view)
{
    CGFloat yOrigin = view.frame.size.height/2 - UNIT_LABEL_HEIGHT/2;
    for (UIView* subview in [view subviews])
    {
        subview.frame = CGRectMake(0, yOrigin, view.frame.size.width, UNIT_LABEL_HEIGHT);
        yOrigin += UNIT_LABEL_HEIGHT;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end
