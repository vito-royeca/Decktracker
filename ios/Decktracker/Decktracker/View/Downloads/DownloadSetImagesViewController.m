//
//  DownloadSetImagesViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 10/6/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DownloadSetImagesViewController.h"

#import "FFCircularProgressView.h"

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation DownloadSetImagesViewController

@synthesize arrSets = _arrSets;
@synthesize tblSets = _tblSets;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height - dY - self.tabBarController.tabBar.frame.size.height;
    
    self.tblSets = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight) style:UITableViewStylePlain];
    self.tblSets.delegate = self;
    self.tblSets.dataSource = self;
//    [self.tblSets registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil]
//          forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tblSets];
    
    
    self.navigationItem.title = @"Download Set Images";
    
    self.arrSets = [DTSet MR_findAllSortedBy:@"name" ascending:YES];
    
#ifndef DEBUG
    // send the screen to Google Analytics
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) downloadSetImages:(id) sender
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
            
            UITapGestureRecognizer *tapee = (UITapGestureRecognizer*) sender;
            FFCircularProgressView *progressView = (FFCircularProgressView*) tapee.view;
            
            for (float i=0; i<1.1; i+=0.01F)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressView setProgress:i];
                });
                usleep(10000);
            }
            NSLog(@"%@ download finished.", [self.arrSets[progressView.tag] name]);
        });
    });
}

#pragma - mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FFCircularProgressView *progressView;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        progressView = [[FFCircularProgressView alloc] init];
        progressView.tag = indexPath.row;
        progressView.frame = CGRectMake(self.view.frame.size.width-40, 7, 30, 30);
        
        
        UITapGestureRecognizer *tappee = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(downloadSetImages:)];
        [progressView addGestureRecognizer:tappee];
        [cell.contentView addSubview:progressView];
    }
    else
    {
        for (UIView *view in [cell.contentView subviews])
        {
            if ([view isKindOfClass:[FFCircularProgressView class]])
            {
                progressView = (FFCircularProgressView*)view;
                break;
            }
        }
    }
    
    DTSet *set = self.arrSets[indexPath.row];
    NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/C/48.png", [[NSBundle mainBundle] bundlePath], set.code];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        cell.imageView.image = [UIImage imageNamed:@"blank.png"];
    }
    else
    {
        UIImage *imgSet = [[UIImage alloc] initWithContentsOfFile:path];
        cell.imageView.image = imgSet;
        
        // resize the image
        CGSize itemSize = CGSizeMake(imgSet.size.width/2, imgSet.size.height/2);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    cell.textLabel.text = set.name.length >= 25 ? [NSString stringWithFormat:@"%@...", [set.name substringToIndex:24]] : set.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Released: %@ (%@ cards)", [JJJUtil formatDate:set.releaseDate withFormat:@"YYYY-MM-dd"], set.numberOfCards];
    
    return cell;
}

@end
