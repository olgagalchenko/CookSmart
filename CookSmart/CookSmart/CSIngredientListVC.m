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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeIngrList:)];
    self.navigationItem.rightBarButtonItem = closeItem;
    
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

#pragma mark - search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
        NSAssert(NO, @"CSIngredientsListVC is not ready to supply data for %@", tableViewToSupplyDataFor);
    }
    return ingredients;
}

@end
