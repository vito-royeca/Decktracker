//
//  SearchInputViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FilterInputViewController.h"
#import "Artist.h"
#import "CardColor.h"
#import "CardRarity.h"
#import "CardType.h"
#import "Format.h"
#import "Magic.h"
#import "Set.h"

@implementation FilterInputViewController
{
    int _selectedFilterIndex;
    int _selectedOperatorIndex;
    NSString *_selectedFilter;
    NSString *_selectedOperator;
    NSArray  *_narrowedFilterOptions;
}

@synthesize filterName = _filterName;
@synthesize filterOptions = _filterOptions;
@synthesize operatorOptions = _operatorOptions;
@synthesize searchBar = _searchBar;
@synthesize tblFilter = _tblFilter;
@synthesize tblOperator = _tblOperator;

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
    _selectedFilterIndex = 0;
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
    
    dY = self.tblOperator.frame.origin.y + self.tblOperator.frame.size.height;
    self.tblFilter = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight*0.60)
                                                  style:UITableViewStylePlain];
    self.tblFilter.dataSource = self;
    self.tblFilter.delegate = self;
    
    [self.view addSubview:self.tblOperator];
    [self.view addSubview:self.tblFilter];
    self.navigationItem.title = self.filterName;
    
    if (self.filterOptions)
    {
        id obj = [self.filterOptions firstObject];
        NSString *stringValue;
        if (obj)
        {
            if ([obj isKindOfClass:[NSManagedObject class]])
            {
                stringValue = [obj performSelector:@selector(name) withObject:nil];
            }
            else if ([obj isKindOfClass:[NSString class]])
            {
                stringValue = obj;
            }
        }
        _selectedFilter = stringValue;
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"Filter";
        self.searchBar.tintColor = [UIColor grayColor];
    }
    else
    {
        self.tblFilter.separatorColor = [UIColor clearColor];
    }
    
    UIBarButtonItem *btnOk = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(btnOkTapped:)];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(btnCancelTapped:)];
    self.navigationItem.rightBarButtonItem = btnOk;
    self.navigationItem.leftBarButtonItem = btnCancel;
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

- (void) searchFilterOptions
{
    NSString *query = self.searchBar.text;
    NSPredicate *predicate;
    _selectedFilterIndex = -1;
    
    if (query.length == 1)
    {
        predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", query];
        _narrowedFilterOptions = [self.filterOptions filteredArrayUsingPredicate:predicate];
    }
    else if (query.length > 1)
    {
        predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", query];
        _narrowedFilterOptions = [self.filterOptions filteredArrayUsingPredicate:predicate];
    }
    else
    {
        _narrowedFilterOptions = nil;
    }
    
    [self.tblFilter reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (tableView == self.tblFilter)
    {
        return @"Filter";
    }
    else if (tableView == self.tblOperator)
    {
        return @"Condition";
    }
    else
    {
        return @"";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        return self.searchBar;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        return 30;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        if (self.filterOptions)
        {
            NSArray *arrFilter = _narrowedFilterOptions ? _narrowedFilterOptions : self.filterOptions;
        
            return arrFilter.count;
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
            
            if ([[arrFilter firstObject] isKindOfClass:[Set class]])
            {
                Set *set = [arrFilter objectAtIndex:indexPath.row];
                NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/C/24.png", [[NSBundle mainBundle] bundlePath], set.code];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    cell.imageView.image = [UIImage imageNamed:@"blank-24.png"];
                }
                else
                {
                    cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
                }
                cell.textLabel.text = set.name;
            }
            else if ([[arrFilter firstObject] isKindOfClass:[CardRarity class]])
            {
                CardRarity *rarity = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = rarity.name;
            }
            else if ([[arrFilter firstObject] isKindOfClass:[Format class]])
            {
                Format *format = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = format.name;
            }
            else if ([[arrFilter firstObject] isKindOfClass:[CardType class]])
            {
                CardType *type = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = type.name;
            }
            else if ([[arrFilter firstObject] isKindOfClass:[Artist class]])
            {
                Artist *artist = [arrFilter objectAtIndex:indexPath.row];
                cell.textLabel.text = artist.name;
            }
            else if ([[arrFilter firstObject] isKindOfClass:[CardColor class]])
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
                    cell.imageView.image = [UIImage imageNamed:@"blank-24.png"];
                }
                else
                {
                    cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
                }
                
                cell.textLabel.text = color.name;
            }
            
            cell.accessoryType = indexPath.row == _selectedFilterIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
        id obj = [arrFilter objectAtIndex:indexPath.row];
        NSString *stringValue;
        
        if ([obj isKindOfClass:[NSManagedObject class]])
        {
            stringValue = [obj performSelector:@selector(name) withObject:nil];
        }
        else if ([obj isKindOfClass:[NSString class]])
        {
            stringValue = obj;
        }
        
        _selectedFilterIndex = (int)indexPath.row;
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
