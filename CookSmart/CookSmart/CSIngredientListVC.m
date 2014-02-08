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
    return [[CSIngredients sharedInstance] countOfIngredientGroups];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[CSIngredients sharedInstance] ingredientGroupAtIndex:section] countOfIngredients];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[CSIngredients sharedInstance] ingredientGroupAtIndex:section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [[[[CSIngredients sharedInstance] ingredientGroupAtIndex:indexPath.section] ingredientAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate ingredientListVC:self
            selectedIngredientGroup:[[CSIngredients sharedInstance] ingredientGroupAtIndex:indexPath.section]
                    ingredientIndex:indexPath.row];
    [self closeIngrList:nil];
}

#pragma mark - dismiss self
- (void)closeIngrList:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
