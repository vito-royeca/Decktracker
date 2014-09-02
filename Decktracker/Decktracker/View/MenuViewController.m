//
//  MenuViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/13/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController
{
    NSArray *_menuItems;
}

@synthesize tblMenu = _tblMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _menuItems = @[@"Simple Search",
                       @"Advance Search",
                       @"Decks",
                       @"Collections",
                       @"Settings"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tblMenu = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tblMenu setDelegate:self];
    [self.tblMenu setDataSource:self];
    [self.tblMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO  scrollPosition:UITableViewScrollPositionTop];
    [self.view addSubview:self.tblMenu];
    [self.tblMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = _menuItems[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row)
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            break;
        }
    }
    
    
}

@end
