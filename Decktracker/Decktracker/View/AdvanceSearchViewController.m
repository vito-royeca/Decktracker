//
//  SearchViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "AdvanceSearchViewController.h"
#import "Artist.h"
#import "CardRarity.h"
#import "CardType.h"
#import "FilterInputViewController.h"
#import "Format.h"
#import "Set.h"

@implementation AdvanceSearchViewController
{
    NSMutableArray *_currentQuery;
    NSArray *_arrFilters;
    NSArray *_cardTypes;
}

@synthesize segmentedControl = _segmentedControl;
@synthesize tblView = _tblView;

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
    
    _arrFilters = @[@"Name", @"Sets", @"Rarities", @"Formats", @"Types", @"Subtypes", @"Colors", @"Text", @"Flavor Text",
                    @"Artist"];
    _cardTypes = @[@"Artifact", @"Basic", @"Conspiracy", @"Creature", @"Enchantment", @"Instant", @"Land",
                   @"Legendary", @"Ongoing", @"Phenomenon", @"Plane", @"Planeswalker", @"Scheme", @"Snow",
                   @"Sorcery", @"Tribal", @"Vanguard", @"World"];
    
    CGFloat dX = 0;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height +
        self.navigationController.navigationBar.frame.size.height;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = 40;
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Filter", @"Sorter", @"Current Query", @"Saved Queries"]];
    self.segmentedControl.frame = CGRectMake(dX, dY, dWidth, dHeight);
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChangedValue:)
                    forControlEvents:UIControlEventValueChanged];
    
    
    dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height;
    dHeight = self.view.frame.size.height - dY;
    self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.tblView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) segmentedControlChangedValue:(id) sender
{
    [self.tblView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            return _arrFilters.count;
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            cell.textLabel.text = [_arrFilters objectAtIndex:indexPath.row];
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
//            arrFilterOptions = [CardType MR_findAllSortedBy:@"name" ascending:YES];
//            arrFilterOptions = [arrFilterOptions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (name IN %@)", _cardTypes]];
            break;
        }
        case 6:
        {
            arrFilterOptions = @[@"Black", @"Blue", @"Green", @"Red", @"White", @"Colorless"];
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
    
    inputView.filterOptions = arrFilterOptions;
    inputView.navigationItem.title = [_arrFilters objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:inputView animated:YES];
}


@end
