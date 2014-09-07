//
//  AddToDeckViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AddToDeckViewController.h"
#import "CardDetailsViewController.h"
#import "FileManager.h"
#import "SearchResultsTableViewCell.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation AddToDeckViewController
{
    NSMutableDictionary *_currentDeck;
}

@synthesize tblAddTo = _tblAddTo;
@synthesize btnCancel = _cancel;
@synthesize btnDone = _btnDone;
@synthesize btnNew = _btnNew;
@synthesize btnShowCard  =_btnShowCard;
@synthesize bottomToolbar = _bottomToolbar;
@synthesize arrDecks = _arrDecks;
@synthesize card = _card;
@synthesize selectedDeckIndex = _selectedDeckIndex;
@synthesize newButtonVisible = _newButtonVisible;
@synthesize showCardButtonVisible = _showCardButtonVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.newButtonVisible = NO;
        self.showCardButtonVisible = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCurrentDeck];
    
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
    
    dHeight = 44;
    dY = self.view.frame.size.height - dHeight;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    self.btnNew = [[UIBarButtonItem alloc] initWithTitle:@"New Deck"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(btnNewTapped:)];
    self.btnShowCard = [[UIBarButtonItem alloc] initWithTitle:@"Show Card"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(btnShowCardTapped:)];
    NSMutableArray *arrButtons = [[NSMutableArray alloc] init];
    [arrButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                        action:nil]];
    if (self.newButtonVisible)
    {
        [arrButtons insertObject:self.btnNew atIndex:0];
    }
    if (self.showCardButtonVisible)
    {
        [arrButtons addObject:self.btnShowCard];
    }
    self.bottomToolbar.items = arrButtons;
    
    [self.view addSubview:self.tblAddTo];
    [self.view addSubview:self.bottomToolbar];
    self.navigationItem.title = @"Add To Deck";
    
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

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnDoneTapped:(id) sender
{
    [[FileManager sharedInstance] saveData:_currentDeck atPath:[NSString stringWithFormat:@"/Decks/%@.json", _currentDeck[@"name"]]];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnNewTapped:(id) sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                     message:@"New Deck Name"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) btnShowCardTapped:(id) sender
{
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    Card *card = self.card;
    
    view.fetchedResultsController = nil;
    view.addToDeckButtonVisible = NO;
    [view setCard:card];
    
    [self.navigationController pushViewController:view animated:YES];
}

-(void) updateDeck:(NSString*) board withValue:(int) newValue
{
    NSMutableArray *arrBoard = _currentDeck[board];
    NSDictionary *newCard = @{@"card" : self.card.name,
                              @"set"  : self.card.set.code,
                              @"qty"  : [NSNumber numberWithInt:newValue]};
    
    if (arrBoard)
    {
        NSDictionary *dictMain;
        
        for (NSDictionary *dict in arrBoard)
        {
            if ([dict[@"card"] isEqualToString:self.card.name] &&
                [dict[@"set"] isEqualToString:self.card.set.code])
            {
                dictMain = dict;
                [arrBoard removeObject:dict];
                break;
            }
        }
        
        if (dictMain)
        {
            if (newValue > 0)
            {
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dictMain];
                [newDict setValue:[NSNumber numberWithInt:newValue] forKey:@"qty"];
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
//    [[FileManager sharedInstance] saveData:_currentDeck atPath:[NSString stringWithFormat:@"/Decks/%@.json", _currentDeck[@"name"]]];
//    [self loadCurrentDeck];
}

-(void) loadCurrentDeck
{
    if (self.arrDecks.count > 0 && self.selectedDeckIndex >= 0)
    {
        NSString *path = [NSString stringWithFormat:@"/Decks/%@.json", self.arrDecks[self.selectedDeckIndex]];
        
        _currentDeck = [[NSMutableDictionary alloc] initWithDictionary:[[FileManager sharedInstance] loadFileAtPath:path]];
    }
    [self.tblAddTo reloadData];
}

-(void) configureQuantityCell:(QuantityTableViewCell*) cell
                      withTag:(int) tag
                 withDeckArea:(NSString*) deckArea
{
    cell.delegate = self;
    cell.tag = tag;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        NSMutableArray *arrBoard = _currentDeck[deckArea];
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
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSDictionary *dict = @{@"name" : [[alertView textFieldAtIndex:0] text],
                               @"mainBoard" : @[],
                               @"sideBoard" : @[]};
        [[FileManager sharedInstance] saveData:dict atPath:[NSString stringWithFormat:@"/Decks/%@.json", dict[@"name"]]];
        NSArray *arrFiles = [[FileManager sharedInstance] findFilesAtPath:@"/Decks"];
        self.arrDecks = [[NSMutableArray alloc] initWithArray:arrFiles];
        
        self.selectedDeckIndex = 0;
        [self loadCurrentDeck];
        
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card In Decks"
                                                              action:nil
                                                               label:@"New Deck"
                                                               value:nil] build]];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 2)
    {
        return 1;
    }
    else
    {
        return self.arrDecks.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0)
    {
        return SEARCH_RESULTS_CELL_HEIGHT;
    }
    else if (indexPath.section == 1 || indexPath.section == 2)
    {
        return 60;
    }
    else
    {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    else if (section == 1)
    {
        return @"Mainboard";
    }
    else if (section == 2)
    {
        return @"Sideboard";
    }
    else
    {
        return @"Select Deck";
    }
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
    }
    else if (indexPath.section == 1)
    {
        cell = (QuantityTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        
        if (!cell)
        {
            cell = [[QuantityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"Cell2"];
        }

        [self configureQuantityCell:(QuantityTableViewCell*)cell
                            withTag:0
                       withDeckArea:@"mainBoard"];
    }
    else if (indexPath.section == 2)
    {
        cell = (QuantityTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell3"];
        
        if (!cell)
        {
            cell = [[QuantityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"Cell3"];
        }

        [self configureQuantityCell:(QuantityTableViewCell*)cell
                            withTag:1
                       withDeckArea:@"sideBoard"];
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

        if (self.arrDecks.count > 0)
        {
            cell.textLabel.text = self.arrDecks[indexPath.row];
        }
        cell.accessoryType = indexPath.row == self.selectedDeckIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        self.selectedDeckIndex = (int)indexPath.row;
        [self loadCurrentDeck];
    }
    
    [tableView reloadData];
}

#pragma mark - 
-(void) stepperChanged:(QuantityTableViewCell*) cell withValue:(int) value
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
}

@end
