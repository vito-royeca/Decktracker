//
//  CardDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CardDetailsViewController.h"

#import "AddCardViewController.h"
#import "AdvanceSearchResultsViewController.h"
#import "DTArtist.h"
#import "DTCardForeignName.h"
#import "DTCardLegality.h"
#import "DTCardRarity.h"
#import "DTCardRuling.h"
#import "DTCardType.h"
#import "DTFormat.h"
#import "DTSet.h"
#import "Database.h"
#import "FileManager.h"
#import "Magic.h"
#import "SearchResultsTableViewCell.h"
#import "SimpleSearchViewController.h"


#import "EDStarRating.h"
#import "LMAlertView.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation CardDetailsViewController
{
    DTCardType *_planeswalkerType;
    MHFacebookImageViewer *_fbImageViewer;
    UIView *_viewSegmented;
    DTSet *_mediaInsertsSet;
    float _newRating;
}

@synthesize card = _card;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize segmentedControl = _segmentedControl;
@synthesize cardImage = cardImage;
@synthesize tblDetails = _tblDetails;
@synthesize webView = _webView;
@synthesize bottomToolbar = _bottomToolbar;
@synthesize btnPrevious = _btnPrevious;
@synthesize btnNext = _btnNext;
@synthesize btnAction = _btnAction;
@synthesize btnRate = _btnRate;
@synthesize btnAdd = _btnAdd;
@synthesize addButtonVisible = _addButtonVisible;

-(void) setCard:(DTCard *)card
{
    _card = card;

    [[FileManager sharedInstance] downloadCardImage:_card immediately:YES];
    [[FileManager sharedInstance] downloadCropImage:_card immediately:YES];
    
    if (self.fetchedResultsController)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSInteger index = [sectionInfo.objects indexOfObject:self.card];
        self.navigationItem.title = [NSString stringWithFormat:@"%tu of %tu", index+1, sectionInfo.objects.count];

        // download next four card images
        for (int i = 0; i < 5; i++)
        {
            if (index+i <= sectionInfo.objects.count-1)
            {
                DTCard *kard = sectionInfo.objects[index+i];
                
                [[FileManager sharedInstance] downloadCardImage:kard immediately:NO];
                [[FileManager sharedInstance] downloadCropImage:kard immediately:NO];
            }
        }
    }
    else
    {
        self.navigationItem.title = @"1 of 1";
    }

#ifndef DEBUG
    [[Database sharedInstance] incrementCardView:_card];
#endif
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.addButtonVisible = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mediaInsertsSet = [DTSet MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"Media Inserts"]];
    _newRating = 0;
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height-44;
    
    self.tblDetails = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                   style:UITableViewStylePlain];
    self.tblDetails.delegate = self;
    self.tblDetails.dataSource = self;
    [self.tblDetails registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
          forCellReuseIdentifier:@"Cell1"];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Card", @"Details"]];
    self.segmentedControl.frame = CGRectMake(dX+10, dY+7, dWidth-20, 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                              action:@selector(switchView)
                    forControlEvents:UIControlEventValueChanged];
    
    dHeight = 44;
    _viewSegmented = [[UIView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
    _viewSegmented.backgroundColor = [UIColor whiteColor];
    [_viewSegmented addSubview:self.segmentedControl];
    
    dY = self.view.frame.size.height - dHeight;
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];

    
    self.btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                  target:self
                                                                  action:@selector(btnActionTapped:)];
    NSMutableArray *arrButtons = [[NSMutableArray alloc] init];
    [arrButtons addObject:self.btnAction];
    self.btnRate = [[UIBarButtonItem alloc] initWithTitle:@"Rate This Card"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(btnRateTapped:)];
    [arrButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:nil
                                                                        action:nil]];
    [arrButtons addObject:self.btnRate];
    if (self.addButtonVisible)
    {
        self.btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(btnAddTapped:)];
        
        [arrButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil]];
        [arrButtons addObject:self.btnAdd];
    }
    self.bottomToolbar.items = arrButtons;

    [self.view addSubview:self.tblDetails];
    [self.view addSubview:self.bottomToolbar];

    self.btnPrevious = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"up4.png"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(btnPreviousTapped:)];
    self.btnNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"down4.png"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(btnNextTapped:)];
    self.navigationItem.rightBarButtonItems = @[self.btnNext, self.btnPrevious];
    
    if (self.fetchedResultsController)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSInteger index = [sectionInfo.objects indexOfObject:self.card];
        
        if (index == 0)
        {
            self.btnPrevious.enabled = NO;
        }
        if (index == [sectionInfo numberOfObjects]-1)
        {
            self.btnNext.enabled = NO;
        }
    }
    
    _planeswalkerType = [DTCardType MR_findFirstByAttribute:@"name" withValue:@"Planeswalker"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCardDownloadCompleted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadCardImage:)
                                                 name:kCardDownloadCompleted
                                               object:nil];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (self.fetchedResultsController)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSInteger index = [sectionInfo.objects indexOfObject:self.card];
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
        {
            index--;
            if (index < 0)
            {
                index = 0;
            }
        }
        else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
        {
            index++;
            if (index > sectionInfo.objects.count-1)
            {
                index = sectionInfo.objects.count-1;
            }
        }
        
        DTCard *card = sectionInfo.objects[index];
        [self setCard:card];
        [self.tblDetails reloadData];
    }
}

-(void) btnActionTapped:(id) sender
{
        NSMutableArray *sharingItems = [NSMutableArray new];
        
        [sharingItems addObject:[NSString stringWithFormat:@"%@ - via #Decktracker", self.card.name]];
        [sharingItems addObject:[UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]]];
    
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems
                                                                                         applicationActivities:nil];
        activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
        {
            if (completed)
            {
#ifndef DEBUG
                // send to Google Analytics
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card Details - Share"
                                                                      action:activityType
                                                                       label:nil
                                                                       value:nil] build]];
#endif
            }
        };
    
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void) btnRateTapped:(id) sender
{
    LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:@"Rate This Card"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Rate", nil];
    CGSize size = alertView.size;
    [alertView setSize:CGSizeMake(size.width, 152.0)];
    
    
    // Add your subviews here to customise
    UIView *contentView = alertView.contentView;
    EDStarRating *ratingControl = [[EDStarRating alloc] initWithFrame:CGRectMake((size.width/2.0 - 190.0/2.0), 55.0, 190.0, 50.0)];
    ratingControl.starImage = [UIImage imageNamed:@"star.png"];
    ratingControl.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    ratingControl.maxRating = 5.0;
    ratingControl.rating = 0;
    ratingControl.editable = YES;
    ratingControl.backgroundColor = [UIColor clearColor];
    ratingControl.displayMode=EDStarRatingDisplayAccurate;
    ratingControl.returnBlock = ^(float rating)
    {
        _newRating = rating;
    };
    [contentView addSubview:ratingControl];
    [alertView show];
}

-(void) btnAddTapped:(id) sender
{
    AddCardViewController *view = [[AddCardViewController alloc] init];
    
    view.arrDecks = [[NSMutableArray alloc] init];
    for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Decks"
                                                          fromFileSystem:FileSystemLocal])
    {
        [view.arrDecks addObject:[file stringByDeletingPathExtension]];
    }
    
    view.arrCollections = [[NSMutableArray alloc] init];
    for (NSString *file in [[FileManager sharedInstance] listFilesAtPath:@"/Collections"
                                                          fromFileSystem:FileSystemLocal])
    {
        [view.arrCollections addObject:[file stringByDeletingPathExtension]];
    }
    
    view.card = self.card;
    view.createButtonVisible = YES;
    view.showCardButtonVisible = NO;
    view.segmentedControlIndex = 0;
    [self.navigationController pushViewController:view animated:YES];
}

-(void) btnPreviousTapped:(id) sender
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger index = [sectionInfo.objects indexOfObject:self.card];
    
    index--;
    if (index < 0)
    {
        index = 0;
    }
    
    DTCard *card = sectionInfo.objects[index];
    [self setCard:card];
    [self.tblDetails reloadData];
}

-(void) btnNextTapped:(id) sender
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger index = [sectionInfo.objects indexOfObject:self.card];
    
    index++;
    if (index > sectionInfo.objects.count-1)
    {
        index = sectionInfo.objects.count-1;
    }
    
    DTCard *card = sectionInfo.objects[index];
    [self setCard:card];
    [self.tblDetails reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

-(void) switchView
{
    [self.tblDetails reloadData];
}

-(void) loadCardImage:(id) sender
{
    DTCard *card = [sender userInfo][@"card"];
    
    if (self.card == card)
    {
        NSString *path = [[FileManager sharedInstance] cardPath:card];
        UIImage *hiResImage = [UIImage imageWithContentsOfFile:path];
        
        self.cardImage.image = hiResImage;
        [[_fbImageViewer tableView] reloadData];
    }
}

- (void) displayCard
{
    NSInteger selectedRow = 0;
    if (self.fetchedResultsController)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        selectedRow = [sectionInfo.objects indexOfObject:self.card];
    }

    UIImage *image = [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]];
    [self.cardImage setImage:image];
    self.cardImage.contentMode = UIViewContentModeScaleAspectFit;
    self.cardImage.clipsToBounds = YES;
    
    [self.cardImage removeImageViewer];
    [self.cardImage setupImageViewerWithDatasource:self
                                      initialIndex:selectedRow
                                            onOpen:^{ }
                                           onClose:^{ }];
    
    [[FileManager sharedInstance] downloadCardImage:self.card immediately:YES];
    [self updateNavigationButtons];
}

- (void) displayDetails
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:[self composeDetails] baseURL:baseURL];
    [self updateNavigationButtons];
    
#ifndef DEBUG
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card Details - Details"
                                                          action:nil
                                                           label:nil
                                                           value:nil] build]];
#endif
}

- (void) updateNavigationButtons
{
    if (self.fetchedResultsController)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSInteger index = [sectionInfo.objects indexOfObject:self.card];
        
        self.btnPrevious.enabled = YES;
        self.btnNext.enabled = YES;
        if (index == sectionInfo.objects.count-1)
        {
            self.btnNext.enabled = NO;
        }
        if (index == 0)
        {
            self.btnPrevious.enabled = NO;
        }
    }
    else
    {
        self.btnPrevious.enabled = NO;
        self.btnNext.enabled = NO;
    }
}

- (NSString*) composeDetails
{
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendFormat:@"<html><head><link rel='stylesheet' type='text/css' href='%@/style.css'></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<table width='100%%'>"];
    
    [html appendFormat:@"<tr><td colspan='2'><div class='cardName'>%@</div></td></tr>", self.card.name];

    
    NSMutableString *text = [[NSMutableString alloc] init];
    if (self.card.originalType && ![self.card.originalType isEqualToString:self.card.type])
    {
        [text appendFormat:@"<div class='originalType'>%@</div>", self.card.originalType];
    }
    else
    {
        [text appendFormat:@"<div class='originalType'>%@</div>", self.card.type];
    }
    if (self.card.originalText)
    {
        if (([self.card.originalType hasPrefix:@"Basic Land"] ||
             [self.card.type hasPrefix:@"Basic Land"]) &&
            self.card.originalText.length == 1)
        {
            [text appendFormat:@"<p align='center'><img src='%@/images/mana/%@/96.png' width='96' height='96' /></p>", [[NSBundle mainBundle] bundlePath], self.card.originalText];
        }
        else
        {
            [text appendFormat:@"<p><div class='originalText'>%@</div></p>", [self replaceSymbolsInText:self.card.originalText]];
        }
    }
    if (self.card.flavor)
    {
        [text appendFormat:@"<p><div class='flavorText'>%@</div></p>", [self replaceSymbolsInText:self.card.flavor]];
    }
    if (self.card.power || self.card.toughness)
    {
        [text appendFormat:@"<p><div class='powerToughness'>%@/%@</div>", self.card.power, self.card.toughness];
    }
    else if ([self.card.types containsObject:_planeswalkerType])
    {
        [text appendFormat:@"<p><div class='powerToughness'>%@</div>", self.card.loyalty];
    }
    if (text.length > 0)
    {
        [html appendFormat:@"<tr><td colspan='2' align='center'><table class='textBox'><tr><td>%@</td></tr></table></td></tr>", text];
    }
    
    if (self.card.text)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Oracle Text</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'>%@<p>%@</td></tr>", self.card.type, [self replaceSymbolsInText:self.card.text]];
    }
    
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    if (self.card.cmc)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Converted Mana Cost</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", [self replaceSymbolsInText:[NSString stringWithFormat:@"{%@}", self.card.cmc]]];
    }

    if (self.card.power || self.card.toughness)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Power/Toughness</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@/%@</div></td></tr>", self.card.power, self.card.toughness];
    }
    else if ([self.card.types containsObject:_planeswalkerType])
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Loyalty</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", self.card.loyalty];
    }
    
    if (self.card.types.count > 1)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in self.card.types)
        {
            [types appendFormat:@"%@", type.name];
            if (i != self.card.types.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }

        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Types</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }
    
    if (self.card.superTypes.count > 0)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in self.card.superTypes)
        {
            [types appendFormat:@"%@", type.name];
            if (i != self.card.superTypes.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Super Types</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }
    
    if (self.card.subTypes.count > 0)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in self.card.subTypes)
        {
            [types appendFormat:@"%@", type.name];
            if (i != self.card.subTypes.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Sub Types</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }

    if (self.card.rarity)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Rarity</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", self.card.rarity.name];
    }
    
    if (self.card.artist)
    {
        NSString *link = [[NSString stringWithFormat:@"card?Artist=%@", self.card.artist.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Artist</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'><a href='%@'>%@</a></div></td></tr>", link, self.card.artist.name];
    }
    
    if (self.card.number)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Number</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@/%@</div></td></tr>", self.card.number, self.card.set.numberOfCards];
    }
    
    if (self.card.source)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Source</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", self.card.source];
    }

    [html appendFormat:@"<tr><td>&nbsp;</td>"];
    [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Printings</div></td></tr>"];
    [html appendFormat:@"<tr><td colspan='2'><table>"];
    for (DTSet *set in [[self.card.printings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO]]])
    {
        DTCard *card = [[Database sharedInstance] findCard:self.card.name inSet:set.code];
        
        NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:card]];
        [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, set.name];
        [html appendFormat:@"<tr><td>&nbsp;</td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>Release Date: %@</div></td></tr>", [card.set.name isEqualToString:_mediaInsertsSet.name] ? card.releaseDate : [JJJUtil formatDate:set.releaseDate withFormat:@"YYYY-MM-dd"]];
    }
    [html appendFormat:@"</table></td></tr>"];
    
    if (self.card.names.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Names</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table>"];
        for (DTCard *card in [[self.card.names allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:card]];
            [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, card.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    if (self.card.variations.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Variations</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table>"];
        for (DTCard *card in [[self.card.variations allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:card]];
            [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, card.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    if (self.card.rulings.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Rulings</div></td></tr>"];
        for (DTCardRuling *ruling in [[self.card.rulings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]])
        {
            [html appendFormat:@"<tr><td colspan='2'><i><b>%@</b></i>: %@</td></tr>", [JJJUtil formatDate:ruling.date withFormat:@"YYYY-MM-dd"], [self replaceSymbolsInText:ruling.text]];
        }
    }
    
    if (self.card.legalities.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Legalities</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table width='100%%'>"];
        for (DTCardLegality *legality in [[self.card.legalities allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"format.name" ascending:YES],
              [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            [html appendFormat:@"<tr><td width='50%%'><div class='detailTextSmall'>%@</div></td>", legality.format.name];
            [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", legality.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }

    if (self.card.foreignNames.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Languages</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table width='100%%'>"];
        for (DTCardForeignName *foreignName in [[self.card.foreignNames allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"language" ascending:YES]]])
        {
            [html appendFormat:@"<tr><td width='50%%'><div class='detailTextSmall'>%@</div></td>", foreignName.language];
            [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", foreignName.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    if (self.card.tcgPlayerLink)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'>Card pricing is provided by <a href=%@>TCGPlayer</a>.</td></tr>", self.card.tcgPlayerLink];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    [html appendFormat:@"</table></body></html>"];
    
    return html;
}

- (NSString*) composeSetImage:(DTCard*) card
{
    NSString *setPath = [[FileManager sharedInstance] cardSetPath:card];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:setPath];
    
    return [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f' border='0' />", setPath, image.size.width/2, image.size.height/2];
}

-(NSString*) replaceSymbolsInText:(NSString*) text
{
    NSMutableArray *arrSymbols = [[NSMutableArray alloc] init];
    int curlyOpen = -1;
    int curlyClose = -1;
    
    for (int i=0; i<text.length; i++)
    {
        if ([text characterAtIndex:i] == '{')
        {
            curlyOpen = i;
        }
        if ([text characterAtIndex:i] == '}')
        {
            curlyClose = i;
        }
        if (curlyOpen != -1 && curlyClose != -1)
        {
            NSString *symbol = [text substringWithRange:NSMakeRange(curlyOpen, (curlyClose-curlyOpen)+1)];
            
            [arrSymbols addObject:symbol];
            curlyOpen = -1;
            curlyClose = -1;
        }
    }
    
    for (NSString *symbol in arrSymbols)
    {
        BOOL bFound = NO;
        NSString *noCurlies = [[symbol substringWithRange:NSMakeRange(1, symbol.length-2)] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSString *noCurliesReverse = [JJJUtil reverseString:noCurlies];
        int pngSize = 0, width=0, height=0;
        
        if ([noCurlies isEqualToString:@"100"])
        {
            width = 24;
            height = 13;
            pngSize = 48;
        }
        else if ([noCurlies isEqualToString:@"1000000"])
        {
            width = 64;
            height = 13;
            pngSize = 96;
        }
        else
        {
            width = 16;
            height = 16;
            pngSize = 32;
        }
        
        for (NSString *mana in kManaSymbols)
        {
            if ([mana isEqualToString:noCurlies])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src='%@/images/mana/%@/%d.png' width='%d' height='%d' />", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize, width, height]];
                bFound = YES;
            }
            else if ([mana isEqualToString:noCurliesReverse])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src='%@/images/mana/%@/%d.png' width='%d' height='%d' />", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize, width, height]];
                bFound = YES;
            }
            else if ([mana isEqualToString:@"Infinity"])
            {
                text = [text stringByReplacingOccurrencesOfString:@"{∞}" withString:[NSString stringWithFormat:@"<img src='%@/images/mana/Infinity/%d.png' width='%d' height='%d' />", [[NSBundle mainBundle] bundlePath], pngSize, width, height]];
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src='%@/images/other/%@/%d.png' width='%d' height='%d' />", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize, width, height]];
                }
                else if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src='%@/images/other/%@/%d.png' width='%d' height='%d' />", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize, width, height]];
                }
            }
        }
    }
    
    text = [text stringByReplacingOccurrencesOfString:@"(" withString:@"(<i>"];
    text = [text stringByReplacingOccurrencesOfString:@")" withString:@")</i>"];
    return [JJJUtil stringWithNewLinesAsBRs:text];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString * q = [url query];
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs)
    {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [bits[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [bits[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [kvPairs setObject:value forKey:key];
    }
    
    if (kvPairs[@"name"] && kvPairs[@"set"])
    {
    
        self.fetchedResultsController = nil;
        
        DTCard *card = [[Database sharedInstance] findCard:kvPairs[@"name"]
                                                   inSet:kvPairs[@"set"]];
    
        [self setCard:card];
        self.segmentedControl.selectedSegmentIndex = 0;
        [self switchView];
    }
    
    else if (kvPairs[@"partner"] && [[url host] isEqualToString:@"store.tcgplayer.com"])
    {
        [[UIApplication sharedApplication] openURL:[request URL]];

        return NO;
    }
    
    else if (kvPairs[@"Artist"])
    {
        SimpleSearchViewController *view = [[SimpleSearchViewController alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artist.name CONTAINS[cd] %@", kvPairs[@"Artist"]];
        view.predicate = predicate;
        view.titleString = kvPairs[@"Artist"];
        view.showTabBar = NO;
        [view doSearch];
        
        [self.navigationController pushViewController:view animated:YES];
    }
    return YES;
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
}

#pragma mark -  MHFacebookImageViewerDatasource
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;

    if (self.fetchedResultsController)
    {
        return self.fetchedResultsController.fetchedObjects.count;
    }
    else
    {
        return 1;
    }
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    if (self.fetchedResultsController)
    {
        DTCard *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        if (self.card != card)
        {
            self.card = card;
            [self.tblDetails reloadData];
        }
    }

    return [NSURL fileURLWithPath:[[FileManager sharedInstance] cardPath:self.card]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    if (self.fetchedResultsController)
    {
        DTCard *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
        if (self.card != card)
        {
            self.card = card;
            [self.tblDetails reloadData];
        }
    }

    return [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]];
}

#pragma mark - UITableView
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone)
    {
        return nil;
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 44;
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return _viewSegmented;
    }
    else
    {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 1;
    
    if (section != 0)
    {
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 1:
            {
                return 1;
            }
            case 2:
            {
                return 1;
            }
        }
    }
    
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height = 44;
    
    if (indexPath.section == 0)
    {
        height = SEARCH_RESULTS_CELL_HEIGHT;
    }
    else if (indexPath.section == 1)
    {
        height = self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height - SEARCH_RESULTS_CELL_HEIGHT - _viewSegmented.frame.size.height - self.bottomToolbar.frame.size.height;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    [self.webView removeFromSuperview];
    [self.cardImage removeFromSuperview];
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height - SEARCH_RESULTS_CELL_HEIGHT - _viewSegmented.frame.size.height - self.bottomToolbar.frame.size.height;
    
    cell.userInteractionEnabled = YES;
    if (indexPath.section == 0)
    {
        cell = (SearchResultsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        
        if (!cell)
        {
            cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"Cell1"];
        }
        
//        [[Database sharedInstance] parseSynch:_card];
        [((SearchResultsTableViewCell*)cell) displayCard:self.card];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.userInteractionEnabled = NO;
    }

    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell2"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        switch (self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

                self.cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
                self.cardImage.backgroundColor = [UIColor grayColor];
                [self.cardImage setUserInteractionEnabled:YES];
                UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
                UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
                [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
                [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
                [self.cardImage addGestureRecognizer:swipeLeft];
                [self.cardImage addGestureRecognizer:swipeRight];
                [cell.contentView addSubview:self.cardImage];
                [self displayCard];
                break;
            }
            case 1:
            {
                tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
                self.webView.delegate = self;
                [cell.contentView addSubview:self.webView];
                
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.webView];
                [self.tblDetails addSubview:hud];
                hud.delegate = self;
                [hud showWhileExecuting:@selector(displayDetails) onTarget:self withObject:nil animated:NO];
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - UIAlerViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[Database sharedInstance] rateCard:self.card for:_newRating];
    }
}

@end
