//
//  DeckDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DeckDetailsViewController.h"
#import "JJJ/JJJ.h"
#import "Database.h"
#import "FileManager.h"
#import "SearchResultsTableViewCell.h"

@implementation DeckDetailsViewController
{
    NSArray *_arrSections;
    NSMutableArray *_arrLands;
    NSMutableArray *_arrCreatures;
    NSMutableArray *_arrOtherSpells;
    NSMutableArray *_arrSideboard;
}

@synthesize dictDeck = _dictDeck;
@synthesize tblCards = _tblCards;
@synthesize bottomToolbar = _bottomToolbar;

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
    
    _arrSections = @[@"Lands", @"Creatures", @"Other Spells", @"Sideboard"];
    [self loadDeck];
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - 44;
    
    self.tblCards = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                 style:UITableViewStyleGrouped];
    self.tblCards.delegate = self;
    self.tblCards.dataSource = self;
    [self.tblCards registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell"];
    
    dHeight = 44;
    dY = self.view.frame.size.height - dHeight;
    dWidth = self.view.frame.size.width;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    
    [self.view addSubview:self.tblCards];
    [self.view addSubview:self.bottomToolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadDeck
{
    NSDictionary *deck = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Decks/%@.json", _dictDeck[@"name"]]];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"card.name"  ascending:YES];
    
    _arrLands = [[NSMutableArray alloc] init];
    _arrCreatures = [[NSMutableArray alloc] init];
    _arrOtherSpells = [[NSMutableArray alloc] init];
    _arrSideboard = [[NSMutableArray alloc] init];
    int totalCards = 0;
    
    for (NSDictionary *dict in deck[@"mainBoard"])
    {
        Card *card = [[Database sharedInstance] findCard:dict[@"card"] inSet:dict[@"set"]];
        
        if ([JJJUtil string:card.type containsString:@"land"])
        {
            [_arrLands addObject:@{@"card": card,
                                   @"qty" : dict[@"qty"]}];
            totalCards += [dict[@"qty"] intValue];
        }
        else if ([JJJUtil string:card.type containsString:@"creature"])
        {
            [_arrCreatures addObject:@{@"card": card,
                                       @"qty" : dict[@"qty"]}];
            totalCards += [dict[@"qty"] intValue];
        }
        else
        {
            [_arrOtherSpells addObject:@{@"card": card,
                                    @"qty" : dict[@"qty"]}];
            totalCards += [dict[@"qty"] intValue];
        }
    }
    
    for (NSDictionary *dict in deck[@"sideBoard"])
    {
        Card *card = [[Database sharedInstance] findCard:dict[@"card"] inSet:dict[@"set"]];
        
        [_arrSideboard addObject:@{@"card": card,
                                   @"qty" : dict[@"qty"]}];
    }
    
    _arrLands = [[NSMutableArray alloc] initWithArray:[_arrLands sortedArrayUsingDescriptors:@[sorter]]];
    _arrCreatures = [[NSMutableArray alloc] initWithArray:[_arrCreatures sortedArrayUsingDescriptors:@[sorter]]];
    _arrOtherSpells = [[NSMutableArray alloc] initWithArray:[_arrOtherSpells sortedArrayUsingDescriptors:@[sorter]]];
    _arrSideboard = [[NSMutableArray alloc] initWithArray:[_arrSideboard sortedArrayUsingDescriptors:@[sorter]]];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ / %d Cards", deck[@"name"], totalCards];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SEARCH_RESULTS_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int count = 0;
    
    switch (section)
    {
        case 0:
        {
            for (NSDictionary *dict in _arrLands)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 1:
        {
            for (NSDictionary *dict in _arrCreatures)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 2:
        {
            for (NSDictionary *dict in _arrOtherSpells)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 3:
        {
            for (NSDictionary *dict in _arrSideboard)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
    }
    
    return [NSString stringWithFormat:@"%@: %tu", _arrSections[section], count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
    {
        case 0:
        {
            return _arrLands.count;
            
        }
        case 1:
        {
            return _arrCreatures.count;
        }
        case 2:
        {
            return _arrOtherSpells.count;
        }
        case 3:
        {
            return _arrSideboard.count;
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
    
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
    }
    
    Card *card;
    int badgeValue = 0;
    switch (indexPath.section)
    {
        case 0:
        {
            NSDictionary *dict = _arrLands[indexPath.row];
            
            card = dict[@"card"];
            badgeValue = [dict[@"qty"] intValue];
            break;
        }
        case 1:
        {
            NSDictionary *dict = _arrCreatures[indexPath.row];
            
            card = dict[@"card"];
            badgeValue = [dict[@"qty"] intValue];
            
            
            break;
        }
        case 2:
        {
            NSDictionary *dict = _arrOtherSpells[indexPath.row];
            
            card = dict[@"card"];
            badgeValue = [dict[@"qty"] intValue];
            break;
        }
        case 3:
        {
            NSDictionary *dict = _arrSideboard[indexPath.row];
            
            card = dict[@"card"];
            badgeValue = [dict[@"qty"] intValue];
            break;
        }
    }
    
    [cell displayCard:card];
    [cell addBadge:badgeValue];
    
    return cell;
}

@end
