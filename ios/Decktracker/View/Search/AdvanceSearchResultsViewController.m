//
//  AdvanceSearchResultsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AdvanceSearchResultsViewController.h"
#import "CardDetailsViewController.h"
#import "Database.h"
#import "DTCard.h"
#import "DTCardColor.h"
#import "DTCardRarity.h"
#import "DTCardType.h"
#import "DTSet.h"
#import "FileManager.h"
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
    NSString *_viewMode;
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
    
    self.btnView = [[UIBarButtonItem alloc] initWithTitle:kCardViewModeList
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
    
    self.navigationItem.rightBarButtonItems = @[self.btnAction, self.btnView];
    
    
    _viewLoadedOnce = YES;
    [self loadResults];
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

-(void) loadResults
{
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:kCardViewMode];
    
    if (value)
    {
        if ([value isEqualToString:kCardViewModeList])
        {
            _viewMode = kCardViewModeList;
            [self showTableView];
        }
        else if ([value isEqualToString:kCardViewModeGrid2x2])
        {
            _viewMode = kCardViewModeGrid2x2;
            [self showGridView];
            
        }
        else if ([value isEqualToString:kCardViewModeGrid3x3])
        {
            _viewMode = kCardViewModeGrid3x3;
            [self showGridView];
        }
        else
        {
            _viewMode = kCardViewModeList;
            [self showTableView];
        }
    }
    else
    {
        _viewMode = kCardViewModeList;
        [self showTableView];
    }
}

-(void) btnViewTapped:(id) sender
{
    int initialSelection = 0;
    
    if ([_viewMode isEqualToString:kCardViewModeList])
    {
        initialSelection = 0;
    }
    else if ([_viewMode isEqualToString:kCardViewModeGrid2x2])
    {
        initialSelection = 1;
    }
    else if ([_viewMode isEqualToString:kCardViewModeGrid3x3])
    {
        initialSelection = 2;
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"View As"
                                            rows:@[kCardViewModeList, kCardViewModeGrid2x2, kCardViewModeGrid3x3]
                                initialSelection:initialSelection
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           
                                           
                                           switch (selectedIndex) {
                                               case 0: {
                                                   _viewMode = kCardViewModeList;
                                                   [self showTableView];
                                                   break;
                                               }
                                               case 1: {
                                                   _viewMode = kCardViewModeGrid2x2;
                                                   [self showGridView];
                                                   break;
                                               }
                                               case 2: {
                                                   _viewMode = kCardViewModeGrid3x3;
                                                   [self showGridView];
                                                   break;
                                               }
                                           }
                                           
                                           [[NSUserDefaults standardUserDefaults] setObject:_viewMode
                                                                                     forKey: kCardViewMode];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                       }
                                     cancelBlock:nil
                                          origin:self.view];
}

-(void) btnActionTapped:(id) sender
{
    if (self.mode == EditModeNew)
    {
        void (^handler)(UIAlertController*) = ^void(UIAlertController *alert) {
            
            NSString *name = [((UITextField*)[alert.textFields firstObject]) text];
            NSString *path = [NSString stringWithFormat:@"/Advance Search/%@.json", name];
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
        };
        
        void (^textFieldHandler)(UITextField*) = ^void(UITextField *textField) {
            textField.text = self.navigationItem.title;
        };
        
        [JJJUtil alertWithTitle:@"Save"
                        message:nil
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@{@"Ok": handler}
              textFieldHandlers:@[textFieldHandler]];
        
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
    self.btnView.title = _viewMode;
}

-(void) showGridView
{
    CGFloat dX = 0;
    CGFloat dY = _viewLoadedOnce ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY;
    CGFloat divisor = [_viewMode isEqualToString:kCardViewModeGrid2x2] ? 2 : 3;
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
    UIImage *bgImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/images/Gray_Patterned_BG.jpg", [[NSBundle mainBundle] bundlePath]]];
    self.colResults.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    if (self.tblResults) {
        [self.tblResults removeFromSuperview];
    }
    [self.view addSubview:self.colResults];
    self.btnView.title = _viewMode;
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
