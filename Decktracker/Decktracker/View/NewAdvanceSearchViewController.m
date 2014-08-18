//
//  NewAdvanceSearchViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "NewAdvanceSearchViewController.h"
#import "Artist.h"
#import "CardRarity.h"
#import "CardType.h"
#import "Format.h"
#import "Magic.h"
#import "Set.h"

@implementation NewAdvanceSearchViewController
{
    NSMutableArray *_currentQuery;
    NSArray *_arrFilters;
    NSArray *_arrSorters;
    NSArray *_cardTypes;
}

@synthesize segmentedControl = _segmentedControl;
@synthesize tblView = _tblView;
@synthesize arrCurrentQuery = _arrCurrentQuery;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrCurrentQuery = [[NSMutableArray alloc] init];
    _arrFilters = @[@"Name", @"Set", @"Rarity", @"Format", @"Type", @"Subtype", @"Color", @"Text", @"Flavor Text",
                    @"Artist"];
    
    _arrSorters = @[@"Name"];
    
    _cardTypes = @[@"Artifact", @"Basic", @"Conspiracy", @"Creature", @"Enchantment", @"Instant", @"Land",
                   @"Legendary", @"Ongoing", @"Phenomenon", @"Plane", @"Planeswalker", @"Scheme", @"Snow",
                   @"Sorcery", @"Tribal", @"Vanguard", @"World"];
    
    CGFloat dX = 0;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height +
    self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = 40;
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Filter", @"Sorter", @"Current Search"]];
    self.segmentedControl.frame = CGRectMake(dX, dY, dWidth, dHeight);
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    
    dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height;
    dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.tblView];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(btnSaveTapped:)];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(btnCancelTapped:)];
    self.navigationItem.rightBarButtonItem = btnSave;
    self.navigationItem.leftBarButtonItem = btnCancel;

    self.navigationItem.title = @"New Advance Search";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnSaveTapped:(id) sender
{
    
}

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) segmentedControlChangedValue:(id) sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            [self.tblView setEditing:YES];
            break;
        }
        default:
        {
            [self.tblView setEditing:NO];
            break;
        }
    }
    [self.tblView reloadData];
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if (![sections containsObject:[dict objectForKey:@"Filter"]])
                {
                    [sections addObject:[dict objectForKey:@"Filter"]];
                }
            }
            NSString *sectionName = [sections objectAtIndex:indexPath.section];
            NSString *stringValue;
            NSDictionary *dead;
            
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if ([[dict objectForKey:@"Filter"] isEqualToString:sectionName])
                {
                    id value = [dict objectForKey:@"Value"];
                    
                    if ([value isKindOfClass:[NSManagedObject class]])
                    {
                        stringValue = [value performSelector:@selector(name) withObject:nil];
                    }
                    else if ([value isKindOfClass:[NSString class]])
                    {
                        stringValue = value;
                    }
                    
                    dead = dict;
                    break;
                }
            }

            if (dead)
            {
                [self.arrCurrentQuery removeObject:dead];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            return YES;
        }
        default:
        {
            return NO;
        }
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            return UITableViewCellEditingStyleDelete;
        }
        default:
        {
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if (![sections containsObject:[dict objectForKey:@"Filter"]])
                {
                    [sections addObject:[dict objectForKey:@"Filter"]];
                }
            }
            return [sections objectAtIndex:section];
        }
        default:
        {
            return nil;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if (![sections containsObject:[dict objectForKey:@"Filter"]])
                {
                    [sections addObject:[dict objectForKey:@"Filter"]];
                }
            }
            return sections.count;
        }
        default:
        {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            return _arrFilters.count;
        }
        case 1:
        {
            return _arrSorters.count;
        }
        case 2:
        {
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            int rows = 0;
            
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if (![sections containsObject:[dict objectForKey:@"Filter"]])
                {
                    [sections addObject:[dict objectForKey:@"Filter"]];
                }
            }
            NSString *sectionName = [sections objectAtIndex:section];
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if ([[dict objectForKey:@"Filter"] isEqualToString:sectionName])
                {
                    rows++;
                }
            }
            return rows;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            cell.textLabel.text = [_arrFilters objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:
        {
            cell.textLabel.text = [_arrSorters objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if (![sections containsObject:[dict objectForKey:@"Filter"]])
                {
                    [sections addObject:[dict objectForKey:@"Filter"]];
                }
            }
            NSString *sectionName = [sections objectAtIndex:indexPath.section];
            for (NSDictionary *dict in self.arrCurrentQuery)
            {
                if ([[dict objectForKey:@"Filter"] isEqualToString:sectionName])
                {
                    NSString *stringValue;
                    id value = [dict objectForKey:@"Value"];
                    
                    if ([value isKindOfClass:[NSManagedObject class]])
                    {
                        stringValue = [value performSelector:@selector(name) withObject:nil];
                    }
                    else if ([value isKindOfClass:[NSString class]])
                    {
                        stringValue = value;
                    }
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ contains '%@'", [dict objectForKey:@"Condition"], sectionName, stringValue];
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FilterInputViewController *inputView = [[FilterInputViewController alloc] init];
    NSArray *arrFilterOptions;
    
    switch (indexPath.row)
    {
        case 1:
        {
            arrFilterOptions = [Set MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        case 2:
        {
            arrFilterOptions = [CardRarity MR_findAll];
            break;
        }
        case 3:
        {
            arrFilterOptions = [Format MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        case 4:
        {
            arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name IN %@", _cardTypes]];
            break;
        }
        case 5:
        {
            arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"NOT (name IN %@)", _cardTypes]];
            break;
        }
        case 6:
        {
            arrFilterOptions = kManaColors;
            break;
        }
        case 9:
        {
            arrFilterOptions = [Artist MR_findAllSortedBy:@"name" ascending:YES];
            break;
        }
        default:
        {
            arrFilterOptions = @[@"High"];
            break;
        }
    }
    
    inputView.delegate = self;
    inputView.filterOptions = arrFilterOptions;
    inputView.navigationItem.title = [_arrFilters objectAtIndex:indexPath.row];
    inputView.filterName = [_arrFilters objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:inputView animated:YES];
}

#pragma mark - FilterInputViewControllerDelegate
-(void) addFilter:(NSDictionary*) filter
{
    [self.arrCurrentQuery addObject:filter];
    self.segmentedControl.selectedSegmentIndex = 2;
    [self.tblView setEditing:YES];
    [self.tblView reloadData];
}

@end
