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

@interface CSConversionVC ()

@property (nonatomic, readwrite, strong) CSIngredientGroup *ingredientGroup;
@property (nonatomic, readwrite, assign) NSUInteger ingredientIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ingredientNameBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet CSScaleView *volumeScaleScrollView;
@property (weak, nonatomic) IBOutlet CSScaleView *weightScaleScrollView;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshUI];
}

- (void)refreshUI
{
    self.navigationItem.title = self.ingredientGroup.name;
    self.ingredientNameBarButtonItem.title = [[self.ingredientGroup ingredientAtIndex:self.ingredientIndex] name];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List"] style:UIBarButtonItemStylePlain target:self action:@selector(onIngrTap:)];
    
    if (_ingredientIndex == 0)
        _prevButton.enabled = NO;
    else
        _prevButton.enabled = YES;
    
    if (_ingredientIndex >= [_ingredientGroup countOfIngredients]-1)
        _nextButton.enabled = NO;
    else
        _nextButton.enabled = YES;

    CSIngredient *ingredient = [self.ingredientGroup ingredientAtIndex:self.ingredientIndex];
    self.ingredientNameBarButtonItem.title = [ingredient name];
    float volumeInitialCenterValue = 2.0;
    float volumeScale = 1.0;
    [self.volumeScaleScrollView configureScaleViewWithInitialCenterValue:volumeInitialCenterValue
                                                                   scale:volumeScale
                                                        scaleDisplayMode:CSScaleViewScaleDisplayModeRight];
    
    float idealWeightScale = ingredient.density*volumeScale;
    NSUInteger humanReadableWeightScale = 1;
    if (idealWeightScale >=  10)
    {
        NSUInteger orderOfMagnitude = (NSUInteger) floor(log10(idealWeightScale));
        humanReadableWeightScale = idealWeightScale - (((NSUInteger)idealWeightScale)%(NSUInteger)pow(10, orderOfMagnitude));
    }
    
    float initialCenterValue = volumeInitialCenterValue*ingredient.density;
    [self.weightScaleScrollView configureScaleViewWithInitialCenterValue:initialCenterValue
                                                                   scale:humanReadableWeightScale
                                                        scaleDisplayMode:CSScaleViewScaleDisplayModeLeft];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onIngrTap:(id)sender
{
    CSIngredientListVC* ingrListVC = [[CSIngredientListVC alloc] initWithDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:ingrListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)ingredientListVC:(CSIngredientListVC *)listVC selectedIngredientGroup:(CSIngredientGroup *)ingredientGroup ingredientIndex:(NSUInteger)index
{
    self.ingredientGroup = ingredientGroup;
    self.ingredientIndex = index;
    [self refreshUI];
}

- (IBAction)onPrevIngrTap:(id)sender
{
    _ingredientIndex--;
    [self refreshUI];
}

- (IBAction)onNextIngrTap:(id)sender
{
    _ingredientIndex++;
    [self refreshUI];
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
}

@end
