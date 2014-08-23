//
//  SearchViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SimpleSearchViewController.h"
#import "AdvanceSearchViewController.h"
#import "Card.h"
#import "CardDetailsViewController.h"
#import "CardRarity.h"
#import "Database.h"
#import "Set.h"

@interface SimpleSearchViewController ()

@end

@implementation SimpleSearchViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize searchBar  = _searchBar;
@synthesize tblResults = _tblResults;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *nsfrc = [[Database sharedInstance] search:self.searchBar.text];
    
    self.fetchedResultsController = nsfrc;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.selectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    
    dHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    self.tblResults = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                   style:UITableViewStylePlain];
    self.tblResults.delegate = self;
    self.tblResults.dataSource = self;
    
    self.navigationItem.titleView = self.searchBar;
    [self.view addSubview:self.tblResults];
    
    // remove the "< Back" title in back buttons
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *btnAdvance = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter-25.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(btnAdvanceTapped:)];
    self.navigationItem.leftBarButtonItem = btnAdvance;

}

-(void) btnAdvanceTapped:(id) sender
{
    AdvanceSearchViewController *advanceView = [[AdvanceSearchViewController alloc] init];
    
    [self.navigationController pushViewController:advanceView animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.selectedIndex != -1)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        
        [self.tblResults selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(UITableViewCell *)cell
           atIndexPath:(NSIndexPath *)indexPath
{
    Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@", card.type];
    if (card.power || card.toughness)
    {
        [type appendFormat:@" (%@/%@)", card.power, card.toughness];
    }
    
    cell.textLabel.text = card.name;
    cell.detailTextLabel.text = type;

    NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/%@/24.png", [[NSBundle mainBundle] bundlePath], card.set.code, [[card.rarity.name substringToIndex:1] uppercaseString]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        cell.imageView.image = [UIImage imageNamed:@"blank-24.png"];
    }
    else
    {
        cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CardDetailsViewController *cardView = [[CardDetailsViewController alloc] init];
    Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cardView.fetchedResultsController = self.fetchedResultsController;
    [cardView setCard:card];
    
    [self.navigationController pushViewController:cardView animated:YES];
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    if ([self.searchBar canResignFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    [hud showWhileExecuting:@selector(doSearch) onTarget:self withObject:nil animated:NO];
}

- (void) doSearch
{
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.tblResults reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblResults beginUpdates];
    NSLog(@"%d %s %s", __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"%d %s %s", __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
    
    UITableView *tableView = self.tblResults;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"%d %s %s", __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
    
    UITableView *tableView = self.tblResults;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"%d %s %s", __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
    
    UITableView *tableView = self.tblResults;
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [tableView endUpdates];
}

@end
