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
#import "Format.h"
#import "LimitedSearchViewController.h"
#import "SearchResultsTableViewCell.h"

@implementation DeckDetailsViewController
{
    NSArray *_arrDetailsSections;
    NSArray *_arrCardSections;
    UIView *_viewSegmented;
}

@synthesize deck = _deck;
@synthesize segmentedControl = _segmentedControl;
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
    
    _arrDetailsSections = @[@"", @"Name", @"Number of Cards", @"Format", @"Notes", @"Original Designer", @"Year"];
    _arrCardSections = @[@"", @"Lands", @"Creatures", @"Other Spells", @"Sideboard"];

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
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Details", @"Cards"]];
    self.segmentedControl.frame = CGRectMake(dX+10, dY+7, dWidth-20, 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    dHeight = 44;
    _viewSegmented = [[UIView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    _viewSegmented.backgroundColor = [UIColor whiteColor];
    [_viewSegmented addSubview:self.segmentedControl];
    
    dHeight = 44;
    dY = self.view.frame.size.height - dHeight;
    dWidth = self.view.frame.size.width;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    
    [self.view addSubview:self.tblCards];
    [self.view addSubview:self.bottomToolbar];
}

-(void) viewDidAppear:(BOOL)animated
{
    NSDictionary *dict = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Decks/%@.json", self.deck.name]];
    Deck *deck = [[Deck alloc] initWithDictionary:dict];
    
    self.deck = deck;
    self.navigationItem.title = self.deck.name;
    [self.tblCards reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) segmentedControlChangedValue:(id) sender
{
    [self.tblCards reloadData];
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
    view.deck = self.deck;
    [self.navigationController pushViewController:view animated:YES];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            if (section == 0)
            {
                return _viewSegmented.frame.size.height;
            }
        }
        case 1:
        {
            if (section == 0)
            {
                return _viewSegmented.frame.size.height;
            }
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _viewSegmented;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        if (indexPath.section == 0)
        {
            return 0;
        }
        else if (indexPath.section == 4) // Notes
        {
            return SEARCH_RESULTS_CELL_HEIGHT;
        }
        else
        {
            return UITableViewAutomaticDimension;
        }
    }
    
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (rows > 1)
    {
        switch (indexPath.section)
        {
            case 0:
            {
                return UITableViewAutomaticDimension;
            }
            case 1:
            {
                if (indexPath.row < self.deck.arrLands.count)
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
                if (indexPath.row < self.deck.arrCreatures.count)
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
                if (indexPath.row < self.deck.arrOtherSpells.count)
                {
                    return SEARCH_RESULTS_CELL_HEIGHT;
                }
                else
                {
                    return UITableViewAutomaticDimension;
                }
            }
            case 4:
            {
                if (indexPath.row < self.deck.arrSideboard.count)
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        return section == 0 ? nil : _arrDetailsSections[section];
    }
    
    int count = 0;
    
    switch (section)
    {
        case 1:
        {
            for (NSDictionary *dict in self.deck.arrLands)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 2:
        {
            for (NSDictionary *dict in self.deck.arrCreatures)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 3:
        {
            for (NSDictionary *dict in self.deck.arrOtherSpells)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        case 4:
        {
            for (NSDictionary *dict in self.deck.arrSideboard)
            {
                count += [dict[@"qty"] intValue];
            }
            break;
        }
        default:
        {
            return nil;
        }
    }
    
    return [NSString stringWithFormat:@"%@: %tu", _arrCardSections[section], count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            return _arrDetailsSections.count;
        }
        case 1:
        {
            return _arrCardSections.count;
        }
        default:
        {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        return 1;
    }
    
	switch (section)
    {
        case 1:
        {
            return self.deck.arrLands.count + 1;
        }
        case 2:
        {
            return self.deck.arrCreatures.count + 1;
        }
        case 3:
        {
            return self.deck.arrOtherSpells.count + 1;
        }
        case 4:
        {
            return self.deck.arrSideboard.count + 1;
        }
        default:
        {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell0"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell0"];
        }
        
        cell.textLabel.text = nil;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (indexPath.section)
        {
            case 1:
            {
                cell.textLabel.text = self.deck.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 2:
            {
                cell.textLabel.text = [NSString stringWithFormat:@"Mainboard: %d / Sideboard: %d", [self.deck cardsInBoard:MainBoard], [self.deck cardsInBoard:SideBoard]];
                cell.userInteractionEnabled = NO;
                break;
            }
            case 3:
            {
                cell.textLabel.text = self.deck.format;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 4:
            {
                cell.textLabel.text = self.deck.notes;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 5:
            {
                cell.textLabel.text = self.deck.originalDesigner;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 6:
            {
                cell.textLabel.text = self.deck.year ? [NSString stringWithFormat:@"%@", self.deck.year] : @"";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
        }
        
        return cell;
    }
    
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (rows > 1)
    {
        switch (indexPath.section)
        {
            case 1:
            {
                if (indexPath.row < self.deck.arrLands.count)
                {
                    NSDictionary *dict = self.deck.arrLands[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]]];
                }
                break;
            }
            case 2:
            {
                if (indexPath.row < self.deck.arrCreatures.count)
                {
                    NSDictionary *dict = self.deck.arrCreatures[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]]];
                }
                break;
            }
            case 3:
            {
                if (indexPath.row < self.deck.arrOtherSpells.count)
                {
                    NSDictionary *dict = self.deck.arrOtherSpells[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]]];
                }
                break;
            }
            case 4:
            {
                if (indexPath.row < self.deck.arrSideboard.count)
                {
                    NSDictionary *dict = self.deck.arrSideboard[indexPath.row];
                    cell = [self createSearchResultsTableCell:dict];
                }
                else
                {
                    cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]]];
                }
                break;
            }
        }
    }
    else
    {
        if (indexPath.section != 0)
        {
            cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]]]
            ;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        FieldEditorViewController *view = [[FieldEditorViewController alloc] init];
        UITableViewCell *cell = [self tableView:self.tblCards cellForRowAtIndexPath:indexPath];
        
        view.delegate = self;
        view.fieldName = _arrDetailsSections[indexPath.section];
        view.oldValue = cell.textLabel.text;
        
        switch (indexPath.section)
        {
            case 1:
            {
                view.fieldEditorType = FieldEditorTypeText;
                break;
            }
            case 3:
            {
                view.fieldEditorType = FieldEditorTypeSelection;
                NSMutableArray *arrFormats = [[NSMutableArray alloc] init];
                for (Format * format in [Format MR_findAllSortedBy:@"name" ascending:YES])
                {
                    [arrFormats addObject:format.name];
                }
                view.fieldOptions = arrFormats;
                break;
            }
            case 4:
            {
                view.fieldEditorType = FieldEditorTypeTextArea;
                break;
            }
            case 5:
            {
                view.fieldEditorType = FieldEditorTypeText;
                break;
            }
            case 6:
            {
                view.fieldEditorType = FieldEditorTypeNumber;
                break;
            }
        }
        [self.navigationController pushViewController:view animated:YES];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        NSPredicate *predicate;
        
        if (rows > 1)
        {
            Card *card;
            
            switch (indexPath.section)
            {
                case 1:
                {
                    if (indexPath.row < self.deck.arrLands.count)
                    {
                        card = self.deck.arrLands[indexPath.row][@"card"];
                    }
                    else
                    {
                        predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"land"];
                    }
                    break;
                }
                case 2:
                {
                    if (indexPath.row < self.deck.arrCreatures.count)
                    {
                        card = self.deck.arrCreatures[indexPath.row][@"card"];
                    }
                    else
                    {
                        predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"creature"];
                    }
                    break;
                }
                case 3:
                {
                    if (indexPath.row < self.deck.arrOtherSpells.count)
                    {
                        card = self.deck.arrOtherSpells[indexPath.row][@"card"];
                    }
                    else
                    {
                        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"land"];
                        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"creature"];
                        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
                    }
                    break;
                }
                case 4:
                {
                    if (indexPath.row < self.deck.arrSideboard.count)
                    {
                        card = self.deck.arrSideboard[indexPath.row][@"card"];
                    }
                    break;
                }
            }
            
            if (card)
            {
                AddCardViewController *view = [[AddCardViewController alloc] init];
                
                view.arrDecks = [[NSMutableArray alloc] initWithArray:@[self.deck.name]];
                
                view.arrCollections = [[NSMutableArray alloc] init];
                for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Collections"
                                                                      fromFileSystem:FileSystemLocal])
                {
                    [view.arrCollections addObject:[file stringByDeletingPathExtension]];
                }
                
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
                    return;
                }
                case 1:
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"land"];
                    break;
                }
                case 2:
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", @"creature"];
                    break;
                }
                case 3:
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
}

#pragma mark - FieldEditorViewControllerDelegate
-(void) editorSaved:(id) newValue
{
    NSString *path = [NSString stringWithFormat:@"/Decks/%@.json", self.deck.name];
    [[FileManager sharedInstance] deleteFileAtPath:path];
    
    switch ([self.tblCards indexPathForSelectedRow].section)
    {
        case 1:
        {
            self.deck.name = newValue;
            break;
        }
        case 3:
        {
            self.deck.format = newValue;
            break;
        }
        case 4:
        {
            self.deck.notes = newValue;
            break;
        }
        case 5:
        {
            self.deck.originalDesigner = newValue;
            break;
        }
        case 6:
        {
            self.deck.year = [NSNumber numberWithInt:[newValue intValue]];
            break;
        }
    }
    
    path = [NSString stringWithFormat:@"/Decks/%@.json", self.deck.name];
    [self.deck save:path];
    [self.tblCards reloadData];
}

@end
