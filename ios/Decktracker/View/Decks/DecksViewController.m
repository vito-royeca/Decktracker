//
//  DecksViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/23/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DecksViewController.h"
#import "DeckDetailsViewController.h"
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
    [self loadDecks];
    
#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Decks"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

-(void) loadDecks
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tblDecks];
    hud.delegate = self;
    [self.view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        self.arrDecks = [[NSMutableArray alloc] init];
        for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Decks"
                                                              fromFileSystem:FileSystemLocal])
        {
            NSDictionary *dict = [[FileManager sharedInstance] loadFileAtPath:[NSString stringWithFormat:@"/Decks/%@", file]];
            
            Deck *deck = [[Deck alloc] initWithDictionary:dict];
            
            [self.arrDecks addObject:deck];
        }
    } completionBlock:^ {
        [self.tblDecks reloadData];
    }];
}

-(void) deleteDeck
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tblDecks];
    hud.delegate = self;
    [self.view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        Deck *deck = self.arrDecks[_selectedRow];
        
        [self.arrDecks removeObject:deck];
        [[FileManager sharedInstance] deleteFileAtPath:[NSString stringWithFormat:@"/Decks/%@.json", deck.name]];
        [deck deletePieImage];
        
#ifndef DEBUG
        // send to Google Analytics
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Decks"
                                                              action:nil
                                                               label:@"Delete"
                                                               value:nil] build]];
#endif
    } completionBlock:^ {
        [self.tblDecks reloadData];
    }];
}

-(void) updateDeck:(Deck*) deck
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.tblDecks];
    hud.delegate = self;
    [self.view addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        Deck *oldDeck = self.arrDecks[_selectedRow];
        [self.arrDecks removeObject:oldDeck];
        [self.arrDecks insertObject:deck atIndex:_selectedRow];
    } completionBlock:^ {
        [self.tblDecks reloadData];
    }];
}

-(void) btnAddTapped:(id) sender
{
    void (^handler)(UIAlertController*) = ^void(UIAlertController *alert) {
        
        NSDictionary *dict = @{@"name" : [((UITextField*)[[alert textFields] firstObject]) text],
                               @"mainBoard" : @[],
                               @"sideBoard" : @[]};
        Deck *deck = [[Deck alloc] initWithDictionary:dict];
        [deck save:[NSString stringWithFormat:@"/Decks/%@.json", dict[@"name"]]];
        [self.arrDecks addObject:deck];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
        NSArray *arrSorted = [self.arrDecks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        self.arrDecks = [[NSMutableArray alloc] initWithArray:arrSorted];
        _selectedRow = [self.arrDecks indexOfObject:deck];
        
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
    };
    
    void (^textFieldHandler)(UITextField*) = ^void(UITextField *textField) {
        textField.text = @"New Deck Name";
    };
    
    [JJJUtil alertWithTitle:@"Create New Deck"
                    message:nil
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@{@"Ok": handler}
          textFieldHandlers:@[textFieldHandler]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.navigationController pushViewController:view animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Deck *deck = self.arrDecks[_selectedRow];
        
        void (^handler)(UIAlertController*) = ^void(UIAlertController *alert) {
            
            [self deleteDeck];
        };
        
        [JJJUtil alertWithTitle:@"Delete Deck"
                        message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", deck.name]
              cancelButtonTitle:@"No"
              otherButtonTitles:@{@"Yes": handler}
              textFieldHandlers:nil];
    }
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
