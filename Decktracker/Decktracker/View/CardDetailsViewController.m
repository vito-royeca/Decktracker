//
//  CardDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CardDetailsViewController.h"

#import "JJJ/JJJUtil.h"
#import "AdvanceSearchResultsViewController.h"
#import "Artist.h"
#import "CardForeignName.h"
#import "CardRarity.h"
#import "CardRuling.h"
#import "CardType.h"
#import "Database.h"
#import "FileManager.h"
#import "Magic.h"
#import "SimpleSearchViewController.h"
#import "Set.h"
#import "UIImage+Scale.h"

@implementation CardDetailsViewController
{
    MHFacebookImageViewer *_fbImageViewer;
}

@synthesize card = _card;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize segmentedControl = _segmentedControl;
@synthesize cardImage = cardImage;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

//-(void) setCard:(Card*) card
//{
//    _card = card;
//    
//    self.navigationItem.title = self.card.name;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat dX = 10;
    CGFloat dY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height+10;
    CGFloat dWidth = self.view.frame.size.width-20;
    CGFloat dHeight = 30;
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Card", @"Details", @"Pricing",]];
    self.segmentedControl.frame = CGRectMake(dX, dY, dWidth, dHeight);
    [self.segmentedControl addTarget:self
                              action:@selector(switchView)
                    forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentedControl];
    [self switchView];
    
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                               target:self
                                                                               action:@selector(btnActionTapped:)];
    self.navigationItem.rightBarButtonItem = btnAction;
}

-(void) btnActionTapped:(id) sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(BOOL)hidesBottomBarWhenPushed
//{
//    return YES;
//}

-(void) switchView
{
    CGFloat dX = 0;
    CGFloat dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height +10;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    [self.cardImage removeFromSuperview];
    [self.webView removeFromSuperview];
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            self.cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
            self.cardImage.backgroundColor = [UIColor grayColor];
            [self.cardImage setUserInteractionEnabled:YES];
            UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            
            // Setting the swipe direction.
            [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
            [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
            
            // Adding the swipe gesture on image view
            [self.cardImage addGestureRecognizer:swipeLeft];
            [self.cardImage addGestureRecognizer:swipeRight];
            
            [self.view addSubview:self.cardImage];
            
            [self displayCard];
            break;
        }
            
        case 1:
        {
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            
            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
            self.webView.delegate = self;
            [self.view addSubview:self.webView];
            [self.webView loadHTMLString:[self composeDetails] baseURL:baseURL];
            break;
        }
        case 2:
        {
            break;
        }
    }
}

- (void) displayCard
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger selectedRow = [sectionInfo.objects indexOfObject:self.card];
    
//    if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[SimpleSearchViewController class]])
//    {
//        SimpleSearchViewController *parent = [self.navigationController.viewControllers firstObject];
//        [parent.tblResults selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]
//                                       animated:NO
//                                 scrollPosition:UITableViewScrollPositionMiddle];
//    }
//    else if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[AdvanceSearchResultsViewController class]])
//    {
//        AdvanceSearchResultsViewController *parent = [self.navigationController.viewControllers firstObject];
//        [parent.tblResults selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]
//                                       animated:NO
//                                 scrollPosition:UITableViewScrollPositionMiddle];
//    }
    
    void (^completion)(void) = ^void(void)
    {
        NSString *path = [[FileManager sharedInstance] cardPath:self.card];
        UIImage *hiResImage = [UIImage imageWithContentsOfFile:path];
        
        [self.cardImage setImage:hiResImage];
        [[_fbImageViewer tableView] reloadData];
    };
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]];
    [self.cardImage setImage:image];
    self.cardImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.cardImage removeImageViewer];
    [self.cardImage setupImageViewerWithDatasource:self
                                      initialIndex:selectedRow
                                            onOpen:^{ }
                                           onClose:^{ }];
    self.cardImage.clipsToBounds = YES;
    self.navigationItem.title = self.card.name;
    
    [[FileManager sharedInstance] downloadCardImage:self.card withCompletion:completion];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
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
    [self displayCard];
}

- (NSString*) composeDetails
{
    NSMutableString *html = [[NSMutableString alloc] init];
    NSString *setPath = [NSString stringWithFormat:@"%@/images/set", [[NSBundle mainBundle] bundlePath]];
    
    [html appendFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@/style.css\"></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<table>"];
    
    if (self.card.manaCost)
    {
        [html appendFormat:@"<tr><td><strong>Mana Cost</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", [self replaceSymbolsInText:self.card.manaCost]];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if (self.card.cmc)
    {
        [html appendFormat:@"<tr><td><strong>Converted Mana Cost</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", [self replaceSymbolsInText:[NSString stringWithFormat:@"{%@}", self.card.cmc]]];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    [html appendFormat:@"<tr><td><strong>Type</strong></td></tr>"];
    [html appendFormat:@"<tr><td>%@</td></tr>", self.card.type];
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    
    if (self.card.power || self.card.toughness)
    {
        [html appendFormat:@"<tr><td><strong>Power/Toughness</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@/%@</td></tr>", self.card.power, self.card.toughness];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    if ([self.card.types containsObject:[CardType MR_findFirstByAttribute:@"name" withValue:@"Planeswalker"]])
    {
        [html appendFormat:@"<tr><td><strong>Planeswalker Loyalty</strong></td></tr>"];
        [html appendFormat:@"<tr><td>%@</td></tr>", self.card.loyalty];
        [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    }
    
    [html appendFormat:@"<tr><td><strong>Rarity</strong></td></tr>"];
    [html appendFormat:@"<tr><td><table><tr><td><img src=\"%@/%@/%@/24.png\" border=\"0\" /></td><td>%@ - %@</td></tr></table></td></tr>", setPath, self.card.set.code, [[Database sharedInstance] cardRarityIndex:self.card], self.card.set.name, self.card.rarity.name];
    [html appendFormat:@"<tr><td>&nbsp;</td></tr>"];
    
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
    
    [html appendFormat:@"<tr><td><strong>All Sets</strong></td></tr>"];
    [html appendFormat:@"<tr><td><table>"];
    for (Set *set in [[self.card.printings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:YES]]])
    {
        Card *card = [[Database sharedInstance] findCard:self.card.name inSet:set.code];
        
        NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *image = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@/%@/%@/24.png\" border=\"0\" /></a>", link, setPath, set.code, [[Database sharedInstance] cardRarityIndex:card]];
        
        
        [html appendFormat:@"<tr><td>%@</td><td><a href=\"%@\">%@</a></td></tr>", image, link, set.name];
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
            
            [html appendFormat:@"<tr><td><a href=\"%@\"><img src=\"%@/%@/%@/24.png\" border=\"0\" /></a></td><td><a href=\"%@\">%@</a></td></tr>", link, setPath, card.set.code, [[Database sharedInstance] cardRarityIndex:card], link, card.name];
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
            
            [html appendFormat:@"<tr><td><a href=\"%@\"><img src=\"%@/%@/%@/24.png\" border=\"0\" /></a></td><td><a href=\"%@\">%@</a></td></tr>", link, setPath, card.set.code, [[Database sharedInstance] cardRarityIndex:card], link, card.name];
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
        NSString *pngFile;
        
        if ([noCurlies isEqualToString:@"100"])
        {
            pngFile = @"24.png";
        }
        else if ([noCurlies isEqualToString:@"1000000"])
        {
            pngFile = @"48.png";
        }
        else
        {
            pngFile = @"16.png";
        }
        
        for (NSString *mana in kManaSymbols)
        {
            if ([mana isEqualToString:noCurlies])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/%@/%@\"/>", [[NSBundle mainBundle] bundlePath], noCurlies, pngFile]];
                bFound = YES;
            }
            else if ([mana isEqualToString:noCurliesReverse])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/%@/%@\"/>", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngFile]];
                bFound = YES;
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/other/%@/%@\"/>", [[NSBundle mainBundle] bundlePath], noCurlies, pngFile]];
                }
                else if ([mana isEqualToString:noCurlies])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/other/%@/%@\"/>", [[NSBundle mainBundle] bundlePath], noCurliesReverse, pngFile]];
                }
            }
        }
    }
    
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * q = [[request URL] query];
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs)
    {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [kvPairs setObject:value forKey:key];
    }
    
    if ([kvPairs objectForKey:@"name"] && [kvPairs objectForKey:@"set"])
    {
    
        Card *card = [[Database sharedInstance] findCard:[kvPairs objectForKey:@"name"]
                                                   inSet:[kvPairs objectForKey:@"set"]];
    
        [self setCard:card];
        self.segmentedControl.selectedSegmentIndex = 0;
        [self switchView];
    }
    
    return YES;
}

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    [self displayCard];
}

#pragma mark -  MHFacebookImageViewerDatasource
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    return self.fetchedResultsController.fetchedObjects.count;
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [self setCard:card];
    [self displayCard];
    return [NSURL fileURLWithPath:[[FileManager sharedInstance] cardPath:self.card]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    _fbImageViewer = imageViewer;
    
    Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [self setCard:card];
    [self displayCard];
    return [UIImage imageWithContentsOfFile:[[FileManager sharedInstance] cardPath:self.card]];
}

@end
