//
//  SearchInputViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FilterInputViewController.h"
#import "JJJ/JJJUtil.h"
#import "Artist.h"
#import "CardColor.h"
#import "CardRarity.h"
#import "CardType.h"
#import "Format.h"
#import "Magic.h"
#import "Set.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation FilterInputViewController
{
    NSIndexPath *_selectedFilterPath;
    int _selectedOperatorIndex;
    NSString *_selectedFilter;
    NSString *_selectedOperator;
    NSArray  *_narrowedFilterOptions;
}

@synthesize filterName = _filterName;
@synthesize filterOptions = _filterOptions;
@synthesize operatorOptions = _operatorOptions;
@synthesize searchBar = _searchBar;
@synthesize tblOperator = _tblOperator;
@synthesize tblFilter = _tblFilter;

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
    
    self.operatorOptions = @[@"And", @"Or", @"Not"];
    _selectedFilterPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _selectedOperatorIndex = 0;
    _selectedOperator = [self.operatorOptions firstObject];
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    self.tblOperator = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight*0.40)
                                                    style:UITableViewStylePlain];
    self.tblOperator.dataSource = self;
    self.tblOperator.delegate = self;
    [self.view addSubview:self.tblOperator];
    
    if (self.filterOptions)
    {
        id obj = [self.filterOptions firstObject];
        NSString *stringValue;
        
        if ([obj isKindOfClass:[NSManagedObject class]])
        {
            stringValue = [obj performSelector:@selector(name) withObject:nil];
        }
        else if ([obj isKindOfClass:[NSString class]])
        {
            stringValue = obj;
        }
        else if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dict = (NSDictionary*) obj;
            NSArray *arrValues = [dict objectForKey:[[dict allKeys] firstObject]];
            stringValue = [arrValues firstObject];
        }
        _selectedFilter = stringValue;
        
        dY = self.tblOperator.frame.origin.y + self.tblOperator.frame.size.height;
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, 30)];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"Filter";
        self.searchBar.tintColor = [UIColor grayColor];
        
        dY = self.searchBar.frame.origin.y + self.searchBar.frame.size.height;
        self.tblFilter = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, (dHeight-self.searchBar.frame.size.height)*0.60)
                                                      style:UITableViewStylePlain];
        self.tblFilter.dataSource = self;
        self.tblFilter.delegate = self;
        
        [self.view addSubview:self.searchBar];
        [self.view addSubview:self.tblFilter];
    }
    else
    {
        dY = self.tblOperator.frame.origin.y + self.tblOperator.frame.size.height;
        self.tblFilter = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight*0.60)
                                                      style:UITableViewStylePlain];
        self.tblFilter.dataSource = self;
        self.tblFilter.delegate = self;
        self.tblFilter.separatorColor = [UIColor clearColor];
        [self.view addSubview:self.tblFilter];
    }
    
    UIBarButtonItem *btnOk = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(btnOkTapped:)];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(btnCancelTapped:)];
    self.navigationItem.rightBarButtonItem = btnOk;
    self.navigationItem.leftBarButtonItem = btnCancel;
    self.navigationItem.title = self.filterName;
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:[NSString stringWithFormat:@"Filter Input - %@", self.filterName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnOkTapped:(id) sender
{
    NSDictionary *dict = @{@"Filter": self.filterName,
                           @"Value": _selectedFilter,
                           @"Condition": _selectedOperator};
    
    [self.delegate addFilter:dict];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchFilterOptions];
    
    if ([self.searchBar canResignFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    _selectedFilterPath = nil;
    _narrowedFilterOptions = nil;
    [self.tblFilter reloadData];
}

- (void) searchFilterOptions
{
    NSString *query = self.searchBar.text;
    NSPredicate *predicate;
    NSMutableArray *arrFilter;
    
    id obj = [self.filterOptions firstObject];
    if ([obj isKindOfClass:[NSManagedObject class]])
    {
        arrFilter = [[NSMutableArray alloc] initWithArray:self.filterOptions];
        
        if (query.length == 1)
        {
            predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", query];
        }
        else if (query.length > 1)
        {
            predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", query];
        }
    }
    else if ([obj isKindOfClass:[NSDictionary class]])
    {
        arrFilter = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in self.filterOptions)
        {
            NSArray *keywords = [dict objectForKey:[[dict allKeys] firstObject]];
            [arrFilter addObjectsFromArray:keywords];
        }
        
        if (query.length == 1)
        {
            predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", query];
        }
        else if (query.length > 1)
        {
            predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query];
        }
    }
    
    if (predicate)
    {
        _narrowedFilterOptions = [arrFilter filteredArrayUsingPredicate:predicate];
        if ([[_narrowedFilterOptions firstObject] isKindOfClass:[NSManagedObject class]])
        {
            _selectedFilter = [[_narrowedFilterOptions firstObject] performSelector:@selector(name) withObject:nil]
            ;
        }
        else if ([[_narrowedFilterOptions firstObject] isKindOfClass:[NSString class]])
        {
            _selectedFilter = [_narrowedFilterOptions firstObject];
        }
    }
    else
    {
        _narrowedFilterOptions = nil;
    }
    
    _selectedFilterPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tblFilter reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sections = 1;
    
    if (tableView == self.tblFilter)
    {
        if (self.filterOptions)
        {
            NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
            
            if ([[arrFilter firstObject] isKindOfClass:[NSDictionary class]])
            {
                sections = (int)arrFilter.count;
            }
        }
    }
    
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        if (self.filterOptions)
        {
            NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
            
            if ([[arrFilter firstObject] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = [arrFilter objectAtIndex:section];
                return [[dict allKeys] firstObject];
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return nil;
        }
    }
    else if (tableView == self.tblOperator)
    {
        return @"Condition";
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        if (self.filterOptions)
        {
            NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
        
            if ([[arrFilter firstObject] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = [arrFilter objectAtIndex:section];
                NSArray *arrValues = [dict objectForKey:[[dict allKeys] firstObject]];
                return arrValues.count;
            }
            else
            {
                return arrFilter.count;
            }
        }
        else
        {
            return 1;
        }
    }
    else if (tableView == self.tblOperator)
    {
        return self.operatorOptions.count;
    }
    else
    {
        return 1;
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
    
    if (tableView == self.tblFilter)
    {
        if (self.filterOptions)
        {
            NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
            
            if ([[self.filterOptions firstObject] isKindOfClass:[Set class]])
            {
                Set *set = [arrFilter objectAtIndex:indexPath.row];
                NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/C/24.png", [[NSBundle mainBundle] bundlePath], set.code];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    cell.imageView.image = [UIImage imageNamed:@"blank.png"];
                }
                else
                {
                    cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
                }
                cell.textLabel.text = set.name;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Released: %@ (%@ cards)", [JJJUtil formatDate:set.releaseDate withFormat:@"YYYY-MM-dd"], set.numberOfCards];
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardRarity class]])
            {
                CardRarity *rarity = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = rarity.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardType class]])
            {
                CardType *type = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = type.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardColor class]])
            {
                CardColor *color = [arrFilter objectAtIndex:indexPath.row];
                NSString *colorInitial;
                if ([color.name isEqualToString:@"Blue"])
                {
                    colorInitial = @"U";
                }
                else if ([color.name isEqualToString:@"Colorless"])
                {
                    colorInitial = @"1";
                }
                else
                {
                    colorInitial = [color.name substringToIndex:1];
                }
                
                NSString *path = [NSString stringWithFormat:@"%@/images/mana/%@/24.png", [[NSBundle mainBundle] bundlePath], colorInitial];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    cell.imageView.image = [UIImage imageNamed:@"blank.png"];
                }
                else
                {
                    cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
                }
                
                cell.textLabel.text = color.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[NSDictionary class]])
            {
                if (_narrowedFilterOptions)
                {
                    cell.textLabel.text = [_narrowedFilterOptions objectAtIndex:indexPath.row];
                }
                else
                {
                    NSDictionary *dict = [arrFilter objectAtIndex:indexPath.section];
                    NSArray *arrValues = [dict objectForKey:[[dict allKeys] firstObject]];
                    cell.textLabel.text = [arrValues objectAtIndex:indexPath.row];
                }
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[Artist class]])
            {
                Artist *artist = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = artist.name;
            }
            if (_selectedFilterPath && [_selectedFilterPath compare:indexPath] == NSOrderedSame)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
            txtField.adjustsFontSizeToFitWidth = YES;
            txtField.borderStyle = UITextBorderStyleRoundedRect;
            txtField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            txtField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            txtField.placeholder = [NSString stringWithFormat:@"Type %@ here", self.filterName];
            txtField.delegate = self;
            txtField.clearButtonMode = UITextFieldViewModeAlways;
            txtField.tag = 1;
            [txtField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:txtField];
        }
    }
    else if (tableView == self.tblOperator)
    {
        cell.textLabel.text = [self.operatorOptions objectAtIndex:indexPath.row];
        cell.accessoryType = indexPath.row == _selectedOperatorIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblFilter)
    {
        NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
        NSString *stringValue;

        if ([[self.filterOptions firstObject] isKindOfClass:[NSManagedObject class]])
        {
            id obj = [arrFilter objectAtIndex:indexPath.row];
            stringValue = [obj performSelector:@selector(name) withObject:nil];
        }
        else if ([[self.filterOptions firstObject] isKindOfClass:[NSString class]])
        {
            stringValue = [arrFilter objectAtIndex:indexPath.row];
        }
        else if ([[self.filterOptions firstObject] isKindOfClass:[NSDictionary class]])
        {
            if (_narrowedFilterOptions)
            {
                stringValue = [_narrowedFilterOptions objectAtIndex:indexPath.row];
            }
            else
            {
                NSDictionary *dict = [arrFilter objectAtIndex:indexPath.section];
                NSArray *arrValues = [dict objectForKey:[[dict allKeys] firstObject]];
                stringValue = [arrValues objectAtIndex:indexPath.row];
            }
        }
        
        _selectedFilterPath = indexPath;
        _selectedFilter = stringValue;
    }
    else if (tableView == self.tblOperator)
    {
        _selectedOperatorIndex = (int)indexPath.row;
        _selectedOperator = [self.operatorOptions objectAtIndex:indexPath.row];
    }
    
    if ([self.searchBar canResignFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
    
    [tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _selectedFilter = textField.text;
    
    if ([textField canBecomeFirstResponder])
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void) textFieldDidChange:(id) sender
{
    UITextField *textField = sender;
    
    _selectedFilter = textField.text;
}

@end
