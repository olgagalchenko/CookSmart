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
#import "CSEditIngredientVC.h"

@interface CSIngredientListVC ()

@property (nonatomic, readwrite, weak) id<CSIngredientListVCDelegate>delegate;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UISearchDisplayController* searchController;
@property (nonatomic, strong) CSIngredients* filteredIngredients;
@end

@implementation CSIngredientListVC

static NSString* CellIdentifier = @"Cell";


- (id)initWithDelegate:(id<CSIngredientListVCDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.delegate = delegate;
        self.title = @"Ingredients";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newIngredientAdded:) name:INGREDIENT_ADD_NOTIFICATION_NAME object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
    self.searchController.delegate = nil;
    self.searchController.searchResultsDataSource = nil;
    self.searchController.searchResultsDelegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeIngrList:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(editIngredient:)];
    
    NSIndexPath* firstCellPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger heightOfCell = [self tableView:self.tableView heightForRowAtIndexPath:firstCellPath];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, heightOfCell)];
    self.searchBar.delegate = self;
    
    self.tableView.contentOffset = CGPointMake(0,heightOfCell);
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    logViewChange(@"ingredient_list", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self ingredientsToSupplyDataForTableView:tableView] countOfIngredientGroups];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self ingredientsToSupplyDataForTableView:tableView] ingredientGroupAtIndex:section] countOfIngredients];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self ingredientsToSupplyDataForTableView:tableView] ingredientGroupAtIndex:section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.textLabel.text = [[[[self ingredientsToSupplyDataForTableView:tableView] ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSIngredientGroup *selectedIngredientGroup = [[self ingredientsToSupplyDataForTableView:tableView] ingredientGroupAtIndex:indexPath.section];
    CSIngredient *selectedIngredient = [selectedIngredientGroup ingredientAtIndex:indexPath.row];
    if ([selectedIngredientGroup respondsToSelector:@selector(originalIngredientGroup)])
    {
        selectedIngredientGroup = [selectedIngredientGroup performSelector:@selector(originalIngredientGroup) withObject:nil];
    }
    [self.delegate ingredientListVC:self
            selectedIngredientGroup:selectedIngredientGroup
                    ingredientIndex:[selectedIngredientGroup indexOfIngredient:selectedIngredient]];
    
    [self closeIngrList:nil];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    CSIngredientGroup *selectedIngredientGroup = [[self ingredientsToSupplyDataForTableView:tableView] ingredientGroupAtIndex:indexPath.section];
    CSIngredient *selectedIngredient = [selectedIngredientGroup ingredientAtIndex:indexPath.row];
    [self editIngredient:selectedIngredient];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't let people delete the final ingredient for now.
    // It's not clear what we want the UX to be when there aren't any ingredients.
    // For now, this is such an edge case that we'll just not support it.
    NSUInteger numGroups = [[CSIngredients sharedInstance] countOfIngredientGroups];
    return  (numGroups > 1) ||
            (numGroups == 1 && [[[CSIngredients sharedInstance] ingredientGroupAtIndex:0] countOfIngredients] > 1);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CSIngredients *ingredients = [self ingredientsToSupplyDataForTableView:tableView];
        CSIngredient *ingredientToDelete = [[ingredients ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row];
        NSUInteger numIngredientGroups = [ingredients countOfIngredientGroups];
        BOOL deleteSuccess = [ingredients deleteIngredientAtGroupIndex:indexPath.section ingredientIndex:indexPath.row];
        if (deleteSuccess)
        {
            logUserAction(@"ingredient_delete", [ingredientToDelete dictionary]);
            if (numIngredientGroups > [ingredients countOfIngredientGroups])
            {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        else
        {
            logIssue(@"ingredient_delete_fail", [ingredientToDelete dictionary]);
            [tableView reloadData];
        }
        if (tableView != self.tableView)
        {
            // Still need to update the base tableView regardless of which tableView we made the delete from.
            [self.tableView reloadData];
        }
    }
}

- (void)editIngredient:(id)sender
{
    CSIngredient* ingrToEdit;
    UIViewController *editVC;
    if (sender == self.navigationItem.rightBarButtonItem)
    {
        ingrToEdit = [[CSIngredient alloc] initWithName:@"" andDensity:125];
        editVC = [[CSEditIngredientVC alloc] initWithIngredient:ingrToEdit
                                                  withDoneBlock:^(CSIngredient* newIngr){
                                                      [[CSIngredients sharedInstance] addIngredient:newIngr];
                                                  }];

    }
    else if ([sender isKindOfClass:[CSIngredient class]])
    {
        ingrToEdit = (CSIngredient*)sender;
        editVC = [[CSEditIngredientVC alloc] initWithIngredient:ingrToEdit
                                                  withDoneBlock:^(CSIngredient* newIngr){
                                                      [[CSIngredients sharedInstance] editIngredient:newIngr];
                                                  }];

    }
    else
    {
        CSAssertFail(@"edit_ingredient_sender", @"The sender of the editIngredient: message should be either the ingredient to edit or the rightBarButtonItem.");
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
    
    self.filteredIngredients = [[CSIngredients alloc] initWithIngredientGroups:filteredGroupsArray];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    logUserAction(@"ingredient_filter_cancel", @{@"search_text" : searchBar.text});
}

#pragma mark - notification responders
- (void)newIngredientAdded:(NSNotification*)notificationObj
{
    [self.tableView reloadData];
}

#pragma mark - dismiss self
- (void)closeIngrList:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Misc Helpers

- (CSIngredients *)ingredientsToSupplyDataForTableView:(UITableView *)tableViewToSupplyDataFor
{
    CSIngredients *ingredients = nil;
    if (tableViewToSupplyDataFor == self.tableView)
    {
        ingredients = [CSIngredients sharedInstance];
    }
    else if (tableViewToSupplyDataFor == self.searchDisplayController.searchResultsTableView)
    {
        ingredients = self.filteredIngredients;
    }
    else
    {
        CSAssertFail(@"ingredients_list_vc_data_source", @"CSIngredientsListVC is not ready to supply data for %@", tableViewToSupplyDataFor);
    }
    return ingredients;
}

@end
