//
//  CSIngredientListVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientListVC.h"
#import "CSIngredients.h"
#import "CSIngredientGroup.h"
#import "CSIngredient.h"

@interface CSIngredientListVC ()

@property (nonatomic, readwrite, weak) id<CSIngredientListVCDelegate>delegate;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UISearchDisplayController* searchController;
@property (nonatomic, strong) CSIngredients* filtered;
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
    return (tableView == self.tableView) ? [[CSIngredients sharedInstance] countOfIngredientGroups] : [self.filtered countOfIngredientGroups];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (tableView == self.tableView) ? [[[CSIngredients sharedInstance] ingredientGroupAtIndex:section] countOfIngredients] : [[self.filtered ingredientGroupAtIndex:section] countOfIngredients];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (tableView == self.tableView) ? [[[CSIngredients sharedInstance] ingredientGroupAtIndex:section] name] : [[self.filtered ingredientGroupAtIndex:section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (tableView == self.tableView)
        cell.textLabel.text = [[[[CSIngredients sharedInstance] ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row] name];
    else
        cell.textLabel.text = [[[self.filtered ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        [self.delegate  ingredientListVC:self
                 selectedIngredientGroup:[[CSIngredients sharedInstance] ingredientGroupAtIndex:indexPath.section]
                         ingredientIndex:indexPath.row];
    else
        [self.delegate ingredientListVC:self selectedIngredientGroup:[self.filtered ingredientGroupAtIndex:indexPath.section] ingredientIndex:indexPath.row];
    
    [self closeIngrList:nil];
}

#pragma mark - search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray* filteredArray = [NSMutableArray array];
    
    for (CSIngredientGroup* group in [CSIngredients sharedInstance])
    {
        NSMutableArray* ingredients = [NSMutableArray array];
        for (CSIngredient* ingr in group)
        {
            if ([ingr.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [ingredients addObject:[ingr dictionary]];
            }
        }
        NSDictionary* groupDict = [[NSDictionary alloc] initWithObjectsAndKeys:ingredients, group.name, nil];
        [filteredArray addObject:groupDict];
    }
    
    self.filtered = [[CSIngredients alloc] initWithArray:filteredArray];
}

#pragma mark - dismiss self
- (void)closeIngrList:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
