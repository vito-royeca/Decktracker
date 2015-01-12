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
#import "CustomViewCell.h"
#import "Database.h"
#import "DeckIASKSettingsStore.h"
#import "DecksViewController.h"
#import "DTFormat.h"
#import "FileManager.h"
#import "LimitedSearchViewController.h"
#import "SearchResultsTableViewCell.h"
#import "Decktracker-Swift.h"

#import "IASKSpecifierValuesViewController.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation DeckDetailsViewController
{
    NSArray *_arrCardSections;
    NSArray *_arrToolSections;
    UIView *_viewSegmented;
}

@synthesize btnBack = _btnBack;
@synthesize segmentedControl = _segmentedControl;
@synthesize tblCards = _tblCards;
@synthesize cardDetailsViewController = _cardDetailsViewController;
@synthesize deck = _deck;

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
    
    _arrCardSections = @[@"", @"Lands", @"Creatures", @"Other Spells", @"Sideboard"];
    _arrToolSections = @[@{@"": @[@""]},
                         @{@"Statistics" : @[/*@"Mana Curve",*/ @"Card Type Distribution", @"Color Distribution"/*, @"Mana Source Distribution"*/]},
                         @{@"Draws" :@[@"Starting Hand"]},
                         /*@{@"Print" :@[@"Proxies", @"Deck Sheet"]}*/];

    CGFloat dX = 0;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = 44;
    
    self.btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(backButtonTapped)];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Cards", @"Details", @"Tools"]];
    self.segmentedControl.frame = CGRectMake(10, 7, dWidth-20, 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    _viewSegmented = [[UIView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    _viewSegmented.backgroundColor = [UIColor whiteColor];
    [_viewSegmented addSubview:self.segmentedControl];
    
    
    dY = _viewSegmented.frame.origin.y + _viewSegmented.frame.size.height;
    dHeight = self.view.frame.size.height - dY;
    self.tblCards = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                 style:UITableViewStylePlain];
    self.tblCards.delegate = self;
    self.tblCards.dataSource = self;
    [self.tblCards registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell1"];
    
    self.navigationItem.leftBarButtonItem = self.btnBack;
    [self.view addSubview:_viewSegmented];
    [self.view addSubview:self.tblCards];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kIASKAppSettingChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];
    
#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Deck Details"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
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

-(void) backButtonTapped
{
    [self.deck deletePieImage];
    [self.cardDetailsViewController.settingsStore synchronize];
    
    DecksViewController *view = ((UINavigationController*)self.parentViewController).viewControllers[0];
    [view loadDecks];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void) segmentedControlChangedValue:(id) sender
{
    CGFloat dX = 0;
    CGFloat dY = _viewSegmented.frame.origin.y + _viewSegmented.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY;
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        [self.cardDetailsViewController.settingsStore synchronize];
        [self.cardDetailsViewController.view removeFromSuperview];

        self.tblCards = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                     style:UITableViewStylePlain];
        self.tblCards.delegate = self;
        self.tblCards.dataSource = self;
        [self.tblCards registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
            forCellReuseIdentifier:@"Cell1"];
        
        [self.view addSubview:self.tblCards];
    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        [self.tblCards removeFromSuperview];
        
        DeckIASKSettingsStore *deckSettingsStore = [[DeckIASKSettingsStore alloc] init];
        deckSettingsStore.deck = self.deck;
        
        self.cardDetailsViewController = [[IASKAppSettingsViewController alloc] init];
        self.cardDetailsViewController.view.frame = CGRectMake(dX, dY, dWidth, dHeight);
        self.cardDetailsViewController.delegate = self;
        self.cardDetailsViewController.settingsStore = deckSettingsStore;
        self.cardDetailsViewController.file = @"deck.inApp";
        self.cardDetailsViewController.showCreditsFooter = NO;
        self.cardDetailsViewController.showDoneButton = NO;
        [self.view addSubview:self.cardDetailsViewController.view];
    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        [self.cardDetailsViewController.settingsStore synchronize];
        [self.cardDetailsViewController.view removeFromSuperview];
        
        self.tblCards = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                     style:UITableViewStylePlain];
        self.tblCards.delegate = self;
        self.tblCards.dataSource = self;
        [self.view addSubview:self.tblCards];
    }
}

-(UITableViewCell*) createSearchResultsTableCell:(NSDictionary*) dict
{
    SearchResultsTableViewCell *cell = [self.tblCards dequeueReusableCellWithIdentifier:@"Cell1"];
    
    if (!cell)
    {
        cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:@"Cell1"];
    }
    
    [cell displayCard:dict[@"card"]];
    [cell addBadge:[dict[@"qty"] intValue]];
    return cell;
}

-(UITableViewCell*) createAddTableCell:(NSString*) text withImagePath:(NSString*) imagePath
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
    view.deckName = self.deck.name;
    [self.navigationController pushViewController:view animated:YES];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
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
    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        if (indexPath.section == 0)
        {
            return 0;
        }
        else
        {
            return UITableViewAutomaticDimension;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
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
    
    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        return section == 0 ? nil : [[_arrToolSections[section] allKeys] firstObject];
    }
    
    else
    {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            return _arrCardSections.count;
        }
        case 2:
        {
            return _arrToolSections.count;
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
    
    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        NSDictionary *dict = _arrToolSections[section];
        NSArray *array = [dict valueForKey:[[dict allKeys] firstObject]];
        return array.count;
    }
    
	else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
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
                        NSString *path = [NSString stringWithFormat:@"%@/images/other/land/32.png", [[NSBundle mainBundle] bundlePath]];
                        cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]] withImagePath:path];
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
                        NSString *path = [NSString stringWithFormat:@"%@/images/other/creature/32.png", [[NSBundle mainBundle] bundlePath]];
                        cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]] withImagePath:path];
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
                        NSString *path = [NSString stringWithFormat:@"%@/images/other/instant/32.png", [[NSBundle mainBundle] bundlePath]];
                        cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]] withImagePath:path];
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
                        NSString *path = [NSString stringWithFormat:@"%@/images/other/multiple/32.png", [[NSBundle mainBundle] bundlePath]];
                        cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]] withImagePath:path];
                    }
                    break;
                }
            }
        }
        else
        {
            if (indexPath.section != 0)
            {
                NSString *path;
                
                switch (indexPath.section)
                {
                    case 1:
                    {
                        path = [NSString stringWithFormat:@"%@/images/other/land/32.png", [[NSBundle mainBundle] bundlePath]];
                        break;
                    }
                    case 2:
                    {
                        path = [NSString stringWithFormat:@"%@/images/other/creature/32.png", [[NSBundle mainBundle] bundlePath]];
                        break;
                    }
                    case 3:
                    {
                        path = [NSString stringWithFormat:@"%@/images/other/instant/32.png", [[NSBundle mainBundle] bundlePath]];
                        break;
                    }
                    case 4:
                    {
                        path = [NSString stringWithFormat:@"%@/images/other/multiple/32.png", [[NSBundle mainBundle] bundlePath]];
                        break;
                    }
                }
                cell = [self createAddTableCell:[NSString stringWithFormat:@"Add %@", _arrCardSections[indexPath.section]] withImagePath:path];

            }
        }
    }

    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell0"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell0"];
        }
        
        cell.textLabel.text = nil;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.section != 0)
        {
            NSDictionary *dict = _arrToolSections[indexPath.section];
            NSString *key = [[dict allKeys] firstObject];
            NSArray *arrFunctions = [dict valueForKey:key];
            cell.textLabel.text = arrFunctions[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        NSPredicate *predicate;
        
        if (rows > 1)
        {
            DTCard *card;
            
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
                        predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", @"type", @"creature", @"type", @"summon"];
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
                        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"summon"];
                        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2, pred3]];
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
                
                [view setCard:card];
                view.createButtonVisible = NO;
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
                    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", @"type", @"creature", @"type", @"summon"];
                    break;
                }
                case 3:
                {
                    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"land"];
                    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"creature"];
                    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"NOT(%K CONTAINS[cd] %@)", @"type", @"summon"];
                    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2, pred3]];
                    break;
                }
            }
            
            [self showLimitedSearch:predicate];
        }
    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        UIViewController *view;
        
        switch (indexPath.section)
        {
            case 1:
            {
                switch (indexPath.row)
                {
                    case 0:
                    {
                        // Card Type Distribution
                        PieChartViewController *view2 = [[PieChartViewController alloc] init];
                        view2.graphTitle = self.deck.name;
                        view2.conciseData = [self.deck cardTypeDistribution:NO];
                        view2.detailedData = [self.deck cardTypeDistribution:YES];
                        view2.navigationItem.title = @"Card Type Distribution";
                        view = view2;
                        break;
                    }
                    case 1:
                    {
                        // Color Distribution
                        PieChartViewController *view2 = [[PieChartViewController alloc] init];
                        view2.graphTitle = self.deck.name;
                        view2.conciseData = [self.deck colorDistribution:NO];
                        view2.conciseColors = [self.deck cardColors:NO];
                        view2.detailedData = [self.deck colorDistribution:YES];
                        view2.detailedColors = [self.deck cardColors:YES];
                        
                        view2.navigationItem.title = @"Color Distribution";
                        view = view2;
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
                break;
            }
            case 2:
            {
                // Starting Hand
                StartingHandViewController *view2 = [[StartingHandViewController alloc] init];
                
                view2.deck = self.deck;
                view = view2;
                break;
            }
            case 3:
            {
                switch (indexPath.row)
                {
                    case 0:
                    {
                        // Proxies
                        break;
                    }
                    case 1:
                    {
                        // Deck Sheet
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
                break;
            }
            default:
            {
                break;
            }
        }
        
        if (view)
        {
            [self.navigationController pushViewController:view animated:YES];
        }
    }
}

#pragma mark - IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [sender.tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier
{
    CustomViewCell *cell = (CustomViewCell*)[tableView dequeueReusableCellWithIdentifier:specifier.key];
    
    if (!cell)
    {
        cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell"
                                                               owner:self
                                                             options:nil] objectAtIndex:0];
    }
    
    cell.textView.text = [self.cardDetailsViewController.settingsStore objectForKey:@"notes"];
    cell.textView.delegate = self;
    [cell setNeedsLayout];
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier
{
    if ([specifier.key isEqualToString:@"notes"])
    {
        return 44*3;
    }
    return 0;
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier
{
    if ([specifier.key isEqualToString:@"format"])
    {
        NSMutableArray *arrFormats = [[NSMutableArray alloc] init];
        for (DTFormat *format in [DTFormat MR_findAllSortedBy:@"name" ascending:YES])
        {
            [arrFormats addObject:format.name];
        }
        NSDictionary *dict = @{@"Title": @"Format",
                               @"DefaultValue": self.deck.format,
                               @"Key": @"format",
                               @"Titles": arrFormats,
                               @"Values": arrFormats,
                               @"Type": kIASKPSMultiValueSpecifier};
        
        IASKSpecifierValuesViewController *targetViewController = [[IASKSpecifierValuesViewController alloc] init];
        [targetViewController setCurrentSpecifier:[[IASKSpecifier alloc] initWithSpecifier:dict]];
        targetViewController.settingsReader = self.cardDetailsViewController.settingsReader;
        targetViewController.settingsStore = self.cardDetailsViewController.settingsStore;
        targetViewController.navigationItem.title = @"Select Format";
        [self.navigationController pushViewController:targetViewController animated:YES];
    }
}

-(void) settingsChanged:(id) sender
{
    NSDictionary *dict = [sender userInfo];
    
    for (NSString *key in dict)
    {
        if ([key isEqualToString:@"format"])
        {
            [self.cardDetailsViewController.settingsStore setObject:dict[key] forKey:key];
            [self.cardDetailsViewController.tableView reloadData];
            break;
        }
    }
}

#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.cardDetailsViewController.settingsStore setObject:textView.text forKey:@"notes"];
}

@end
