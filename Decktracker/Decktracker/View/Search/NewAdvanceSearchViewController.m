//
//  NewAdvanceSearchViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "NewAdvanceSearchViewController.h"
#import "AdvanceSearchResultsViewController.h"
#import "Artist.h"
#import "CardColor.h"
#import "CardRarity.h"
#import "CardType.h"
#import "Database.h"
#import "Format.h"
#import "Set.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation NewAdvanceSearchViewController
{
    UIBarButtonItem *_btnPlay;
    
    NSArray *_arrFilters;
    NSArray *_arrSorters;
}

@synthesize segmentedControl = _segmentedControl;
@synthesize tblView = _tblView;
@synthesize dictCurrentQuery = _dictCurrentQuery;
@synthesize dictCurrentSorter = _dictCurrentSorter;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize mode = _mode;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *nsfrc = [[Database sharedInstance] advanceSearch:self.dictCurrentQuery
                                                                      withSorter:self.dictCurrentSorter];
    
    self.fetchedResultsController = nsfrc;
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.dictCurrentQuery = [[NSMutableDictionary alloc] init];
        self.dictCurrentSorter = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _arrFilters = @[@"Name", @"Set", @"Rarity", @"Type", @"Subtype", @"Color", @"Keyword", @"Text", @"Flavor Text",
                    @"Artist"];
    
    _arrSorters = @[@"Name"];
    
    CGFloat dX = 10;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height+10;
    CGFloat dWidth = self.view.frame.size.width - 20;
    CGFloat dHeight = 30;
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Filter", @"Search Criteria"]];
    self.segmentedControl.frame = CGRectMake(dX, dY, dWidth, dHeight);
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    
    dX = 0;
    dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height +5;
    dWidth += 20;
    dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.tblView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _btnPlay = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                             target:self
                                                             action:@selector(btnPlayTapped:)];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(btnCancelTapped:)];
    self.navigationItem.leftBarButtonItem = btnCancel;

    if (self.mode == EditModeEdit)
    {
        self.navigationItem.title = @"Edit Advance Search";
    }
    else if (self.mode == EditModeNew)
    {
        self.navigationItem.title = @"New Advance Search";
    }
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewDidAppear:(BOOL)animated
{
    if (self.dictCurrentQuery.count > 0)
    {
        self.segmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnPlayTapped:(id) sender
{
    if (self.dictCurrentQuery.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Select at least one filter."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.delegate = self;
        [hud showWhileExecuting:@selector(doSearch) onTarget:self withObject:nil animated:NO];
        
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advance Search"
                                                              action:self.mode == EditModeEdit ? @"Edit" : @"New"
                                                               label:@"Run"
                                                               value:nil] build]];
    }
}

-(void) btnCancelTapped:(id) sender
{
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advance Search"
                                                          action:self.mode == EditModeEdit ? @"Edit" : @"New"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    [self.navigationController popViewControllerAnimated:NO];
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

-(void) segmentedControlChangedValue:(id) sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            self.tblView.editing = YES;
            self.navigationItem.rightBarButtonItem = _btnPlay;
            break;
        }
        default:
        {
            self.tblView.editing = NO;
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
    }
    
    [self.tblView reloadData];
}

-(void) showSegment:(int) index
{
    self.segmentedControl.selectedSegmentIndex = index;
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSString *key = [[self.dictCurrentQuery allKeys] objectAtIndex:indexPath.section];
            NSMutableArray *rows = [self.dictCurrentQuery objectForKey:key];
            [rows removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if (rows.count == 0)
            {
                [self.dictCurrentQuery removeObjectForKey:key];
            }
            
//            [tableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            return YES;
        }
        default:
        {
            return NO;
        }
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            return UITableViewCellEditingStyleDelete;
        }
        default:
        {
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            return [[self.dictCurrentQuery allKeys] objectAtIndex:section];
        }
        default:
        {
            return nil;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            return [self.dictCurrentQuery allKeys].count;
        }
        default:
        {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            return _arrFilters.count;
        }
//        case 1:
//        {
//            return _arrSorters.count;
//        }
        case 1:
        {
            NSString *key = [[self.dictCurrentQuery allKeys] objectAtIndex:section];
            NSMutableArray *rows = [self.dictCurrentQuery objectForKey:key];
            
            return rows.count;
        }
        default:
        {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            cell.textLabel.text = [_arrFilters objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
//        case 1:
//        {
//            cell.textLabel.text = [_arrSorters objectAtIndex:indexPath.row];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            break;
//        }
        case 1:
        {
            NSString *key = [[self.dictCurrentQuery allKeys] objectAtIndex:indexPath.section];
            NSMutableArray *rows = [self.dictCurrentQuery objectForKey:key];
            NSDictionary *dict = [rows objectAtIndex:indexPath.row];
            NSString *stringValue;
            id value = [[dict allValues] firstObject];
            
            if ([value isKindOfClass:[NSManagedObject class]])
            {
                stringValue = [value performSelector:@selector(name) withObject:nil];
            }
            else if ([value isKindOfClass:[NSString class]])
            {
                stringValue = value;
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ = '%@'", [[dict allKeys] firstObject], key, stringValue];
            cell.accessoryType = UITableViewCellAccessoryNone;

            break;
        }
        default:
        {
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrFilterOptions;

    if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Set"])
    {
        arrFilterOptions = [Set MR_findAllSortedBy:@"name" ascending:YES];
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Rarity"])
    {
        arrFilterOptions = [CardRarity MR_findAll];
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Type"])
    {
        arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name IN %@", CARD_TYPES]];
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Subtype"])
    {
        arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"NOT (name IN %@)", CARD_TYPES]];
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Color"])
    {
        arrFilterOptions = [CardColor MR_findAllSortedBy:@"name" ascending:YES];;
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Keyword"])
    {
        arrFilterOptions = KEYWORDS;
    }
    else if ([[_arrFilters objectAtIndex:indexPath.row] isEqualToString:@"Artist"])
    {
        arrFilterOptions = [Artist MR_findAllSortedBy:@"name" ascending:YES];
    }
    
    FilterInputViewController *view = [[FilterInputViewController alloc] init];
    view.delegate = self;
    view.filterOptions = arrFilterOptions;
    view.filterName = [_arrFilters objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - FilterInputViewControllerDelegate
-(void) addFilter:(NSDictionary*) filter
{
    NSMutableArray *arrRows = [self.dictCurrentQuery objectForKey:[filter objectForKey:@"Filter"]];
    
    if (!arrRows)
    {
        arrRows = [[NSMutableArray alloc] init];
        [self.dictCurrentQuery setObject:arrRows forKey:[filter objectForKey:@"Filter"]];
    }
    [arrRows addObject:@{[filter objectForKey:@"Condition"] : [filter objectForKey:@"Value"]}];
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    
    AdvanceSearchResultsViewController *view = [[AdvanceSearchResultsViewController alloc] init];
    
    view.fetchedResultsController = self.fetchedResultsController;
    view.fetchedResultsController.delegate = view;
//    view.navigationItem.title = [NSString stringWithFormat:@"%tu Results", [self.fetchedResultsController.fetchedObjects count]];
    view.queryToSave = self.dictCurrentQuery;
    view.sorterToSave = self.dictCurrentSorter;
    view.mode = EditModeNew;
    [self.navigationController pushViewController:view animated:NO];
}

@end
