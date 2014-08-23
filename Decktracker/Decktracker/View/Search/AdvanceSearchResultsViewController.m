//
//  AdvanceSearchResultsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AdvanceSearchResultsViewController.h"
#import "AdvanceSearchViewController.h"
#import "Card.h"
#import "CardDetailsViewController.h"
#import "CardRarity.h"
#import "Database.h"
#import "FileManager.h"
#import "NewAdvanceSearchViewController.h"
#import "Set.h"

@implementation AdvanceSearchResultsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize tblResults = _tblResults;
@synthesize queryToSave = _queryToSave;
@synthesize sorterToSave = _sorterToSave;
@synthesize mode = _mode;

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
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblResults = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblResults.delegate = self;
    self.tblResults.dataSource = self;
    
    [self.view addSubview:self.tblResults];
    
    
    
    UIBarButtonItem *btnAction;
    
    if (self.mode == EditModeEdit)
    {
        btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                  target:self
                                                                  action:@selector(btnActionTapped:)];
    }
    else if (self.mode == EditModeNew)
    {
        btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                  target:self
                                                                  action:@selector(btnActionTapped:)];
    }
    self.navigationItem.rightBarButtonItem = btnAction;
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.tblResults reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnActionTapped:(id) sender
{
    if (self.mode == EditModeEdit)
    {
        NewAdvanceSearchViewController *view = [[NewAdvanceSearchViewController alloc] init];
        
        view.mode = EditModeEdit;
        view.dictCurrentQuery = [[NSMutableDictionary alloc] initWithDictionary:self.queryToSave];
        view.dictCurrentSorter = [[NSMutableDictionary alloc] initWithDictionary:self.sorterToSave];
        [self.navigationController pushViewController:view animated:NO];
    }
    else if (self.mode == EditModeNew)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                         message:@"Advance Search Name"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[FileManager sharedInstance] saveAdvanceQuery:[[alertView textFieldAtIndex:0] text]
                                           withFilters:self.queryToSave
                                            andSorters:self.sorterToSave];
        AdvanceSearchViewController *view = [[AdvanceSearchViewController alloc] init];
    
        [self.navigationController pushViewController:view animated:NO];
    }
}

#pragma mark - UITableView
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
    
    NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/%@/24.png", [[NSBundle mainBundle] bundlePath], card.set.code, [[Database sharedInstance] cardRarityIndex:card]];
    
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
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    view.fetchedResultsController = self.fetchedResultsController;
    [view setCard:card];
    
    [self.navigationController pushViewController:view animated:YES];
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
