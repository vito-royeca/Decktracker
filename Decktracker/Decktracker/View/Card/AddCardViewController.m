//
//  AddCardViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardDetailsViewController.h"
#import "CollectionsViewController.h"
#import "FileManager.h"
#import "MainViewController.h"
#import "SearchResultsTableViewCell.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation AddCardViewController
{
    UIView *_viewSegmented;
    NSMutableDictionary *_currentDeck;
    NSMutableDictionary *_currentCollection;
    InAppPurchase *_inAppPurchase;
}

@synthesize segmentedControl = _segmentedControl;
@synthesize tblAddTo = _tblAddTo;
@synthesize btnCancel = _btnCancel;
@synthesize btnDone = _btnDone;
@synthesize btnShowCard = _btnShowCard;
@synthesize bottomToolbar = _bottomToolbar;

@synthesize card = _card;
@synthesize arrDecks = _arrDecks;
@synthesize arrCollections = _arrCollections;

@synthesize segmentedControlIndex = _segmentedControlIndex;
@synthesize selectedDeckIndex = _selectedDeckIndex;
@synthesize selectedCollectionIndex = _selectedCollectionIndex;
@synthesize addDeckButtonVisible = _addDeckButtonVisible;
@synthesize addCollectionButtonVisible = _addCollectionButtonVisible;
@synthesize showCardButtonVisible = _showCardButtonVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.selectedDeckIndex = 0;
        self.selectedCollectionIndex = 0;
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
    CGFloat dHeight = self.view.frame.size.height - 30;
    self.tblAddTo = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                 style:UITableViewStylePlain];
    self.tblAddTo.dataSource = self;
    self.tblAddTo.delegate = self;
    [self.tblAddTo registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"Cell1"];
    [self.tblAddTo registerNib:[UINib nibWithNibName:@"QuantityTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"Cell2"];
    [self.tblAddTo registerNib:[UINib nibWithNibName:@"QuantityTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"Cell3"];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Add To Deck", @"Add to Collection"]];
    self.segmentedControl.frame = CGRectMake(dX+10, dY+7, dWidth-20, 30);
    self.segmentedControl.selectedSegmentIndex = self.segmentedControlIndex;
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    dHeight = 44;
    _viewSegmented = [[UIView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    _viewSegmented.backgroundColor = [UIColor whiteColor];
    [_viewSegmented addSubview:self.segmentedControl];
    
    
    dY = self.view.frame.size.height - dHeight;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    self.btnShowCard = [[UIBarButtonItem alloc] initWithTitle:@"Show Card"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(btnShowCardTapped:)];
    
    NSMutableArray *arrButtons = [[NSMutableArray alloc] init];
    if (self.showCardButtonVisible)
    {
        [arrButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil]];
        [arrButtons addObject:self.btnShowCard];
    }
    self.bottomToolbar.items = arrButtons;
    
    [self.view addSubview:self.tblAddTo];
    [self.view addSubview:self.bottomToolbar];
    self.navigationItem.title = @"Add Card";
    
    self.btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(btnCancelTapped:)];
    self.btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(btnDoneTapped:)];
    self.navigationItem.leftBarButtonItem = self.btnCancel;
    self.navigationItem.rightBarButtonItem = self.btnDone;
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            [self loadCurrentDeck];
            break;
        }
        case 1:
        {
            [self loadCurrentCollection];
            break;
        }
    }
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) segmentedControlChangedValue:(id) sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            self.segmentedControlIndex = (int)self.segmentedControl.selectedSegmentIndex;
            [self loadCurrentDeck];
            break;
        }
        case 1:
        {
            if (!_inAppPurchase)
            {
                _inAppPurchase = [[InAppPurchase alloc] init];
                _inAppPurchase.delegate = self;
            }

            if (![_inAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
            {
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.delegate = self;
                [hud showWhileExecuting:@selector(initPurchase) onTarget:self withObject:nil animated:NO];
            }
            else
            {
                self.segmentedControlIndex = (int)self.segmentedControl.selectedSegmentIndex;
                [self loadCurrentCollection];
            }
            break;
        }
    }
}

-(void) initPurchase
{
    [_inAppPurchase purchaseProduct:COLLECTIONS_IAP_PRODUCT_ID];
}

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnDoneTapped:(id) sender
{
    if (_currentDeck)
    {
        [[FileManager sharedInstance] saveData:_currentDeck atPath:[NSString stringWithFormat:@"/Decks/%@.json", _currentDeck[@"name"]]];
    }
    if (_currentCollection)
    {
        [[FileManager sharedInstance] saveData:_currentCollection atPath:[NSString stringWithFormat:@"/Collections/%@.json", _currentCollection[@"name"]]];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnShowCardTapped:(id) sender
{
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    Card *card = self.card;
    
    view.fetchedResultsController = nil;
    view.addButtonVisible = NO;
    [view setCard:card];
    
    [self.navigationController pushViewController:view animated:YES];
}

-(void) loadCurrentDeck
{
    if (self.arrDecks.count > 0)
    {
        NSString *path = [NSString stringWithFormat:@"/Decks/%@.json", self.arrDecks[self.selectedDeckIndex]];
        
        _currentDeck = [[NSMutableDictionary alloc] initWithDictionary:[[FileManager sharedInstance] loadFileAtPath:path]];
    }
    else
    {
        _currentDeck = nil;
    }
    [self.tblAddTo reloadData];
}

-(void) loadCurrentCollection
{
    if (self.arrCollections.count > 0)
    {
        NSString *path = [NSString stringWithFormat:@"/Collections/%@.json", self.arrCollections[self.selectedCollectionIndex]];
        
        _currentCollection = [[NSMutableDictionary alloc] initWithDictionary:[[FileManager sharedInstance] loadFileAtPath:path]];
    }
    else
    {
        _currentCollection = nil;
    }
    [self.tblAddTo reloadData];
}

-(void) updateDeck:(NSString*) board withValue:(int) newValue
{
    NSMutableArray *arrBoard = _currentDeck[board];
    NSDictionary *newCard = @{@"card" : self.card.name,
                              @"multiverseID" : self.card.multiverseID,
                              @"set"  : self.card.set.code,
                              @"qty"  : [NSNumber numberWithInt:newValue]};
    
    if (arrBoard)
    {
        NSDictionary *dictMain;
        
        for (NSDictionary *dict in arrBoard)
        {
            if ([dict[@"multiverseID"] intValue] == [self.card.multiverseID intValue] ||
                ([dict[@"card"] isEqualToString:self.card.name] &&
                [dict[@"set"] isEqualToString:self.card.set.code]))
            {
                dictMain = dict;
                break;
            }
        }
        
        if (dictMain)
        {
            [arrBoard removeObject:dictMain];

            if (newValue > 0)
            {
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dictMain];
                [newDict setValue:[NSNumber numberWithInt:newValue] forKey:@"qty"];
                [newDict setValue:self.card.multiverseID forKey:@"multiverseID"];
                [arrBoard addObject:newDict];
            }
        }
        else
        {
            [arrBoard addObject:newCard];
        }
    }
    else
    {
        arrBoard = [[NSMutableArray alloc] init];
        [arrBoard addObject:newCard];
    }
    
    [_currentDeck setObject:arrBoard forKey:board];
}

-(void) updateCollection:(NSString*) type withValue:(int) newValue
{
    NSMutableArray *arrType = _currentCollection[type];
    NSDictionary *newCard = @{@"card" : self.card.name,
                              @"multiverseID" : self.card.multiverseID,
                              @"set"  : self.card.set.code,
                              @"qty"  : [NSNumber numberWithInt:newValue]};
    
    if (arrType)
    {
        NSDictionary *dictMain;
        
        for (NSDictionary *dict in arrType)
        {
            if ([dict[@"multiverseID"] intValue] == [self.card.multiverseID intValue] ||
                ([dict[@"card"] isEqualToString:self.card.name] &&
                 [dict[@"set"] isEqualToString:self.card.set.code]))
            {
                dictMain = dict;
                break;
            }
        }
        
        if (dictMain)
        {
            [arrType removeObject:dictMain];
            
            if (newValue > 0)
            {
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dictMain];
                [newDict setValue:[NSNumber numberWithInt:newValue] forKey:@"qty"];
                [newDict setValue:self.card.multiverseID forKey:@"multiverseID"];
                [arrType addObject:newDict];
            }
        }
        else
        {
            [arrType addObject:newCard];
        }
    }
    else
    {
        arrType = [[NSMutableArray alloc] init];
        [arrType addObject:newCard];
    }
    
    [_currentCollection setObject:arrType forKey:type];
}

-(void) configureQuantityCell:(QuantityTableViewCell*) cell
                      withTag:(int) tag
                 withKey:(NSString*) key
{
    cell.delegate = self;
    cell.tag = tag;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            if (![self.card.type hasPrefix:@"Basic Land"])
            {
                cell.stepper.maximumValue = 4;
            }
            else
            {
                cell.stepper.maximumValue = 5000;
            }

            if (_currentDeck)
            {
                NSMutableArray *arrBoard = _currentDeck[key];
                NSDictionary *dictBoard;
                for (NSDictionary *dict in arrBoard)
                {
                    if ([dict[@"card"] isEqualToString:self.card.name] &&
                        [dict[@"set"] isEqualToString:self.card.set.code])
                    {
                        dictBoard = dict;
                        break;
                    }
                }
                if (dictBoard)
                {
                    cell.txtQuantity.text = [dictBoard[@"qty"] stringValue];
                    cell.stepper.value = [dictBoard[@"qty"] doubleValue];
                }
                else
                {
                    cell.txtQuantity.text = @"0";
                    cell.stepper.value = 0;
                }
            }
            else
            {
                cell.txtQuantity.text = @"0";
                cell.stepper.value = 0;
            }
            break;
        }
            
        case 1:
        {
            cell.stepper.maximumValue = 5000;
            
            if (_currentCollection)
            {
                NSMutableArray *arrType = _currentCollection[key];
                NSDictionary *dictType;
                for (NSDictionary *dict in arrType)
                {
                    if ([dict[@"card"] isEqualToString:self.card.name] &&
                        [dict[@"set"] isEqualToString:self.card.set.code])
                    {
                        dictType = dict;
                        break;
                    }
                }
                if (dictType)
                {
                    cell.txtQuantity.text = [dictType[@"qty"] stringValue];
                    cell.stepper.value = [dictType[@"qty"] doubleValue];
                }
                else
                {
                    cell.txtQuantity.text = @"0";
                    cell.stepper.value = 0;
                }
            }
            else
            {
                cell.txtQuantity.text = @"0";
                cell.stepper.value = 0;
            }
            break;
        }
    }
}

#pragma mark - UITableView
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone)
    {
        return nil;
    }
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2 || section == 3)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 0;
    }
    else
    {
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                return self.arrDecks.count;
            }
            case 1:
            {
                return self.arrCollections.count;
            }
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return _viewSegmented.frame.size.height;
    }
    
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return _viewSegmented;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0)
    {
        return SEARCH_RESULTS_CELL_HEIGHT;
    }
    else if (indexPath.section == 1)
    {
        return _viewSegmented.frame.size.height;
    }
    else if (indexPath.section == 2 || indexPath.section == 3)
    {
        return QUANTITY_TABLE_CELL_HEIGHT;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            if (section == 2)
            {
                return @"Mainboard";
            }
            else if (section == 3)
            {
                return @"Sideboard";
            }
            else if (section == 4)
            {
                return @"Select Deck";
            }
        }
        case 1:
        {
            if (section == 2)
            {
                return @"Regular";
            }
            else if (section == 3)
            {
                return @"Foiled";
            }
            else if (section == 4)
            {
                return @"Select Collection";
            }
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = (SearchResultsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        
        if (!cell)
        {
            cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"Cell1"];
        }
        
        [((SearchResultsTableViewCell*)cell) displayCard:self.card];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else if (indexPath.section == 2)
    {
        cell = (QuantityTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        
        if (!cell)
        {
            cell = [[QuantityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"Cell2"];
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        NSString *key;
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                key = @"mainBoard";
                break;
            }
            case 1:
            {
                key = @"regular";
                break;
            }
        }
        [self configureQuantityCell:(QuantityTableViewCell*)cell
                            withTag:0
                       withKey:key];
    }
    else if (indexPath.section == 3)
    {
        cell = (QuantityTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell3"];
        
        if (!cell)
        {
            cell = [[QuantityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"Cell3"];
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        NSString *key;
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                key = @"sideBoard";
                break;
            }
            case 1:
            {
                key = @"foiled";
                break;
            }
        }
        [self configureQuantityCell:(QuantityTableViewCell*)cell
                            withTag:1
                       withKey:key];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4"];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"Cell4"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                if (self.arrDecks.count > 0)
                {
                    cell.textLabel.text = self.arrDecks[indexPath.row];
                }
                cell.accessoryType = indexPath.row == self.selectedDeckIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            }
            case 1:
            {
                if (self.arrCollections.count > 0)
                {
                    cell.textLabel.text = self.arrCollections[indexPath.row];
                }
                cell.accessoryType = indexPath.row == self.selectedCollectionIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4)
    {
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                self.selectedDeckIndex = (int)indexPath.row;
                [self loadCurrentDeck];
                break;
            }
            case 1:
            {
                self.selectedCollectionIndex = (int)indexPath.row;
                [self loadCurrentCollection];
                break;
            }
        }
    }
}

#pragma mark -
-(void) stepperChanged:(QuantityTableViewCell*) cell withValue:(int) value
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            if (!_currentDeck || self.selectedDeckIndex < 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"You may need to create one Deck or select a Deck from the list."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                switch (cell.tag)
                {
                    case 0:
                    {
                        [self updateDeck:@"mainBoard" withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                    case 1:
                    {
                        [self updateDeck:@"sideBoard" withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                }
            }
            break;
        }
        case 1:
        {
            if (!_currentCollection || self.selectedCollectionIndex < 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"You may need to create one Collection or select a Collection from the list."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                switch (cell.tag)
                {
                    case 0:
                    {
                        [self updateCollection:@"regular" withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                    case 1:
                    {
                        [self updateCollection:@"foiled" withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                }
            }
            break;
        }
    }
}

#pragma mark - InAppPurchaseDelegate
-(void) purchaseSucceded:(NSString*) message
{
    self.segmentedControlIndex = (int)self.segmentedControl.selectedSegmentIndex;
    [self loadCurrentCollection];
    
    MainViewController *view = (MainViewController*)self.tabBarController;
    [view addCollectionsProduct];
}

-(void) purchaseRestored:(NSString*) message
{
    [self purchaseSucceded:message];
}

-(void) purchaseFailed:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControlIndex = (int)self.segmentedControl.selectedSegmentIndex;
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
}

@end
