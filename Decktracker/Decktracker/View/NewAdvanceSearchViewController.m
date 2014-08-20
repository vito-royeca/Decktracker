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
#import "Magic.h"
#import "Set.h"

@implementation NewAdvanceSearchViewController
{
    UIBarButtonItem *_btnPlay;
    
    NSArray *_arrFilters;
    NSArray *_arrSorters;
    NSArray *_cardTypes;
}

@synthesize segmentedControl = _segmentedControl;
@synthesize tblView = _tblView;
@synthesize dictCurrentQuery = _dictCurrentQuery;
@synthesize dictCurrentSort = _dictCurrentSort;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *nsfrc = [[Database sharedInstance] advanceSearch:self.dictCurrentQuery withSorter:self.dictCurrentSort];
    
    self.fetchedResultsController = nsfrc;
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dictCurrentQuery = [[NSMutableDictionary alloc] init];
    _arrFilters = @[@"Name", @"Set", @"Rarity", @"Format", @"Type", @"Subtype", @"Color", @"Text", @"Flavor Text",
                    @"Artist"];
    
    _arrSorters = @[@"Name"];
    
    _cardTypes = @[@"Artifact", @"Basic", @"Conspiracy", @"Creature", @"Enchantment", @"Instant", @"Land",
                   @"Legendary", @"Ongoing", @"Phenomenon", @"Plane", @"Planeswalker", @"Scheme", @"Snow",
                   @"Sorcery", @"Tribal", @"Vanguard", @"World"];
    
    CGFloat dX = 10;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height+10;
    CGFloat dWidth = self.view.frame.size.width - 20;
    CGFloat dHeight = 30;
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Filter", @"Sorter", @"Search Criteria"]];
    self.segmentedControl.frame = CGRectMake(dX, dY, dWidth, dHeight);
    self.segmentedControl.selectedSegmentIndex = 0;
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

    self.navigationItem.title = @"New Advance Search";
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
    }
}

-(void) btnCancelTapped:(id) sender
{
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
        case 2:
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

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 2)
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 1:
        {
            return _arrSorters.count;
        }
        case 2:
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
        case 1:
        {
            cell.textLabel.text = [_arrSorters objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:
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
    
    FilterInputViewController *inputView = [[FilterInputViewController alloc] init];
    NSArray *arrFilterOptions;
    
    switch (indexPath.row)
    {
        case 1:
        {
            arrFilterOptions = [Set MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        case 2:
        {
            arrFilterOptions = [CardRarity MR_findAll];
            break;
        }
        case 3:
        {
            arrFilterOptions = [Format MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        case 4:
        {
            arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name IN %@", _cardTypes]];
            break;
        }
        case 5:
        {
            arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"NOT (name IN %@)", _cardTypes]];
            break;
        }
        case 6:
        {
            arrFilterOptions = [CardColor MR_findAllSortedBy:@"name" ascending:YES];;
            break;
        }
        case 9:
        {
            arrFilterOptions = [Artist MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        default:
        {
            break;
        }
    }
    
    inputView.delegate = self;
    inputView.filterOptions = arrFilterOptions;
    inputView.filterName = [_arrFilters objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:inputView animated:YES];
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
    
    self.segmentedControl.selectedSegmentIndex = 2;
    self.tblView.editing = YES;
    self.navigationItem.rightBarButtonItem = _btnPlay;
    [self.tblView reloadData];
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    
    AdvanceSearchResultsViewController *advanceSearchResultsView = [[AdvanceSearchResultsViewController alloc] init];
    advanceSearchResultsView.fetchedResultsController = self.fetchedResultsController;
    advanceSearchResultsView.fetchedResultsController.delegate = advanceSearchResultsView;
    advanceSearchResultsView.navigationItem.title = [NSString stringWithFormat:@"%tu Search Results", [self.fetchedResultsController.fetchedObjects count]];
    [self.navigationController pushViewController:advanceSearchResultsView animated:NO];
}

@end
