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
    id _selectedFilter;
    NSString *_selectedOperator;
}

@synthesize filterName = _filterName;
@synthesize filterOptions = _filterOptions;
@synthesize operatorOptions = _operatorOptions;
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
    _selectedFilter = [self.filterOptions firstObject];
    _selectedOperator = [self.operatorOptions firstObject];

    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblFilter = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight*0.70)
                                                  style:UITableViewStylePlain];
    self.tblFilter.dataSource = self;
    self.tblFilter.delegate = self;
    
    dY = self.tblFilter.frame.origin.y + self.tblFilter.frame.size.height;
    self.tblOperator = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight*0.30)
                                                    style:UITableViewStylePlain];
    self.tblOperator.dataSource = self;
    self.tblOperator.delegate = self;
    
    [self.view addSubview:self.tblFilter];
    [self.view addSubview:self.tblOperator];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblFilter)
    {
        return self.filterOptions.count;
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
        if (!self.filterOptions)
        {
            // for text input here
        }
        else
        {
            if ([[self.filterOptions firstObject] isKindOfClass:[Set class]])
            {
                Set *set = [self.filterOptions objectAtIndex:indexPath.row];
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
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardRarity class]])
            {
                CardRarity *rarity = [self.filterOptions objectAtIndex:indexPath.row];
                cell.textLabel.text = rarity.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[Format class]])
            {
                Format *format = [self.filterOptions objectAtIndex:indexPath.row];
                cell.textLabel.text = format.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardType class]])
            {
                CardType *type = [self.filterOptions objectAtIndex:indexPath.row];
                cell.textLabel.text = type.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[Artist class]])
            {
                Artist *artist = [self.filterOptions objectAtIndex:indexPath.row];
                cell.textLabel.text = artist.name;
            }
            else if ([[self.filterOptions firstObject] isKindOfClass:[CardColor class]])
            {
                CardColor *color = [self.filterOptions objectAtIndex:indexPath.row];
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
        }
        
        cell.accessoryType = indexPath.row == _selectedFilterIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
        _selectedFilterIndex = (int)indexPath.row;
        _selectedFilter = [self.filterOptions objectAtIndex:indexPath.row];
    }
    else if (tableView == self.tblOperator)
    {
        _selectedOperatorIndex = (int)indexPath.row;
        _selectedOperator = [self.operatorOptions objectAtIndex:indexPath.row];
    }
    
    [tableView reloadData];
}

@end
