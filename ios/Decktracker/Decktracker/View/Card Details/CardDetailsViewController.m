//
//  CardDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CardDetailsViewController.h"

#import "AddCardViewController.h"
#import "Constants.h"
#import "DTArtist.h"
#import "DTCardColor.h"
#import "DTCardForeignName.h"
#import "DTCardLegality.h"
#import "DTCardRarity.h"
#import "DTCardRuling.h"
#import "DTCardType.h"
#import "DTFormat.h"
#import "DTLanguage.h"
#import "DTSet.h"
#import "Database.h"
#import "FileManager.h"
#import "SearchResultsTableViewCell.h"

#import "Decktracker-Swift.h"

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
    float _newRating;
    NSString *_currentCardImage;
    NSString *_currentLanguage;
}

-(void) setCardId:(NSString*) cardId
{
    _cardId = cardId;
    _currentCardImage = [[FileManager sharedInstance] cardPath:_cardId forLanguage:_currentLanguage];
    
    [[FileManager sharedInstance] downloadCardImage:_cardId forLanguage:_currentLanguage immediately:YES];

    if (self.cardIds)
    {
        NSInteger index = 0;
        
        for (NSString *kardId in self.cardIds) {
            if ([kardId isEqualToString:cardId])
            {
                break;
            }
            index++;
        }
        self.navigationItem.title = [NSString stringWithFormat:@"%tu of %tu", index+1, self.cardIds.count];

        // download next four card images
        for (int i = 0; i < 5; i++)
        {
            if (index+i <= self.cardIds.count-1)
            {
                [[FileManager sharedInstance] downloadCardImage:self.cardIds[index+i] forLanguage:_currentLanguage immediately:NO];
            }
        }
    }
    else
    {
        self.navigationItem.title = @"1 of 1";
    }

//#ifndef DEBUG
    [[Database sharedInstance] incrementCardView:cardId];
//#endif
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
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Card", @"Details"/*, @"Reviews"*/]];
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
    self.btnRate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rate.png"]
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
    
    if (self.cardIds)
    {
        NSInteger index = [self.cardIds indexOfObject:self.cardId];
        
        if (index == 0)
        {
            self.btnPrevious.enabled = NO;
        }
        if (index == self.cardIds.count-1)
        {
            self.btnNext.enabled = NO;
        }
    }
    
    _planeswalkerType = [[DTCardType objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Planeswalker"]] firstObject];
    
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
    if (self.cardIds)
    {
        NSInteger index = [self.cardIds indexOfObject:self.cardId];
        
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
            if (index > self.cardIds.count-1)
            {
                index = self.cardIds.count-1;
            }
        }
        
        id kardId = self.cardIds[index];
        [self setCardId:kardId];
        [self.tblDetails reloadData];
    }
}

-(void) btnActionTapped:(id) sender
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    [sharingItems addObject:[NSString stringWithFormat:@"%@ - via #Decktracker", card.name]];
    [sharingItems addObject:[UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.cardId forLanguage:_currentLanguage]]];
    
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
    
    view.cardId = self.cardId;
    view.createButtonVisible = YES;
    view.showCardButtonVisible = NO;
    view.segmentedControlIndex = 0;
    [self.navigationController pushViewController:view animated:YES];
}

-(void) btnPreviousTapped:(id) sender
{
    NSInteger index = [self.cardIds indexOfObject:self.cardId];
    
    index--;
    if (index < 0)
    {
        index = 0;
    }
    
    id kardId = self.cardIds[index];
    [self setCardId:kardId];
    [self.tblDetails reloadData];
}

-(void) btnNextTapped:(id) sender
{
    NSInteger index = [self.cardIds indexOfObject:self.cardId];
    
    index++;
    if (index > self.cardIds.count-1)
    {
        index = self.cardIds.count-1;
    }
    
    id kardId = self.cardIds[index];
    [self setCardId:kardId];
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
    NSString *cardId = [sender userInfo][@"cardId"];
    
    if (self.cardId == cardId)
    {
        NSString *path = [[FileManager sharedInstance] cardPath:self.cardId forLanguage:_currentLanguage];
        
        if (![path isEqualToString:_currentCardImage])
        {
            UIImage *hiResImage = [UIImage imageWithContentsOfFile:path];
        
            [UIView transitionWithView:self.cardImage
                              duration:1
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.cardImage.image = hiResImage;
                            } completion:nil];
            
            [[_fbImageViewer tableView] reloadData];
        }
        
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:kCardDownloadCompleted
//                                                      object:nil];
    }
}

- (void) displayCard
{
    NSInteger selectedRow = 0;
    
    if (self.cardIds)
    {
        selectedRow = [self.cardIds indexOfObject:self.cardId];
    }

    UIImage *image = [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.cardId forLanguage:_currentLanguage]];
    self.cardImage.image = image;
    self.cardImage.contentMode = UIViewContentModeScaleAspectFit;
    self.cardImage.clipsToBounds = YES;
    
    [self.cardImage removeImageViewer];
    [self.cardImage setupImageViewerWithDatasource:self
                                      initialIndex:selectedRow
                                            onOpen:^{ }
                                           onClose:^{ }];
    
    [[FileManager sharedInstance] downloadCardImage:self.cardId forLanguage:_currentLanguage immediately:YES];
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
    if (self.cardIds)
    {
        NSInteger index = [self.cardIds indexOfObject:self.cardId];
        
        self.btnPrevious.enabled = YES;
        self.btnNext.enabled = YES;
        if (index == self.cardIds.count-1)
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
    DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
    
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendFormat:@"<html><head><link rel='stylesheet' type='text/css' href='%@/web/style.css'></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<table width='100%%'>"];
    
    NSString *cardNameFont;
    if (card.modern)
    {
        cardNameFont = @"cardNameEightEdition";
    }
    else
    {
        cardNameFont = @"cardNamePreEightEdition";
    }
    [html appendFormat:@"<tr><td colspan='2'><div class='%@'>%@</div></td></tr>", cardNameFont, card.name];

    
    NSMutableString *text = [[NSMutableString alloc] init];
    if (card.originalType.length &&
        ![card.originalType isEqualToString:card.type])
    {
        [text appendFormat:@"<div class='originalType'>%@</div>", card.originalType];
    }
    else
    {
        [text appendFormat:@"<div class='originalType'>%@</div>", card.type];
    }
    if (card.originalText.length > 0)
    {
        if (([card.originalType hasPrefix:@"Basic Land"] ||
             [card.type hasPrefix:@"Basic Land"]) &&
             card.originalText.length == 1)
        {
            [text appendFormat:@"<p align='center'><img src='%@/images/mana/%@/96.png' width='96' height='96' /></p>", [[NSBundle mainBundle] bundlePath], card.originalText];
        }
        else
        {
            [text appendFormat:@"<p><div class='originalText'>%@</div></p>", [self replaceSymbolsInText:card.originalText]];
        }
    }
    if (card.flavor.length > 0)
    {
        [text appendFormat:@"<p><div class='flavorText'>%@</div></p>", [self replaceSymbolsInText:card.flavor]];
    }
    if (card.power.length > 0  || card.toughness.length > 0)
    {
        [text appendFormat:@"<p><div class='powerToughness'>%@/%@</div>", card.power, card.toughness];
    }
    else
    {
        for (DTCardType *cardType in card.types)
        {
            if (cardType == _planeswalkerType)
            {
                [text appendFormat:@"<p><div class='powerToughness'>%d</div>", card.loyalty];
                break;
            }
        }
    }
    if (text.length > 0)
    {
        [html appendFormat:@"<tr><td colspan='2' align='center'><table class='textBox'><tr><td>%@</td></tr></table></td></tr>", text];
    }
    
    if (card.text.length > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Oracle Text</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'>%@<p>%@</td></tr>", card.type, [self replaceSymbolsInText:card.text]];
    }
    
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    if (card.cmc >= 0)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Converted Mana Cost&nbsp;&nbsp;</div></td>"];
    [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", [self replaceSymbolsInText:[NSString stringWithFormat:@"{%@}", [NSNumber numberWithFloat:card.cmc]]]];
    }

    if (card.power.length > 0 || card.toughness.length > 0)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Power/Toughness&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@/%@</div></td></tr>", card.power, card.toughness];
    }
    else
    {
        for (DTCardType *cardType in card.types)
        {
            if (cardType == _planeswalkerType)
            {
                [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Loyalty&nbsp;&nbsp;</div></td>"];
                [html appendFormat:@"<td><div class='detailTextSmall'>%d</div></td></tr>", card.loyalty];
            }
        }
    }
    
    if (card.types.count > 1)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in card.types)
        {
            [types appendFormat:@"%@", type.name];
            if (i != card.types.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }

        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Types&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }
    
    if (card.superTypes.count > 0)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in card.superTypes)
        {
            [types appendFormat:@"%@", type.name];
            if (i != card.superTypes.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Super Types&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }
    
    if (card.subTypes.count > 0)
    {
        NSMutableString *types = [[NSMutableString alloc] init];
        int i=0;
        for (DTCardType *type in card.subTypes)
        {
            [types appendFormat:@"%@", type.name];
            if (i != card.subTypes.count-1)
            {
                [types appendFormat:@", "];
            }
            i++;
        }
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Sub Types&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></tr>", types];
    }

    if (card.rarity)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Rarity&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", card.rarity.name];
    }
    
    if (card.artist)
    {
        NSString *link = [[NSString stringWithFormat:@"artist?name=%@", card.artist.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Artist&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'><a href='%@'>%@</a></div></td></tr>", link, card.artist.name];
    }
    
    if (card.number.length > 0)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Number&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@/%d</div></td></tr>", card.number, card.set.numberOfCards];
    }
    
    if (card.source.length > 0)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Source&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", card.source];
    }

    if (card.reserved)
    {
        [html appendFormat:@"<tr><td width='50%%' align='right'><div class='detailHeaderSmall'>Will Be Reprinted?&nbsp;&nbsp;</div></td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", card.reserved ? @"No" : @"Yes"];
    }

    [html appendFormat:@"<tr><td>&nbsp;</td>"];
    [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Printings</div></td></tr>"];
    [html appendFormat:@"<tr><td colspan='2'><table>"];
    NSMutableArray *sets = [[NSMutableArray alloc] init];
    for (DTSet *set in card.printings)
    {
        [sets addObject:set];
    }
    for (DTSet *set in [sets sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO]]])
    {
        if (![[Database sharedInstance] isSetPurchased:set])
        {
            continue;
        }
        
        DTCard *kard = [[Database sharedInstance] findCard:card.name inSet:set.code];
        NSString *link = [[NSString stringWithFormat:@"printings?cardId=%@", kard.cardId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:kard]];
        [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, set.name];
        [html appendFormat:@"<tr><td>&nbsp;</td>"];
        [html appendFormat:@"<td><div class='detailTextSmall'>Release Date: %@</div></td></tr>", kard.releaseDate.length > 0 ? kard.releaseDate : [JJJUtil formatDate:set.releaseDate withFormat:@"YYYY-MM-dd"]];
    }
    [html appendFormat:@"</table></td></tr>"];
    
    if (card.names.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Names</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table>"];
        NSMutableArray *cards = [[NSMutableArray alloc] init];
        for (DTCard *kard in card.names)
        {
            [cards addObject:kard];
        }
        for (DTCard *kard in [cards sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            if (![[Database sharedInstance] isSetPurchased:kard.set])
            {
                continue;
            }
            
            NSString *link = [[NSString stringWithFormat:@"names?cardId=%@", kard.cardId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:kard]];
            [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, kard.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    if (card.variations.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Variations</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table>"];
        NSMutableArray *cards = [[NSMutableArray alloc] init];
        for (DTCard *kard in card.variations)
        {
            [cards addObject:kard];
        }
        for (DTCard *kard in [cards sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            if (![[Database sharedInstance] isSetPurchased:kard.set])
            {
                continue;
            }
            
            NSString *link = [[NSString stringWithFormat:@"variations?cardId=%@", kard.cardId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href='%@'>%@</a></td>", link, [self composeSetImage:kard]];
            [html appendFormat:@"<td><a href='%@'>%@</a></td></tr>", link, kard.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    RLMResults *rulings = [[DTCardRuling objectsWithPredicate:[NSPredicate predicateWithFormat:@"card.cardId = %@", self.cardId]] sortedResultsUsingProperty:@"date" ascending:NO];
    if (rulings.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Rulings</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table width='100%%'>"];
        for (DTCardRuling *ruling in rulings)
        {
            [html appendFormat:@"<tr><td colspan='2'><i><b>%@</b></i>: %@</td></tr>", [JJJUtil formatDate:ruling.date withFormat:@"YYYY-MM-dd"], [self replaceSymbolsInText:ruling.text]];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    RLMResults *legalities = [[DTCardLegality objectsWithPredicate:[NSPredicate predicateWithFormat:@"card.cardId = %@", self.cardId]] sortedResultsUsingProperty:@"name" ascending:YES];
    if (legalities.count > 0)
    {
        NSMutableArray *marrSorted = [[NSMutableArray alloc] init];
        for (DTCardLegality *legality in legalities)
        {
            [marrSorted addObject:legality];
        }
        NSArray *arrSorted = [marrSorted sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"format.name" ascending:YES]]];

        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Legalities</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table width='100%%'>"];
        for (DTCardLegality *legality in arrSorted)
        {
            [html appendFormat:@"<tr><td width='50%%'><div class='detailTextSmall'>%@</div></td>", legality.format.name];
            [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", legality.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    RLMResults *foreignNames = [[DTCardForeignName objectsWithPredicate:[NSPredicate predicateWithFormat:@"card.cardId = %@", self.cardId]] sortedResultsUsingProperty:@"name" ascending:YES];
    if (foreignNames.count > 0)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><div class='detailHeader'>Languages</div></td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'><table width='100%%'>"];
        
        DTCard *card = [DTCard objectForPrimaryKey:self.cardId];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (DTLanguage *language in [card.set.languages sortedResultsUsingProperty:@"name" ascending:YES])
        {
            for (DTCardForeignName *foreignName in foreignNames)
            {
                if ([foreignName.language.name isEqualToString:language.name])
                {
                    [array addObject:foreignName];
                }
            }
        }
        
        for (DTCardForeignName *foreignName in array)
        {
            [html appendFormat:@"<tr><td width='50%%'><div class='detailTextSmall'>%@</div></td>", foreignName.language.name];
            [html appendFormat:@"<td><div class='detailTextSmall'>%@</div></td></tr>", foreignName.name];
        }
        [html appendFormat:@"</table></td></tr>"];
    }
    
    if (card.tcgPlayerLink)
    {
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
        [html appendFormat:@"<tr><td colspan='2'>Buy this card at <a href=%@>TCGPlayer</a>.</td></tr>", card.tcgPlayerLink];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    [html appendFormat:@"</table></body></html>"];
    
    return html;
}

- (NSString*) composeSetImage:(DTCard*) card
{
    NSString *setPath = [[FileManager sharedInstance] cardSetPath:[NSString stringWithFormat:@"%tu", card.cardId]];
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
    NSString *path = [[url path] lastPathComponent];
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
    
    _currentLanguage = nil;
    
    if ([path isEqualToString:@"artist"])
    {
        CardListViewController *view = [[CardListViewController alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artist.name CONTAINS[c] %@", kvPairs[@"name"]];
        view.predicate = predicate;
        view.navigationItem.title = kvPairs[@"name"];
        [self.navigationController pushViewController:view animated:YES];
    }
    
    else if ([path isEqualToString:@"printings"] ||
             [path isEqualToString:@"names"] ||
             [path isEqualToString:@"variations"])
    {
        self.cardIds = nil;
//        DTCard *card = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"set.code = %@ AND number = %@", kvPairs[@"set"], kvPairs[@"number"]]] firstObject];
        
        self.cardId = kvPairs[@"cardId"];
        self.segmentedControl.selectedSegmentIndex = 0;
        [self switchView];
    }
    else if ([path isEqualToString:@"foreign"])
    {
        _currentLanguage = kvPairs[@"language"];
        self.cardId = kvPairs[@"cardId"];
        self.segmentedControl.selectedSegmentIndex = 0;
        [self switchView];
    }
    
    else
    {
        if ([[url host] isEqualToString:@"store.tcgplayer.com"])
        {
            [[UIApplication sharedApplication] openURL:[request URL]];

            return NO;
        }
    }

    return YES;
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    CGFloat height = webView.scrollView.contentSize.height;
//    CGRect newFrame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, height);
//    webView.frame = newFrame;
//    webView.scrollView.scrollEnabled = NO;
//}

#pragma mark -  MHFacebookImageViewerDatasource
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;

    if (self.cardIds)
    {
        return self.cardIds.count;
    }
    else
    {
        return 1;
    }
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    if (self.cardIds)
    {
        NSString *cardId = self.cardIds[index];
        
        if (self.cardId != cardId)
        {
            self.cardId = cardId;
            [self.tblDetails reloadData];
        }
    }

    return [NSURL fileURLWithPath:[[FileManager sharedInstance] cardPath:self.cardId forLanguage:_currentLanguage]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    if (self.cardIds)
    {
        NSString *cardId = self.cardIds[index];
        
        if (self.cardId != cardId)
        {
            self.cardId = cardId;
            [self.tblDetails reloadData];
        }
    }

    return [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.cardId forLanguage:_currentLanguage]];
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
        
        [((SearchResultsTableViewCell*)cell) displayCard:self.cardId];
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
                UIImage *bgImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/images/Gray_Patterned_BG.jpg", [[NSBundle mainBundle] bundlePath]]];
                self.cardImage.backgroundColor = [UIColor colorWithPatternImage:bgImage];
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
        [[Database sharedInstance] rateCard:self.cardId withRating:_newRating];
    }
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
