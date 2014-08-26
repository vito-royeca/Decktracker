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

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

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
    
    [self.view addSubview:self.tblView];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(btnAddTapped:)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    self.navigationItem.title = @"Advance Search";
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Advance Search"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnAddTapped:(id) sender
{
    NewAdvanceSearchViewController *view = [[NewAdvanceSearchViewController alloc] init];
    
    view.mode = EditModeNew;
    [self.navigationController pushViewController:view animated:NO];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:indexPath.row];
    NSData *data = [NSData dataWithContentsOfFile:[[dict allValues] firstObject]];
    NSArray *arrData = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Advance Search"
                                                        message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [[dict allKeys] firstObject]]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:self.tblView.indexPathForSelectedRow.row];
        
        [[FileManager sharedInstance] deleteAdvanceSearchFile:[[dict allKeys] firstObject]];
        [self.arrAdvanceSearches removeObject:dict];
        
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advance Search"
                                                              action:nil
                                                               label:@"Delete"
                                                               value:nil] build]];
    }

    [self.tblView reloadData];
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    
    NSIndexPath *selectedPath = [self.tblView indexPathForSelectedRow];
    NSDictionary *dict = [self.arrAdvanceSearches objectAtIndex:selectedPath.row];
    AdvanceSearchResultsViewController *view = [[AdvanceSearchResultsViewController alloc] init];
    
    view.fetchedResultsController = self.fetchedResultsController;
    view.fetchedResultsController.delegate = view;
    view.navigationItem.title = [[dict allKeys] firstObject];
    view.queryToSave = _dictCurrentQuery;
    view.sorterToSave = _dictCurrentSort;
    view.mode = EditModeEdit;
    [self.navigationController pushViewController:view animated:NO];
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
