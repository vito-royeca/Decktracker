//
//  CardDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CardDetailsViewController.h"

#import "JJJ/JJJUtil.h"
#import "AddCardViewController.h"
#import "AdvanceSearchResultsViewController.h"
#import "Artist.h"
#import "CardForeignName.h"
#import "CardLegality.h"
#import "CardRarity.h"
#import "CardRuling.h"
#import "CardType.h"
#import "Database.h"
#import "FileManager.h"
#import "Format.h"
#import "TFHpple.h"
#import "Magic.h"
#import "SearchResultsTableViewCell.h"
#import "SimpleSearchViewController.h"
#import "Set.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation CardDetailsViewController
{
    MHFacebookImageViewer *_fbImageViewer;
    UIView *_viewSegmented;
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
@synthesize btnAdd = _btnAdd;
@synthesize addButtonVisible = _addButtonVisible;

-(void) setCard:(Card *)card
{
    _card = card;
    
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
                Card *card = sectionInfo.objects[index+i];
                [[FileManager sharedInstance] downloadCardImage:card];
                [[FileManager sharedInstance] downloadCropImage:card];
            }
        }
    }
    else
    {
        self.navigationItem.title = @"1 of 1";
    }

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
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Card", @"Details", @"Pricing",]];
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
    self.btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                target:self
                                                                action:@selector(btnAddTapped:)];
    NSMutableArray *arrButtons = [[NSMutableArray alloc] init];
    [arrButtons addObject:self.btnAction];
    if (self.addButtonVisible)
    {
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
        
        Card *card = sectionInfo.objects[index];
        [self setCard:card];
        [self.tblDetails reloadData];
    }
}

-(void) btnActionTapped:(id) sender
{
        NSMutableArray *sharingItems = [NSMutableArray new];
        
        [sharingItems addObject:[NSString stringWithFormat:@"%@ - via #Decktracker", self.card.name]];
        [sharingItems addObject:[UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]]];
    
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void) btnAddTapped:(id) sender
{
    AddCardViewController *view = [[AddCardViewController alloc] init];
    
    view.arrDecks = [[NSMutableArray alloc] initWithArray:[[FileManager sharedInstance] findFilesAtPath:@"/Decks"]];
    view.arrCollections = [[NSMutableArray alloc] initWithArray:[[FileManager sharedInstance] findFilesAtPath:@"/Collections"]];
    view.card = self.card;
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
    
    Card *card = sectionInfo.objects[index];
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
    
    Card *card = sectionInfo.objects[index];
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
    Card *card = [sender userInfo][@"card"];
    
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
    [self.cardImage removeImageViewer];
    [self.cardImage setupImageViewerWithDatasource:self
                                      initialIndex:selectedRow
                                            onOpen:^{ }
                                           onClose:^{ }];
    self.cardImage.clipsToBounds = YES;
    
    [[FileManager sharedInstance] downloadCardImage:self.card];
    [self updateNavigationButtons];
    
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card Details - Card"
                                                          action:nil
                                                           label:nil
                                                           value:nil] build]];
}

- (void) displayDetails
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:[self composeDetails] baseURL:baseURL];
    [self updateNavigationButtons];
    
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card Details - Details"
                                                          action:nil
                                                           label:nil
                                                           value:nil] build]];
}

- (void) displayPricing
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:[self composePricing] baseURL:baseURL];
    [self updateNavigationButtons];
    
    // send to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Card Details - Pricing"
                                                          action:nil
                                                           label:nil
                                                           value:nil] build]];
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
    
    [html appendFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@/style.css\"></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<table>"];
    
    if (self.card.cmc)
    {
        [html appendFormat:@"<tr><td><strong>Converted Mana Cost</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", [self replaceSymbolsInText:[NSString stringWithFormat:@"{%@}", self.card.cmc]]];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.originalText)
    {
        [html appendFormat:@"<tr><td><strong>Original Text</v></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", [self replaceSymbolsInText:self.card.originalText]];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.text)
    {
        [html appendFormat:@"<tr><td><strong>Oracle Text</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", [self replaceSymbolsInText:self.card.text]];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.flavor)
    {
        [html appendFormat:@"<tr><td><strong>Flavor Text</strong></td></tr>"];
        [html appendFormat:@"<tr><td><i>%@</i></td></tr>", self.card.flavor];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    [html appendFormat:@"<tr><td><strong>Artist</strong></td></tr>"];
    [html appendFormat:@"<tr><td>%@</td></tr>", self.card.artist.name];
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    
    if (self.card.number)
    {
        [html appendFormat:@"<tr><td><strong>Number</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@/%@</td></tr>", self.card.number, self.card.set.numberOfCards];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.source)
    {
        [html appendFormat:@"<tr><td><strong>Source</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", self.card.source];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }

    [html appendFormat:@"<tr><td><strong>All Sets</strong></td></tr>"];
    [html appendFormat:@"<tr><td><table>"];
    for (Set *set in [[self.card.printings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:YES]]])
    {
        Card *card = [[Database sharedInstance] findCard:self.card.name inSet:set.code];
        
        NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [html appendFormat:@"<tr><td><a href=\"%@\">%@</a></td><td><a href=\"%@\">%@</a></td></tr>", link, [self composeSetImage:card], link, set.name];
        [html appendFormat:@"<tr><td>&nbsp;</td><td>Release Date: %@</td></tr>", [JJJUtil formatDate:set.releaseDate withFormat:@"YYYY-MM-dd"]];
    }
    [html appendFormat:@"</table></td></tr>"];
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    
    if (self.card.names.count > 0)
    {
        [html appendFormat:@"<tr><td><strong>Names</strong></td></tr>"];
        [html appendFormat:@"<tr><td><table>"];
        for (Card *card in [[self.card.names allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href=\"%@\">%@</a></td><td><a href=\"%@\">%@</a></td></tr>", link, [self composeSetImage:card], link, card.name];
        }
        [html appendFormat:@"</table></td></tr>"];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.variations.count > 0)
    {
        [html appendFormat:@"<tr><td><strong>Variations</strong></td></tr>"];
        [html appendFormat:@"<tr><td><table>"];
        for (Card *card in [[self.card.variations allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, card.set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [html appendFormat:@"<tr><td><a href=\"%@\">%@</a></td><td><a href=\"%@\">%@</a></td></tr>", link, [self composeSetImage:card], link, card.name];
        }
        [html appendFormat:@"</table></td></tr>"];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.rulings.count > 0)
    {
        [html appendFormat:@"<tr><td><strong>Rulings</strong></td></tr>"];
        for (CardRuling *ruling in [[self.card.rulings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]])
        {
            [html appendFormat:@"<tr><td><i><b>%@</b></i>: %@</td></tr>", [JJJUtil formatDate:ruling.date withFormat:@"YYYY-MM-dd"], [self replaceSymbolsInText:ruling.text]];
        }
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.legalities.count > 0)
    {
        [html appendFormat:@"<tr><td><strong>Legalities</strong></td></tr>"];
        for (CardLegality *legality in [[self.card.legalities allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"format.name" ascending:YES],
              [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]])
        {
            [html appendFormat:@"<tr><td>%@: %@</td></tr>", legality.format.name, legality.name];
        }
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }

    if (self.card.foreignNames.count > 0)
    {
        [html appendFormat:@"<tr><td><strong>Languages</strong></td></tr>"];
        [html appendFormat:@"<tr><td><table>"];
        for (CardForeignName *foreignName in [[self.card.foreignNames allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"language" ascending:YES]]])
        {
            [html appendFormat:@"<tr><td>%@</td><td>%@</td></tr>", foreignName.language, foreignName.name];
        }
        [html appendFormat:@"</table></td></tr>"];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    [html appendFormat:@"</table></body></html>"];
    return html;
}

- (NSString*) composeSetImage:(Card*) card
{
    NSString *setPath = [[FileManager sharedInstance] cardSetPath:card];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:setPath];
    
    return [NSString stringWithFormat:@"<img src=\"%@\" width=\"%f\" height=\"%f\" border=\"0\" />", setPath, image.size.width/2, image.size.height/2];
}

- (NSString*) composePricing
{
    NSString *tcgPricing = [[NSString stringWithFormat:@"http://partner.tcgplayer.com/x3/phl.asmx/p?pk=%@&s=%@&p=%@", TCGPLAYER_PARTNER_KEY, self.card.set.tcgPlayerName, self.card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!self.card.set.tcgPlayerName)
    {
        tcgPricing = [[NSString stringWithFormat:@"http://partner.tcgplayer.com/x3/phl.asmx/p?pk=%@&p=%@", TCGPLAYER_PARTNER_KEY, self.card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tcgPricing]];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSString *low, *med, *high, *foil, *link;
    
    NSArray *nodes = [parser searchWithXPathQuery:@"//product"];
    for (TFHppleElement *element in nodes)
    {
        if ([element hasChildren])
        {
            BOOL linkIsNext = NO;
            
            for (TFHppleElement *child in element.children)
            {
                if ([[child tagName] isEqualToString:@"hiprice"])
                {
                    high = [[child firstChild] content];
                }
                else if ([[child tagName] isEqualToString:@"avgprice"])
                {
                    med = [[child firstChild] content];
                }
                else if ([[child tagName] isEqualToString:@"lowprice"])
                {
                    low = [[child firstChild] content];
                }
                else if ([[child tagName] isEqualToString:@"foilavgprice"])
                {
                    foil = [[child firstChild] content];
                }
                else if ([[child tagName] isEqualToString:@"link"])
                {
                    linkIsNext = YES;
                }
                else if ([[child tagName] isEqualToString:@"text"] && linkIsNext)
                {
                    link = [child content];
                }
            }
        }
    }
    
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@/style.css\"></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<center><table width=\"100%%\">"];

    [html appendFormat:@"<tr>"];
    [html appendFormat:@"<td align=\"center\" bgcolor=\"red\" width=\"25%%\"><strong><font color=\"white\">Low</font></strong></td>"];
    [html appendFormat:@"<td align=\"center\" bgcolor=\"blue\" width=\"25%%\"><strong><font color=\"white\">Median</font></strong></td>"];
    [html appendFormat:@"<td align=\"center\" bgcolor=\"green\" width=\"25%%\"><strong><font color=\"white\">High</font></strong></td>"];
    [html appendFormat:@"<td align=\"center\" bgcolor=\"silver\" width=\"25%%\"><strong><font color=\"white\">Foil</font></strong></td>"];
    [html appendFormat:@"</tr>"];
    
    [html appendFormat:@"<tr>"];
    [html appendFormat:@"<td align=\"right\" width=\"25%%\">%@</td>", low && ![low isEqualToString:@"0"] ? [NSString stringWithFormat:@"$%@", low] : @"N/A"];
    [html appendFormat:@"<td align=\"right\" width=\"25%%\">%@</td>", med && ![med isEqualToString:@"0"]? [NSString stringWithFormat:@"$%@", med] : @"N/A"];
    [html appendFormat:@"<td align=\"right\" width=\"25%%\">%@</td>", high && ![high isEqualToString:@"0"]? [NSString stringWithFormat:@"$%@", high] : @"N/A"];
    [html appendFormat:@"<td align=\"right\" width=\"25%%\">%@</td>", foil && ![foil isEqualToString:@"0"]? [NSString stringWithFormat:@"$%@", foil] : @"N/A"];
    [html appendFormat:@"</tr>"];
    [html appendFormat:@"<tr><td colspan=\"3\">&nbsp;</td></tr>"];
    if (link)
    {
        [html appendFormat:@"<tr><td colspan=\"3\">More details at <a href=%@>TCGPlayer</a>.</td></tr>", link];
    }

    [html appendFormat:@"</table></center></body></html>"];
    return html;
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
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/%@/%d.png\" width=\"%d\"/ height=\"%d\" />", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize, width, height]];
                bFound = YES;
            }
            else if ([mana isEqualToString:noCurliesReverse])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/%@/%d.png\" width=\"%d\"/ height=\"%d\" />", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize, width, height]];
                bFound = YES;
            }
            else if ([mana isEqualToString:@"Infinity"])
            {
                text = [text stringByReplacingOccurrencesOfString:@"{∞}" withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/Infinity/%d.png\" width=\"%d\"/ height=\"%d\" />", [[NSBundle mainBundle] bundlePath], pngSize, width, height]];
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/other/%@/%d.png\" width=\"%d\"/ height=\"%d\" />", [[NSBundle mainBundle] bundlePath], noCurlies, pngSize, width, height]];
                }
                else if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/other/%@/%d.png\" width=\"%d\"/ height=\"%d\" />", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngSize, width, height]];
                }
            }
        }
    }
    
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
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
        
        Card *card = [[Database sharedInstance] findCard:kvPairs[@"name"]
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
        Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
        [self setCard:card];
        [self.tblDetails reloadData];
    }
    return [NSURL fileURLWithPath:[[FileManager sharedInstance] cardPath:self.card]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    if (self.fetchedResultsController)
    {
        Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
        [self setCard:card];
        [self.tblDetails reloadData];
    }
    return [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]];
}

#pragma mark - UITableView
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone)
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
    
    if (indexPath.section == 0)
    {
        cell = (SearchResultsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        
        if (!cell)
        {
            cell = [[SearchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"Cell1"];
        }
        
        [((SearchResultsTableViewCell*)cell) displayCard:self.card];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
            case 2:
            {
                tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
                self.webView.delegate = self;
                [cell.contentView addSubview:self.webView];

                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.webView];
                [self.tblDetails addSubview:hud];
                hud.delegate = self;
                [hud showWhileExecuting:@selector(displayPricing) onTarget:self withObject:nil animated:NO];
                break;
            }
        }
    }
    
    return cell;
}

@end
