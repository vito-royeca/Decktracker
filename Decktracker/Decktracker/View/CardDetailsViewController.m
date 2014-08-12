//
//  CardDetailsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "CardDetailsViewController.h"

#import "JJJ/JJJUtil.h"
#import "Artist.h"
#import "CardRarity.h"
#import "Database.h"
#import "Magic.h"
#import "SearchViewController.h"
#import "Set.h"
#import "UIImage+Scale.h"

@implementation CardDetailsViewController
{
    NSString *_cardPath;
}

@synthesize card = _card;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize segmentedControl = _segmentedControl;
@synthesize webView = _webView;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void) setCard:(Card*) card
{
    _card = card;
    
    _cardPath = [NSString stringWithFormat:@"%@/images/card/%@/%@.jpg", [[NSBundle mainBundle] bundlePath], self.card.set.code, self.card.imageName];
}

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
                              action:@selector(switchView:)
                    forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentedControl];
    [self switchView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchView:(id) sender
{
    CGFloat dX = 10;
    CGFloat dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height +5;
    CGFloat dWidth = self.view.frame.size.width-20;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height -10;
    
    [self.webView removeFromSuperview];
    [self.tableView removeFromSuperview];
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
        {
            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)];
            self.webView.scalesPageToFit = YES;
            self.webView.delegate = self;
            UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
            UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
            rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.view addGestureRecognizer:rightSwipeGesture];
            [self.view addGestureRecognizer:leftSwipeGesture];
            
            [_webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGesture];
            [_webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:leftSwipeGesture];
            [self.view addSubview:self.webView];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:_cardPath])
            {
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.delegate = self;
                [hud showWhileExecuting:@selector(downloadCard) onTarget:self withObject:nil animated:NO];
            }
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
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            [self.view addSubview:self.tableView];
            break;
        }
    }
}

- (void) downloadCard
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", self.card.set.code]];
    _cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", self.card.name]];
    BOOL bFound = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        bFound = NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cardPath])
    {
        bFound = NO;
    }
    
    if (!bFound)
    {
        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.jpg", self.card.set.code, self.card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
        [JJJUtil downloadResource:url toPath:_cardPath];
    }
}

- (void) displayCard
{
    CGFloat dY = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height +5;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];

    dHeight -= 60;
    UIImage *cardImage = [[UIImage alloc] initWithContentsOfFile:_cardPath];
    CGFloat xDim = ((cardImage.size.width * dHeight) / cardImage.size.height);
    self.navigationItem.title = self.card.name;
    [self.webView loadHTMLString:[self composeCardImageWithWidth:xDim andHeight:dHeight andScale:dHeight/cardImage.size.height] baseURL:baseURL];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    SearchViewController *parent = [self.navigationController.viewControllers firstObject];
    parent.selectedIndex = [sectionInfo.objects indexOfObject:self.card];
}

-(void) handleSwipeGesture:(id) sender
{
    UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*) sender;
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

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
    [self displayCard];
}

#pragma - mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
	switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            rows = 3;
            break;
        }
        case 2:
        {
            break;
        }
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(UITableViewCell *)cell
           atIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 1:
        {
            break;
        }
        case 2:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}

- (NSString*) composeCardImageWithWidth:(CGFloat) width andHeight:(CGFloat) height andScale:(CGFloat) scale
{
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendFormat:@"<html><head><meta name=\"viewport\" content=\"initial-scale=%f,maximum-scale=10.0\"/><link rel=\"stylesheet\" type=\"text/css\" href=\"%@/style.css\"></head><body background=\"%@/images/Gray_Patterned_BG.jpg\">", scale, [[NSBundle mainBundle] bundlePath], [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<img src=\"%@\" border=\"0\" class=\"img_center\"/>", _cardPath];
    [html appendFormat:@"</table></body></html>"];
    
    return html;
}

- (NSString*) composeDetails
{
    NSMutableString *html = [[NSMutableString alloc] init];
    NSString *setPath = [NSString stringWithFormat:@"%@/images/set", [[NSBundle mainBundle] bundlePath]];
    NSString *manaPath = [NSString stringWithFormat:@"%@/images/mana", [[NSBundle mainBundle] bundlePath]];
    
    [html appendFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@/style.css\"></head><body>", [[NSBundle mainBundle] bundlePath]];
    [html appendFormat:@"<table>"];
    
    if (self.card.manaCost)
    {
        [html appendFormat:@"<tr><td colspan=\"2\"><strong>Mana Cost</strong></td></tr>"];
        [html appendFormat:@"<tr><td colspan=\"2\">%@</td></tr>", [self replaceSymbolsInText:self.card.manaCost]];
    }
    
    if (self.card.convertedManaCost)
    {
        [html appendFormat:@"<tr><td colspan=\"2\"><strong>Converted Mana Cost</strong></td></tr>"];
        [html appendFormat:@"<tr><td colspan=\"2\"><img src=\"%@/%@/16.png\" border=\"0\" /></td></tr>", manaPath, [self.card.convertedManaCost stringValue]];
    }
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Type</strong></td></tr>"];
    [html appendFormat:@"<tr><td colspan=\"2\">%@</td></tr>", self.card.type];
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Rarity</strong></td></tr>"];
    [html appendFormat:@"<tr><td><img src=\"%@/%@/%@/24.png\" border=\"0\" /></td><td>%@ - %@</td></tr>", setPath, self.card.set.code, [[self.card.rarity.name substringToIndex:1] uppercaseString], self.card.set.name, self.card.rarity.name];
    
    if (self.card.power || self.card.toughness)
    {
        [html appendFormat:@"<tr><td colspan=\"2\"><strong>Power/Toughness</strong></td></tr>"];
        [html appendFormat:@"<tr><td colspan=\"2\">%@/%@</td></tr>", self.card.power, self.card.toughness];
    }
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Oracle Text</strong></td></tr>"];
    [html appendFormat:@"<tr><td colspan=\"2\">%@</td></tr>", [self replaceSymbolsInText:self.card.text]];
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Original Text</v></td></tr>"];
    [html appendFormat:@"<tr><td colspan=\"2\">%@</td></tr>", [self replaceSymbolsInText:self.card.originalText]];
    
    if (self.card.flavor)
    {
        [html appendFormat:@"<tr><td colspan=\"2\"><strong>Flavor Text</strong></td></tr>"];
        [html appendFormat:@"<tr><td colspan=\"2\"><i>%@</i></td></tr>", self.card.flavor];
    }
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Artist</strong></td></tr>"];
    [html appendFormat:@"<tr><td colspan=\"2\">%@</td></tr>", self.card.artist.name];
    
    [html appendFormat:@"<tr><td colspan=\"2\"><strong>Sets</strong></td></tr>"];
    for (Set *set in [[self.card.printings allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:YES]]])
    {
        Card *card = [[Database sharedInstance] findCard:self.card.name inSet:set.code];
        
        NSString *link = [[NSString stringWithFormat:@"card?name=%@&set=%@", card.name, set.code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [html appendFormat:@"<tr><td><a href=\"%@\"><img src=\"%@/%@/%@/24.png\" border=\"0\" /></a></td><td><a href=\"%@\">%@</a></td></tr>", link, setPath, set.code, [[card.rarity.name substringToIndex:1] uppercaseString], link, set.name];
    }
    
    [html appendFormat:@"</table></body></html>"];
    return html;
}

-(NSString*) replaceSymbolsInText:(NSString*) text
{
    NSMutableArray *arrSymbols = [[NSMutableArray alloc] init];
    
    for (int i=0; i<text.length; i++)
    {
        if ([text characterAtIndex:i] == '{' &&
            [text characterAtIndex:i+2] == '}')
        {
            [arrSymbols addObject:[text substringWithRange:NSMakeRange(i, 3)]];
        }
    }
    
    for (NSString *symbol in arrSymbols)
    {
        NSString *center = [symbol substringWithRange:NSMakeRange(1, symbol.length-2)];
        BOOL bFound = NO;
        
        for (NSString *mana in kManaSymbols)
        {
            if ([mana isEqualToString:center])
            {
                text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/mana/%@/16.png\"/>", [[NSBundle mainBundle] bundlePath], center]];
                bFound = YES;
            }
        }
        
        if (!bFound)
        {
            for (NSString *mana in kOtherSymbols)
            {
                if ([mana isEqualToString:center])
                {
                    text = [text stringByReplacingOccurrencesOfString:symbol withString:[NSString stringWithFormat:@"<img src=\"%@/images/other/%@/16.png\"/>", [[NSBundle mainBundle] bundlePath], center]];
                }
            }
        }
    }
    
    return text;
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
        [self switchView:nil];
    }
    
    return YES;
}

@end
