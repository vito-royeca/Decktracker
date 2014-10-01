//
//  CollectionsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CollectionsViewController.h"
#import "CollectionDetailsViewController.h"
#import "FileManager.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation CollectionsViewController
{
    NSInteger _selectedRow;
}

@synthesize tblCollections = _tblCollections;
@synthesize arrCollections = _arrCollections;


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
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblCollections = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                       style:UITableViewStylePlain];
    self.tblCollections.delegate = self;
    self.tblCollections.dataSource = self;
    
    [self.view addSubview:self.tblCollections];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(btnAddTapped:)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    self.navigationItem.title = @"Collections";
    
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Collections"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewDidAppear:(BOOL)animated
{
    self.arrCollections = [[NSMutableArray alloc] init];
    for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Collections"
                                                       fromFileSystem:FileSystemLocal])
    {
        [self.arrCollections addObject:[file stringByDeletingPathExtension]];
    }
    
    [self.tblCollections reloadData];
}

-(void) btnAddTapped:(id) sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save"
                                                     message:@"New Collection Name"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 0;
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == 0)
        {
            NSDictionary *dict = @{@"name" : [[alertView textFieldAtIndex:0] text],
                                   @"regular" : @[],
                                   @"foiled" : @[]};
            [[FileManager sharedInstance] saveData:dict atPath:[NSString stringWithFormat:@"/Collections/%@.json", dict[@"name"]]];
            
            // send to Google Analytics
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Collections"
                                                                  action:nil
                                                                   label:@"New Collection"
                                                                   value:nil] build]];
            
            CollectionDetailsViewController *view = [[CollectionDetailsViewController alloc] init];
            NSDictionary *deck = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Collections/%@.json", dict[@"name"]]];
            view.dictCollection = deck;
            [self.navigationController pushViewController:view animated:YES];
            [self.tblCollections reloadData];
        }
        
        else if (alertView.tag == 1)
        {
            NSString *name = self.arrCollections[_selectedRow];
            NSString *path = [NSString stringWithFormat:@"/Collections/%@.json", name];
            [[FileManager sharedInstance] deleteFileAtPath:path];
            [self.arrCollections removeObject:name];
            
            // send to Google Analytics
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Collections"
                                                                  action:nil
                                                                   label:@"Delete"
                                                                   value:nil] build]];
            [self.tblCollections reloadData];
        }
    }
}

#pragma - mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.arrCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.arrCollections.count > 0)
    {
        NSDictionary *deck = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Collections/%@.json", self.arrCollections[indexPath.row]]];
        
        cell.textLabel.text = deck[@"name"];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    CollectionDetailsViewController *view = [[CollectionDetailsViewController alloc] init];
    
    NSDictionary *deck = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Collections/%@.json", self.arrCollections[_selectedRow]]];
    
    view.dictCollection = deck;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Collection"
                                                        message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", self.arrCollections[indexPath.row]]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }
}

@end
