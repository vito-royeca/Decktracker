//
//  BoxFolderPickerViewController.m
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#define kCellHeight 58.0

#import <BoxSDK/BoxFolderPickerTableViewController.h>
#import <BoxSDK/BoxSDK.h>
#import <BoxSDK/BoxOAuth2Session.h>
#import <BoxSDK/BoxFolderPickerCell.h>


@implementation BoxFolderPickerTableViewController

@synthesize folderPicker = _folderPicker;
@synthesize delegate = _delegate;
@synthesize helper = _helper;

- (id)initWithFolderPickerHelper:(BoxFolderPickerHelper *)helper
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self != nil)
    {
        _helper = helper;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UI Setup
    self.tableView.alpha = 0.0;
    self.tableView.rowHeight = kCellHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.helper cancelThumbnailOperations];
    [super viewWillDisappear:animated];
}

#pragma mark - Data Management

- (void)refreshData
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.alpha = 1.0;
    }];
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSUInteger count = [self.delegate currentNumberOfItems];
    NSUInteger total = [self.delegate totalNumberOfItems];
    
    // +1 for the "load more" cell at the bottom.
    return (count < total) ? count + 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BoxCell";
    static NSString *FooterIdentifier = @"BoxFooterCell";
    
    BoxFolderPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[BoxFolderPickerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.helper = self.helper;
    
    if (indexPath.row < [self.delegate currentNumberOfItems])
    {
        
        BoxItem *item = [self.delegate itemAtIndex:indexPath.row];
        
        if (![self.delegate fileSelectionEnabled] && ![item isKindOfClass:[BoxFolder class]]) {
            cell.enabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.enabled = YES;
        }
        
        cell.cachePath = [self.delegate thumbnailPath];
        cell.showThumbnails = [self.delegate thumbnailsEnabled];
        cell.item = item;        
    }
    else 
    {
        UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:FooterIdentifier];
        if (!footerCell) {
            footerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FooterIdentifier];
            footerCell.textLabel.textColor = [UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0];
        }
        footerCell.textLabel.text =  NSLocalizedString(@"Load more files ...", @"Title : Cell allowing the user to load the next page of items");
        footerCell.imageView.image = nil;
        footerCell.detailTextLabel.text = nil;
        
        return footerCell;
    }
    
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.delegate currentNumberOfItems])
    {
        BoxItem *item = (BoxItem *)[self.delegate itemAtIndex:indexPath.row];
        
        if ([item isKindOfClass:[BoxFolder class]])
        {
            BoxFolderPickerViewController *childFolderPicker = [[BoxFolderPickerViewController alloc] initWithSDK:[self.delegate currentSDK]
                                                                                                     rootFolderID:item.modelID thumbnailsEnabled:[self.delegate thumbnailsEnabled] 
                                                                                             cachedThumbnailsPath:[self.delegate thumbnailPath] fileSelectionEnabled:[self.delegate fileSelectionEnabled]];
            childFolderPicker.delegate = self.folderPicker.delegate;
            [self.navigationController pushViewController:childFolderPicker animated:YES];
        }
        else if ([item isKindOfClass:[BoxFile class]])
        {
            if ([self.delegate fileSelectionEnabled]) {
                [self.helper purgeInMemoryCache];
                [self.folderPicker.delegate folderPickerController:self.folderPicker didSelectBoxItem:item];
            }
        }
    }
    else 
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];
        [self.delegate loadNextSetOfItems];
    }
}

@end
