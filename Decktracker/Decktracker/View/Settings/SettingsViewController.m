//
//  SettingsViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "SettingsViewController.h"

#import <Dropbox/DBAccountManager.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat dX = 10;
    CGFloat dY = 100;
    CGFloat dWidth = self.view.frame.size.width - 20;
    CGFloat dHeight = 30;
    
    UIBarButtonItem *btnDropBox = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropbox.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dropBoxTapped:)];
    self.navigationItem.rightBarButtonItem = btnDropBox;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dropBoxTapped:(id) sender
{
    [[DBAccountManager sharedManager] linkFromController:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
