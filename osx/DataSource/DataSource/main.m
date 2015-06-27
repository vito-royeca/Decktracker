//
//  main.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Database.h"
//#import "ImageLoader.h"
#import "JSONLoader.h"
#import "RulesLoader.h"

#import "JJJ/JJJ.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSDate *dateStart = [NSDate date];
        
        /* Step 1 */
//        JSONLoader *jsonLoader = [[JSONLoader alloc] init];
//        [jsonLoader json2Database];
        
        /* Step 2 */
        RulesLoader *rulesLoader = [[RulesLoader alloc] init];
        [rulesLoader json2Database];

        /* Optional */
//        ImageLoader *imageLoader = [[ImageLoader alloc] init];
//        [imageLoader downloadSetIcons:@[@"DDO"]];
//        [imageLoader downloadSymbols];
//        [imageLoader downloadOtherSymbols];
        
        [[Database sharedInstance] copyRealmDatabaseToHome];
//        [[Database sharedInstance] updateParseCards];
        
        NSDate *dateEnd = [NSDate date];
        NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
        NSLog(@"Started: %@", dateStart);
        NSLog(@"Ended: %@", dateEnd);
        NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
    }
    return 0;
}

