//
//  AddCardViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardDetailsViewController.h"
#import "Collection.h"
#import "CollectionsViewController.h"
#import "Deck.h"
#import "FileManager.h"
#import "InAppPurchase.h"
#import "InAppPurchaseViewController.h"
#import "MainViewController.h"
#import "SearchResultsTableViewCell.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation AddCardViewController
{
    UIView *_viewSegmented;
    Deck *_currentDeck;
    Collection *_currentCollection;
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
            if (![InAppPurchase isProductPurchased:COLLECTIONS_IAP_PRODUCT_ID])
            {
                self.segmentedControl.selectedSegmentIndex = 0;
                self.segmentedControlIndex = (int)self.segmentedControl.selectedSegmentIndex;
                
                InAppPurchaseViewController *view = [[InAppPurchaseViewController alloc] init];
                
                view.productID = COLLECTIONS_IAP_PRODUCT_ID;
                [self.navigationController pushViewController:view animated:NO];
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

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnDoneTapped:(id) sender
{
    if (_currentDeck)
    {
        [_currentDeck save:[NSString stringWithFormat:@"/Decks/%@.json", _currentDeck.name]];
    }
    if (_currentCollection)
    {
        [_currentCollection save:[NSString stringWithFormat:@"/Collections/%@.json", _currentCollection.name]];
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
        NSDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[[FileManager sharedInstance] loadFileAtPath:path]];
                              
        _currentDeck = [[Deck alloc] initWithDictionary:dict];
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
        NSDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[[FileManager sharedInstance] loadFileAtPath:path]];
        
        _currentCollection = [[Collection alloc] initWithDictionary:dict];
    }
    else
    {
        _currentCollection = nil;
    }
    [self.tblAddTo reloadData];
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
                DeckBoard deckboard = [key isEqualToString:@"mainBoard"] ? MainBoard : SideBoard;
                
                int qty = [_currentDeck cards:self.card inBoard:deckboard];
                cell.txtQuantity.text = [NSString stringWithFormat:@"%d", qty];
                cell.stepper.value = qty;
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
                CollectionType type = [key isEqualToString:@"regular"] ? CollectionTypeRegular : CollectionTypeFoiled;
                
                int qty = [_currentCollection cards:self.card inType:type];
                cell.txtQuantity.text = [NSString stringWithFormat:@"%d", qty];
                cell.stepper.value = qty;
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
    
    cell.userInteractionEnabled = YES;
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
        cell.userInteractionEnabled = NO;
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
                        [_currentDeck updateDeck:MainBoard
                                        withCard:self.card
                                       withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                    case 1:
                    {
                        [_currentDeck updateDeck:SideBoard
                                        withCard:self.card
                                       withValue:value];
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
                        [_currentCollection updateCollection:CollectionTypeRegular
                                                    withCard:self.card
                                                   withValue:value];
                        cell.stepper.value = value;
                        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                        break;
                    }
                    case 1:
                    {
                        [_currentCollection updateCollection:CollectionTypeFoiled
                                                    withCard:self.card
                                                   withValue:value];
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

@end
