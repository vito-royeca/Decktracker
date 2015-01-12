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

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation AdvanceSearchViewController
{
    NSMutableDictionary *_dictCurrentQuery;
    NSMutableDictionary *_dictCurrentSort;
    NSInteger _selectedRow;
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

    self.arrAdvanceSearches = [[NSMutableArray alloc] init];
    for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Advance Search"
                                                       fromFileSystem:FileSystemLocal])
    {
        [self.arrAdvanceSearches addObject:[file stringByDeletingPathExtension]];
    }
    
    _selectedRow = 0;

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

#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Advance Search"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
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
    view.navigationItem.title = @"New Advance Search";
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
    
    cell.textLabel.text = self.arrAdvanceSearches[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    NSString *name = self.arrAdvanceSearches[_selectedRow];
    NSArray *arrData = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Advance Search/%@.json", name]];

    _dictCurrentQuery = [arrData firstObject];
    _dictCurrentSort = [arrData lastObject];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    [hud showWhileExecuting:@selector(doSearch) onTarget:self withObject:nil animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Advance Search"
                                                        message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", self.arrAdvanceSearches[_selectedRow]]
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
        NSString *name = self.arrAdvanceSearches[_selectedRow];
        NSString *path = [NSString stringWithFormat:@"/Advance Search/%@.json", name];
        [[FileManager sharedInstance] deleteFileAtPath:path];
        [self.arrAdvanceSearches removeObject:name];

#ifndef DEBUG
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advance Search"
                                                              action:nil
                                                               label:@"Delete"
                                                               value:nil] build]];
#endif
    }

    [self.tblView reloadData];
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    
    NSIndexPath *selectedPath = [self.tblView indexPathForSelectedRow];
    AdvanceSearchResultsViewController *view = [[AdvanceSearchResultsViewController alloc] init];
    
    view.fetchedResultsController = self.fetchedResultsController;
    view.fetchedResultsController.delegate = view;
    view.navigationItem.title = self.arrAdvanceSearches[selectedPath.row];
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
