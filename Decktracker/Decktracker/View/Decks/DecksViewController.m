//
//  DecksViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DecksViewController.h"
#import "DeckDetailsViewController.h"
#import "Deck.h"
#import "Decktracker-Swift.h"
#import "FileManager.h"


#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation DecksViewController
{
    NSInteger _selectedRow;
}

@synthesize tblDecks = _tblDecks;
@synthesize arrDecks = _arrDecks;

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
    
    _selectedRow = 0;

    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblDecks = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                   style:UITableViewStylePlain];
    self.tblDecks.delegate = self;
    self.tblDecks.dataSource = self;
    [self.tblDecks registerNib:[UINib nibWithNibName:@"DecksTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell"];
    
    [self.view addSubview:self.tblDecks];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(btnAddTapped:)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    self.navigationItem.title = @"Decks";
    
#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Decks"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tblDecks];
    [self.tblDecks addSubview:hud];
    hud.delegate = self;

    [hud showAnimated:YES whileExecutingBlock:^{
      [self loadDecks];
    } completionBlock:^ {
          [self.tblDecks reloadData];
    }];
}

-(void) loadDecks
{
    self.arrDecks = [[NSMutableArray alloc] init];
    for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Decks"
                                                          fromFileSystem:FileSystemLocal])
    {
        NSDictionary *dict = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Decks/%@", file]];
        
        Deck *deck = [[Deck alloc] initWithDictionary:dict];
        
        [self.arrDecks addObject:deck];
    }
}

-(void) deleteDeck
{
    Deck *deck = self.arrDecks[_selectedRow];
    NSString *path = [NSString stringWithFormat:@"/Decks/%@.json", deck.name];
    
    [[FileManager sharedInstance] deleteFileAtPath:path];
    [deck deletePieImage];

    [self.arrDecks removeObject:deck.name];
    [self loadDecks];
    
#ifndef DEBUG
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Decks"
                                                          action:nil
                                                           label:@"Delete"
                                                           value:nil] build]];
#endif
}

-(void) btnAddTapped:(id) sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Create New Deck"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = @"New Deck Name";
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
                                   @"mainBoard" : @[],
                                   @"sideBoard" : @[]};
            Deck *deck = [[Deck alloc] initWithDictionary:dict];
            [deck save:[NSString stringWithFormat:@"/Decks/%@.json", dict[@"name"]]];
            
            DeckDetailsViewController *view = [[DeckDetailsViewController alloc] init];
            view.deck = deck;
            
#ifndef DEBUG
            // send to Google Analytics
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Decks"
                                                                  action:nil
                                                                   label:@"New Deck"
                                                                   value:nil] build]];
#endif
            [self.navigationController pushViewController:view animated:YES];
        }
        
        else if (alertView.tag == 1)
        {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tblDecks];
            [self.tblDecks addSubview:hud];
            hud.delegate = self;
            
            [hud showAnimated:YES whileExecutingBlock:^{
                [self loadDecks];
            } completionBlock:^ {
                [self.tblDecks reloadData];
            }];
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
	return self.arrDecks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    DecksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[DecksTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
 
    if (self.arrDecks.count > 0)
    {
        Deck *deck = self.arrDecks[indexPath.row];
        
        [cell displayDeck: deck];
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
    
    DeckDetailsViewController *view = [[DeckDetailsViewController alloc] init];
    Deck *deck = self.arrDecks[_selectedRow];
    
    view.deck = deck;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Deck *deck = self.arrDecks[indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Deck"
                                                        message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", deck.name]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
