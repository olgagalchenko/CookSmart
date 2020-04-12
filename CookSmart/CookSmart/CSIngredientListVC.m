//
//  CSIngredientListVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientListVC.h"
#import "CSIngredients.h"
#import "CSFilteredIngredientGroup.h"
#import "CSIngredient.h"
#import "CSIngredientListViewCell.h"
#import "CSRecentsIngredientGroup.h"
#import "cake-Swift.h"

@interface CSIngredientListVC ()

@property (nonatomic, readwrite, weak) id<CSIngredientListVCDelegate>delegate;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UIButton* resetToDefaults;
@property (nonatomic, strong) CSIngredients* filteredIngredients;

@end

@implementation CSIngredientListVC

static NSString* CellIdentifier = @"Cell";
static const NSUInteger ResetToDefaultsHeight = 40;

- (id)initWithDelegate:(id<CSIngredientListVCDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.delegate = delegate;
        self.title = @"Ingredients";
    }
    return self;
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[CSIngredientListViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeIngrList:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    [self.navigationItem.leftBarButtonItem setTintColor:RED_LINE_COLOR];

    UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(editIngredient:)];
    add.tintColor = RED_LINE_COLOR;
    self.navigationItem.rightBarButtonItem = add;
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    titleView.text = self.title;
    titleView.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.resetToDefaults = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, ResetToDefaultsHeight)];
    [self.resetToDefaults addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetToDefaults setTitle:@"Reset to Defaults" forState:UIControlStateNormal];
    [self.resetToDefaults setTitleColor:BACKGROUND_COLOR forState:UIControlStateNormal];
    [self.resetToDefaults.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:17]];
    self.resetToDefaults.backgroundColor = RED_LINE_COLOR;
    [self showHideResetToDefaults];
    
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + self.searchBar.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    logViewChange(@"ingredient_list", nil);
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self ingredientsToSupplyData] countOfIngredientGroups];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self ingredientsToSupplyData] ingredientGroupAtIndex:section] countOfIngredients];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self ingredientsToSupplyData] ingredientGroupAtIndex:section] name];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = [@"   " stringByAppendingString:[[[self ingredientsToSupplyData] ingredientGroupAtIndex:section] name]];
    headerLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15];
    headerLabel.backgroundColor = BACKGROUND_COLOR;
    return headerLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSIngredientListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CSIngredient *ingredient = [[[self ingredientsToSupplyData] ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row];
    [cell configureForListVC:self ingredient:ingredient];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSIngredientGroup *selectedIngredientGroup = [[self ingredientsToSupplyData] ingredientGroupAtIndex:indexPath.section];
    CSIngredient *selectedIngredient = [selectedIngredientGroup ingredientAtIndex:indexPath.row];
    if ([selectedIngredientGroup respondsToSelector:@selector(originalIngredientGroup)])
    {
        selectedIngredientGroup = [selectedIngredientGroup performSelector:@selector(originalIngredientGroup) withObject:nil];
    }
    [self.delegate ingredientListVC:self
            selectedIngredientGroup:[[CSIngredients sharedInstance] indexOfIngredientGroup:selectedIngredientGroup]
                    ingredientIndex:[selectedIngredientGroup indexOfIngredient:selectedIngredient]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)detailButtonTapped:(id)sender
{
    NSUInteger flattenedIngredientIndex = [(UIButton *)sender tag];
    if (flattenedIngredientIndex != NSNotFound)
        [self editIngredient:[[CSIngredients sharedInstance] ingredientAtFlattenedIngredientIndex:flattenedIngredientIndex]];
    else
        CSAssertFail(@"detail_button_unfound_ingredient", @"Wasn't able to find the flattened ingredient index for this button.");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numGroups = [[CSIngredients sharedInstance] countOfIngredientGroups];
    CSIngredientGroup *ingrGroup = [[CSIngredients sharedInstance] ingredientGroupAtIndex:indexPath.section];
    // Don't allow deletions from synthetic groups.
    return  !ingrGroup.isSynthetic &&
                // Don't let people delete the final ingredient for now.
                // It's not clear what we want the UX to be when there aren't any ingredients.
                // For now, this is such an edge case that we'll just not support it.
                ((numGroups > 1) || (numGroups == 1 && [[[CSIngredients sharedInstance] ingredientGroupAtIndex:0] countOfIngredients] > 1));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CSIngredients *ingredients = [self ingredientsToSupplyData];
        CSRecentsIngredientGroup *beforeChangeRecents = ingredients.recents;
        CSIngredientGroup *ingredientGroup = [ingredients ingredientGroupAtIndex:indexPath.section];
        CSIngredient *ingredientToDelete = [ingredientGroup ingredientAtIndex:indexPath.row];
        BOOL needToDeleteFromRecents = beforeChangeRecents && [beforeChangeRecents indexOfIngredient:ingredientToDelete] != NSNotFound;
        BOOL deleteSuccess = [ingredients deleteIngredientAtGroupIndex:indexPath.section ingredientIndex:indexPath.row];
        if (deleteSuccess)
        {
            logUserAction(@"ingredient_delete", [ingredientToDelete dictionaryForAnalytics]);
            
            [tableView beginUpdates];
            if (ingredientGroup.countOfIngredients == 0)
            {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            if (needToDeleteFromRecents)
            {
                CSRecentsIngredientGroup *afterChangeRecents = ingredients.recents;
                if (afterChangeRecents == nil)
                {
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                {
                    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[beforeChangeRecents indexOfIngredient:ingredientToDelete] inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            [tableView endUpdates];
        }
        else
        {
            logIssue(@"ingredient_delete_fail", [ingredientToDelete dictionaryForAnalytics]);
        }
    }
}

- (void)editIngredient:(id)sender
{
    UIViewController *editVC;
    if (sender == self.navigationItem.rightBarButtonItem)
    {
      editVC = [[EditIngredientViewController alloc] initWithIngredient: nil];
    }
    else if ([sender isKindOfClass:[CSIngredient class]])
    {
      CSIngredient *ingredientToEdit = (CSIngredient *)sender;
      editVC = [[EditIngredientViewController alloc] initWithIngredient:ingredientToEdit];
    }
    else
    {
        CSAssertFail(@"edit_ingredient_sender", @"The sender of the editIngredient: message should be rightBarButtonItem.");
    }
        
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    logUserAction(@"ingredient_filter", @{@"search_text" : searchText});
    
    NSMutableArray* filteredGroupsArray = [NSMutableArray array];
    
    for (CSIngredientGroup* group in [CSIngredients sharedInstance])
    {
        if ([group isSynthetic]) {
            continue;
        }
        NSMutableArray* ingredients = [NSMutableArray array];
        for (CSIngredient* ingr in group)
        {
            if ([ingr.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [ingredients addObject:ingr];
            }
        }
        if (ingredients.count > 0)
        {
            CSFilteredIngredientGroup *filteredIngredientGroup = [CSFilteredIngredientGroup filteredIngredientGroupWithIngredients:ingredients name:group.name originalIngredientGroup:group];
            [filteredGroupsArray addObject:filteredIngredientGroup];
        }
    }
    
    self.filteredIngredients = [[CSIngredients alloc] initWithIngredientGroups:filteredGroupsArray synthesizeGroups:NO];
    [self refreshData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    logUserAction(@"ingredient_filter_cancel", @{@"search_text" : searchBar.text});
}

#pragma mark - reset to defaults
- (void)refreshData
{
    [[CSIngredients sharedInstance] refreshRecents];
    [self.tableView reloadData];
    [self showHideResetToDefaults];
}

- (void)showHideResetToDefaults
{
    if ([[NSFileManager defaultManager] contentsEqualAtPath:pathToIngredientsOnDisk() andPath:pathToIngredientsInBundle()])
        self.tableView.tableFooterView = nil;
    else
        self.tableView.tableFooterView = self.resetToDefaults;
}

- (void)resetButtonAction:(id)sender
{
    UIAlertController* alertController = [UIAlertController
                                          alertControllerWithTitle:@"Are you sure?"
                                          message:@"Resetting to defaults will remove all your added and edited ingredients."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    UIAlertAction* resetAction = [UIAlertAction
                                  actionWithTitle:@"Reset"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * _Nonnull action) {
        self.tableView.tableFooterView = nil;
        
        [[CSIngredients sharedInstance] deleteAllSavedIngredients];
        [self refreshData];
        NSIndexPath* firstCellPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:firstCellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:resetAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - dismiss self
- (void)closeIngrList:(id)sender
{
    // When closing the ingredient list, always select the very first item – the one most recently looked at.
    [self.delegate ingredientListVC:self
            selectedIngredientGroup:0
                    ingredientIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Misc Helpers

- (CSIngredients *)ingredientsToSupplyData
{
    CSIngredients *ingredients = nil;
    if ([self.searchBar.text isEqualToString:@""] || !self.searchBar.text)
    {
        ingredients = [CSIngredients sharedInstance];
    }
    else
    {
        ingredients = self.filteredIngredients;
    }

    return ingredients;
}

@end
