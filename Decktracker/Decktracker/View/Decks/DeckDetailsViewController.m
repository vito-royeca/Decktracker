//
//  DeckDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DeckDetailsViewController.h"
#import "JJJ/JJJ.h"
#import "AddCardViewController.h"
#import "Database.h"
#import "FileManager.h"
#import "LimitedSearchViewController.h"
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

    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - 44;
    
    self.tblCards = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                 style:UITableViewStyleGrouped];
    self.tblCards.delegate = self;
    self.tblCards.dataSource = self;
    [self.tblCards registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell1"];
    
    dHeight = 44;
    dY = self.view.frame.size.height - dHeight;
    dWidth = self.view.frame.size.width;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    
    [self.view addSubview:self.tblCards];
    [self.view addSubview:self.bottomToolbar];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self loadDeck];
    [self.tblCards reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadDeck
{
    NSDictionary *deck = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Decks/%@.json", _dictDeck[@"name"]]];
    
    NSSortDescriptor *sorter1 = [[NSSortDescriptor alloc] initWithKey:@"card.name"  ascending:YES];
    NSSortDescriptor *sorter2 = [[NSSortDescriptor alloc] initWithKey:@"card.set.releaseDate"  ascending:YES];
    NSArray *sorters = @[sorter1, sorter2];
    
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
    
    _arrLands = [[NSMutableArray alloc] initWithArray:[_arrLands sortedArrayUsingDescriptors:sorters]];
    _arrCreatures = [[NSMutableArray alloc] initWithArray:[_arrCreatures sortedArrayUsingDescriptors:sorters]];
    _arrOtherSpells = [[NSMutableArray alloc] initWithArray:[_arrOtherSpells sortedArrayUsingDescriptors:sorters]];
    _arrSideboard = [[NSMutableArray alloc] initWithArray:[_arrSideboard sortedArrayUsingDescriptors:sorters]];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ / %d Cards", deck[@"name"], totalCards];
}

-(UITableViewCell*) createSearchResultsTableCell:(NSDictionary*) dict
{
    SearchResultsTableViewCell *cell = [self.tblCards dequeueReusableCellWithIdentifier:@"Cell1"];
    if (cell == nil)
    {
        cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:@"Cell1"];
    }
    
    [cell displayCard:dict[@"card"]];
    [cell addBadge:[dict[@"qty"] intValue]];
    return cell;
}

-(UITableViewCell*) createAddTableCell:(NSString*) text
{
    UITableViewCell *cell = [self.tblCards dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell2"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = text;
    return cell;
}

-(void) showLimitedSearch:(NSPredicate*) predicate
{
    LimitedSearchViewController *view = [[LimitedSearchViewController alloc] init];
    
    view.predicate = predicate;
    view.dictDeck = self.dictDeck;
    [self.navigationController pushViewController:view animated:YES];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (rows > 1)
    {
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row < _arrLands.count)
                {
                    return SEARCH_RESULTS_CELL_HEIGHT;
                }
                else
                {
                    return UITableViewAutomaticDimension;
                }
            }
            case 1:
            {
                if (indexPath.row < _arrCreatures.count)
                {
                    return SEARCH_RESULTS_CELL_HEIGHT;
                }
                else
                {
                    return UITableViewAutomaticDimension;
                }
            }
            case 2:
            {
                if (indexPath.row < _arrOtherSpells.count)
                {
                    return SEARCH_RESULTS_CELL_HEIGHT;
                }
                else
                {
                    return UITableViewAutomaticDimension;
                }
            }
            case 3:
            {
                if (indexPath.row < _arrSideboard.count)
                {
                    return SEARCH_RESULTS_CELL_HEIGHT;
                }
                else
                {
                    return UITableViewAutomaticDimension;
                }
            }
        }
    }
    
    return UITableViewAutomaticDimension;
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
            return _arrLands.count + 1;
        }
        case 1:
        {
            return _arrCreatures.count + 1;
        }
        case 2:
        {
            return _arrOtherSpells.count + 1;
        }
        case 3:
        {
            return _arrSideboard.count + 1;
        }
        default:
        {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    UITableViewCell *cell;
    
    if (rows > 1)
    {
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row < _arrLands.count)
                {
                    NSDictionary *dict = _arrLands[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrSections[indexPath.section]]];
                }
                break;
            }
            case 1:
            {
                if (indexPath.row < _arrCreatures.count)
                {
                    NSDictionary *dict = _arrCreatures[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrSections[indexPath.section]]];
                }
                break;
            }
            case 2:
            {
                if (indexPath.row < _arrOtherSpells.count)
                {
                    NSDictionary *dict = _arrOtherSpells[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrSections[indexPath.section]]];
                }
                break;
            }
            case 3:
            {
                if (indexPath.row < _arrSideboard.count)
                {
                    NSDictionary *dict = _arrSideboard[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrSections[indexPath.section]]];
                }
                break;
            }
        }
    }
    else
    {
        cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrSections[indexPath.section]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    NSPredicate *predicate;
    
    if (rows > 1)
    {
        Card *card;
        
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row < _arrLands.count)
                {
                    card = _arrLands[indexPath.row][@"card"];
                }
                else
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"land"];
                }
                break;
            }
            case 1:
            {
                if (indexPath.row < _arrCreatures.count)
                {
                    card = _arrCreatures[indexPath.row][@"card"];
                }
                else
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"creature"];
                }
                break;
            }
            case 2:
            {
                if (indexPath.row < _arrOtherSpells.count)
                {
                    card = _arrOtherSpells[indexPath.row][@"card"];
                }
                else
                {
                    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"land"];
                    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"creature"];
                    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
                }
                break;
            }
            case 3:
            {
                if (indexPath.row < _arrSideboard.count)
                {
                    card = _arrSideboard[indexPath.row][@"card"];
                }
                break;
            }
        }
        
        if (card)
        {
            AddCardViewController *view = [[AddCardViewController alloc] init];
        
            view.arrDecks = [[NSMutableArray alloc] initWithArray:@[self.dictDeck[@"name"]]];
            view.arrCollections = [[NSMutableArray alloc] initWithArray:[[FileManager sharedInstance] findFilesAtPath:@"/Collections"]];
            view.card = card;
            view.showCardButtonVisible = YES;
            view.segmentedControlIndex = 0;
            [self.navigationController pushViewController:view animated:YES];
        }
        
        else
        {
            [self showLimitedSearch:predicate];
        }
    }
    
    else
    {
        switch (indexPath.section)
        {
            case 0:
            {
                predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"land"];
                break;
            }
            case 1:
            {
                predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"creature"];
                break;
            }
            case 2:
            {
                NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"land"];
                NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"creature"];
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
                break;
            }
        }
        
        [self showLimitedSearch:predicate];
    }
}

@end
