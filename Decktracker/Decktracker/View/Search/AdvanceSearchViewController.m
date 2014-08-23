//
//  SearchViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AdvanceSearchViewController.h"
#import "AdvanceSearchResultsViewController.h"
#import "Database.h"
#import "FileManager.h"
#import "Magic.h"
#import "NewAdvanceSearchViewController.h"
#import "SimpleSearchViewController.h"

@implementation AdvanceSearchViewController
{
    NSMutableDictionary *_dictCurrentQuery;
    NSMutableDictionary *_dictCurrentSort;
}

@synthesize arrAdvanceSearches = _arrAdvanceSearches;
@synthesize tblView = _tblView;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *nsfrc = [[Database sharedInstance] advanceSearch:_dictCurrentQuery
                                                                      withSorter:_dictCurrentSort];
    
    self.fetchedResultsController = nsfrc;
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrAdvanceSearches = [[NSMutableArray alloc] initWithArray:[[FileManager sharedInstance] findAdvanceSearchFiles]];
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    self.tblView.editing = YES;
    
    [self.view addSubview:self.tblView];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(btnAddTapped:)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    self.navigationItem.title = @"Advance Search";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnAddTapped:(id) sender
{
    NewAdvanceSearchViewController *newAdvanceView = [[NewAdvanceSearchViewController alloc] init];
    
    newAdvanceView.mode = EditModeNew;
    [self.navigationController pushViewController:newAdvanceView animated:NO];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrAdvanceSearches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:indexPath.row];
    cell.textLabel.text = [[dict allKeys] firstObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:indexPath.row];
    NSArray *arrData = [[NSArray alloc] initWithContentsOfFile:[[dict allValues] firstObject]];
    _dictCurrentQuery = [arrData firstObject];
    _dictCurrentSort = [arrData lastObject];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    [hud showWhileExecuting:@selector(doSearch) onTarget:self withObject:nil animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:indexPath.row];
            
            [[FileManager sharedInstance] deleteAdvanceSearchFile:[[dict allKeys] firstObject]];
            [self.arrAdvanceSearches removeObject:dict];
            [tableView reloadData];
        }
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    
    AdvanceSearchResultsViewController *advanceSearchResultsView = [[AdvanceSearchResultsViewController alloc] init];
    advanceSearchResultsView.fetchedResultsController = self.fetchedResultsController;
    advanceSearchResultsView.fetchedResultsController.delegate = advanceSearchResultsView;
    advanceSearchResultsView.navigationItem.title = [NSString stringWithFormat:@"%tu Search Results", [self.fetchedResultsController.fetchedObjects count]];
    advanceSearchResultsView.queryToSave = _dictCurrentQuery;
    advanceSearchResultsView.sorterToSave = _dictCurrentSort;
    advanceSearchResultsView.mode = EditModeEdit;
    [self.navigationController pushViewController:advanceSearchResultsView animated:NO];
}

-(void) doSearch
{
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
