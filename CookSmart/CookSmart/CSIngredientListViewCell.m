//
//  CSIngredientListViewCell.m
//  CookSmart
//
//  Created by Vova Galchenko on 9/24/15.
//  Copyright © 2015 Olga Galchenko. All rights reserved.
//

#import "CSIngredientListViewCell.h"
#import "CSIngredientListVC.h"
#import "CSIngredient.h"
#import "CSIngredients.h"

@interface CSIngredientListViewCell()

@property (nonatomic, weak, readwrite) UIButton *detailButton;

@end

@implementation CSIngredientListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [detailButton setTintColor:RED_LINE_COLOR];
        self.accessoryView = detailButton;
        self.detailButton = detailButton;
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    }
    return self;
}

- (void)configureForListVC:(CSIngredientListVC *)listVC ingredient:(CSIngredient *)ingredient
{
    self.textLabel.text = [ingredient name];
    self.detailButton.tag = [[CSIngredients sharedInstance] flattenedIndexForIngredient:ingredient];
    [self.detailButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.detailButton addTarget:listVC action:@selector(detailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

@end
