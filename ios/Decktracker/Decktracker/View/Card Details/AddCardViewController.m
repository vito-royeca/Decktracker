//
//  AddCardViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AddCardViewController.h"
#import "CardDetailsViewController.h"
#import "Deck.h"
#import "FileManager.h"
#import "InAppPurchase.h"
#import "MainViewController.h"
#import "CardSummaryView.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation AddCardViewController
{
    Deck *_currentDeck;
}

-(void) setCardId:(NSString*) cardId
{
    _cardId = cardId;
    [[FileManager sharedInstance] downloadCardImage:_cardId immediately:YES];
}

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
    [self.tblAddTo registerNib:[UINib nibWithNibName:@"QuantityTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"Cell2"];
    [self.tblAddTo registerNib:[UINib nibWithNibName:@"QuantityTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"Cell3"];

    dHeight = 44;
    
    dY = self.view.frame.size.height - dHeight;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    NSMutableArray *arrButtons = [[NSMutableArray alloc] init];
    
    if (self.createButtonVisible)
    {
        self.btnCreate = [[UIBarButtonItem alloc] initWithTitle:@"Create New Deck"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(btnCreateTapped:)];
        
        
        [arrButtons addObject:self.btnCreate];
    }
    
    if (self.showCardButtonVisible)
    {
        self.btnShowCard = [[UIBarButtonItem alloc] initWithTitle:@"Show Card"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(btnShowCardTapped:)];
        
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
    [self loadCurrentDeck];

#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
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
    if (_currentDeck)
    {
        [_currentDeck save:[NSString stringWithFormat:@"/Decks/%@.json", _currentDeck.name]];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnCreateTapped:(id) sender
{
    void (^handler)(UIAlertController*) = ^void(UIAlertController *alert) {
        NSDictionary *dict = @{@"name" : [((UITextField*)[alert.textFields firstObject]) text],
                               @"format" : @"Standard",
                               @"mainBoard" : @[],
                               @"sideBoard" : @[]};
        [[FileManager sharedInstance] saveData:dict
                                        atPath:[NSString stringWithFormat:@"/Decks/%@.json", dict[@"name"]]];
        self.arrDecks = [[NSMutableArray alloc] init];
        for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Decks"
                                                              fromFileSystem:FileSystemLocal])
        {
            [self.arrDecks addObject:[file stringByDeletingPathExtension]];
        }
        self.selectedDeckIndex = (int)[self.arrDecks indexOfObject:dict[@"name"]];
        [self loadCurrentDeck];
        
#ifndef DEBUG
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.navigationItem.title
                                                              action:nil
                                                               label:@"New Deck"
                                                               value:nil] build]];
#endif
    };
    
    void (^textFieldHandler)(UITextField*) = ^void(UITextField *textField) {
        textField.text = @"New Deck Name";
    };
    
    [JJJUtil alertWithTitle:@"Create New Deck"
                    message:nil
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@{@"Ok": handler}
          textFieldHandlers:@[textFieldHandler]];
}

-(void) btnShowCardTapped:(id) sender
{
    CardDetailsViewController *view = [[CardDetailsViewController alloc] init];
    
    view.cardIds = nil;
    view.addButtonVisible = NO;
    [view setCardId:self.cardId];
    
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

-(void) configureQuantityCell:(QuantityTableViewCell*) cell
                      withTag:(int) tag
                 withKey:(NSString*) key
{
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    
    cell.delegate = self;
    cell.tag = tag;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (![card.type hasPrefix:@"Basic Land"])
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
        
        int qty = [_currentDeck cards:card.cardId inBoard:deckboard];
        cell.txtQuantity.text = [NSString stringWithFormat:@"%d", qty];
        cell.stepper.value = qty;
    }
    else
    {
        cell.txtQuantity.text = @"0";
        cell.stepper.value = 0;
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
        return self.arrDecks.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0)
    {
        return CARD_SUMMARY_VIEW_CELL_HEIGHT;
    }
    else if (indexPath.section == 1)
    {
        return 44; //_viewSegmented.frame.size.height;
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
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    CardSummaryView *cardSummaryView;
    
    cell.userInteractionEnabled = YES;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        
        if (cell)
        {
            for (UIView *subView in cell.contentView.subviews)
            {
                if ([subView isKindOfClass:[CardSummaryView class]])
                {
                    cardSummaryView = (CardSummaryView*)subView;
                    break;
                }
            }
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"Cell1"];
            cardSummaryView = [[[NSBundle mainBundle] loadNibNamed:@"CardSummaryView" owner:self options:nil] firstObject];
            cardSummaryView.frame = CGRectMake(0, 0, tableView.frame.size.width, CARD_SUMMARY_VIEW_CELL_HEIGHT);
            [cell.contentView addSubview:cardSummaryView];
        }
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.userInteractionEnabled = NO;
        [cardSummaryView displayCard:self.cardId];
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
        
        NSString *key = @"mainBoard";
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
        
        NSString *key = @"sideBoard";
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
    if (indexPath.section == 4)
    {
        self.selectedDeckIndex = (int)indexPath.row;
        [self loadCurrentDeck];
    }
}

#pragma mark - QuantityTableViewCellDelegate
-(void) stepperChanged:(QuantityTableViewCell*) cell withValue:(int) value
{
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    
    if (!_currentDeck || self.selectedDeckIndex < 0)
    {
        [JJJUtil alertWithTitle:@"Error"
                     andMessage:@"You may need to create one Deck or select a Deck from the list."];
    }
    else
    {
        switch (cell.tag)
        {
            case 0:
            {
                [_currentDeck updateDeck:MainBoard
                                withCard:card.cardId
                               withValue:value];
                cell.stepper.value = value;
                cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                break;
            }
            case 1:
            {
                [_currentDeck updateDeck:SideBoard
                                withCard:card.cardId
                               withValue:value];
                cell.stepper.value = value;
                cell.txtQuantity.text = [NSString stringWithFormat:@"%d", value];
                break;
            }
        }
    }
}

@end
