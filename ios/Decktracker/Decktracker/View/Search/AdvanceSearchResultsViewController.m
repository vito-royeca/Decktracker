//
//  AdvanceSearchResultsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AdvanceSearchResultsViewController.h"
#import "AdvanceSearchViewController.h"
#import "CardDetailsViewController.h"
#import "Database.h"
#import "DTCard.h"
#import "DTCardColor.h"
#import "DTCardRarity.h"
#import "DTCardType.h"
#import "DTSet.h"
#import "FileManager.h"
#import "NewAdvanceSearchViewController.h"
#import "SearchResultsTableViewCell.h"
#import "Decktracker-Swift.h"

#import "ActionSheetStringPicker.h"
#import "CSStickyHeaderFlowLayout.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation AdvanceSearchResultsViewController
{
    AdvanceSearchResultsViewMode _viewMode;
    BOOL _viewLoadedOnce;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize btnView = _btnView;
@synthesize btnAction = _btnAction;
@synthesize tblResults = _tblResults;
@synthesize colResults = _colResults;
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
    
    self.btnView = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"insert_table.png"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(btnViewTapped:)];
    if (self.mode == EditModeEdit)
    {
        self.btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                       target:self
                                                                       action:@selector(btnActionTapped:)];
    }
    else if (self.mode == EditModeNew)
    {
        self.btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                       target:self
                                                                       action:@selector(btnActionTapped:)];
    }
    
    self.navigationItem.rightBarButtonItems = @[self.btnAction, self.btnView];;
    _viewMode = AdvanceSearchResultsViewModeByList;
    _viewLoadedOnce = YES;
    [self showTableView];
    _viewLoadedOnce = NO;

#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Advance Search Results"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) hidesBottomBarWhenPushed
{
    return YES;
}

-(void) btnViewTapped:(id) sender
{
    NSArray *statusOptions = @[@"List", @"2x2", @"3x3"];
    int initialSelection = 0;
    
    switch (_viewMode) {
        case AdvanceSearchResultsViewModeByList:
        {
            initialSelection = 0;
            break;
        }
        case AdvanceSearchResultsViewModeByGrid2x2:
        {
            initialSelection = 1;
            break;
        }
        case AdvanceSearchResultsViewModeByGrid3x3:
        {
            initialSelection = 2;
            break;
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"View As"
                                            rows:statusOptions
                                initialSelection:initialSelection
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           
                                           
                                           switch (selectedIndex) {
                                               case 0: {
                                                   _viewMode = AdvanceSearchResultsViewModeByList;
                                                   [self showTableView];
                                                   break;
                                               }
                                               case 1: {
                                                   _viewMode = AdvanceSearchResultsViewModeByGrid2x2;
                                                   [self showGridView];
                                                   break;
                                               }
                                               case 2: {
                                                   _viewMode = AdvanceSearchResultsViewModeByGrid3x3;
                                                   [self showGridView];
                                                   break;
                                               }
                                           }
                                       }
                                     cancelBlock:nil
                                          origin:self.view];
}

-(void) btnActionTapped:(id) sender
{
    if (self.mode == EditModeNew)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].text = self.navigationItem.title;
        [alert show];
    }
    else if (self.mode == EditModeEdit)
    {
        NewAdvanceSearchViewController *view = [[NewAdvanceSearchViewController alloc] init];
        
        view.mode = EditModeEdit;
        view.navigationItem.title = self.navigationItem.title;
        view.dictCurrentQuery = [[NSMutableDictionary alloc] initWithDictionary:self.queryToSave];
        view.dictCurrentSorter = [[NSMutableDictionary alloc] initWithDictionary:self.sorterToSave];
        [self.navigationController pushViewController:view animated:NO];
    }
}

-(void) showTableView
{
    CGFloat dX = 0;
    CGFloat dY = _viewLoadedOnce ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY;
    
    self.tblResults = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblResults.delegate = self;
    self.tblResults.dataSource = self;
    [self.tblResults registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell"];
    
    if (self.colResults) {
        [self.colResults removeFromSuperview];
    }
    [self.view addSubview:self.tblResults];
}

-(void) showGridView
{
    CGFloat dX = 0;
    CGFloat dY = _viewLoadedOnce ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY;
    CGFloat divisor = _viewMode == AdvanceSearchResultsViewModeByGrid2x2 ? 2 : 3;
    CGRect frame = CGRectMake(dX, dY, dWidth, dHeight);
    
    CSStickyHeaderFlowLayout *layout = [[CSStickyHeaderFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.headerReferenceSize = CGSizeMake(dWidth, 22);
    layout.itemSize = CGSizeMake(frame.size.width/divisor, frame.size.height/divisor);
    
    self.colResults = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.colResults.dataSource = self;
    self.colResults.delegate = self;
    [self.colResults registerClass:[CardListCollectionViewCell class] forCellWithReuseIdentifier:@"Card"];
//    [self.colResults registerClass:[UICollectionReusableView class]
//        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//               withReuseIdentifier:@"Header"];
    self.colResults.backgroundColor = [UIColor lightGrayColor];
    
    if (self.tblResults) {
        [self.tblResults removeFromSuperview];
    }
    [self.view addSubview:self.colResults];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *path = [NSString stringWithFormat:@"/Advance Search/%@.json", [[alertView textFieldAtIndex:0] text]];
        [[FileManager sharedInstance] saveData:@[self.queryToSave, self.sorterToSave]
                                        atPath:path];
        
        AdvanceSearchViewController *view = [[AdvanceSearchViewController alloc] init];
        [self.navigationController pushViewController:view animated:NO];

#ifndef DEBUG
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advance Search"
                                                              action:nil
                                                               label:@"Save"
                                                               value:nil] build]];
#endif
    }
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SEARCH_RESULTS_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
	if (self.fetchedResultsController)
    {
        return [NSString stringWithFormat:@"%tu Results", [sectionInfo numberOfObjects]];
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;

    DTCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell displayCard:card];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *dict = [[Database sharedInstance] inAppSettingsForSet:card.set];
    if (dict)
    {
        return;
    }
    
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    view.fetchedResultsController = self.fetchedResultsController;
    view.addButtonVisible = YES;
    [view setCard:card];
    
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CardListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Card" forIndexPath:indexPath];
    
    [cell displayCard:card];
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *dict = [[Database sharedInstance] inAppSettingsForSet:card.set];
    if (dict)
    {
        return;
    }
    
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    view.fetchedResultsController = self.fetchedResultsController;
    view.addButtonVisible = YES;
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
            DTCard *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
            SearchResultsTableViewCell *cell = (SearchResultsTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell displayCard:card];
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
        default:
        {
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
