//
//  CSIngredientListVC.m
//  CookSmart
//
//  Created by Olga Galchenko on 1/23/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "CSIngredientListVC.h"
#import "CSAppDelegate.h"
#import "CSConversionVC.h"
@interface CSIngredientListVC ()

@end

@implementation CSIngredientListVC

static NSString* CellIdentifier = @"Cell";


- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        delegate = (CSAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Down"] style:UIBarButtonItemStylePlain target:self action:@selector(closeIngrList:)];
    self.navigationItem.rightBarButtonItem = closeItem;
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
    return [[delegate ingrData] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray* ingrdOfType = [delegate ingredientsForSection:section];
    return [ingrdOfType count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [delegate ingredientTypeForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray* ingrOfType = [delegate ingredientsForSection:indexPath.section];
    
    cell.textLabel.text =[ingrOfType[indexPath.row] objectForKey:@"Name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[CSConversionVC conversionVC] changeIngredientTo:indexPath];
    [self closeIngrList:nil];
}

#pragma mark - dismiss self
- (void)closeIngrList:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
