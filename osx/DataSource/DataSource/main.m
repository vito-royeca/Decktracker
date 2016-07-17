//
//  main.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//


#import <JJJUtils/JJJ.h>
#import "DataSource-Swift.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSDate *dateStart = [NSDate date];
        
        // Step 1
        JSONLoader *jsonLoader = [[JSONLoader alloc] init];
//        [jsonLoader json2Database];
        [jsonLoader updateCardNumbers];
        
        // Step 2
//        RulesLoader *rulesLoader = [[RulesLoader alloc] init];
//        [rulesLoader json2Database];

        // Step 3
//        [[Database sharedInstance] copyRealmDatabaseToHome];
        
        // Step 4: Parse Maintenance (Optional)
//        [[Database sharedInstance] setupParse:nil];
//        [[Database sharedInstance] setupDb];
//        [[Database sharedInstance] deleteDuplicateParseCards];
        
        NSDate *dateEnd = [NSDate date];
        NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
        NSLog(@"Started: %@", dateStart);
        NSLog(@"Ended: %@", dateEnd);
        NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
    }
    return 0;
}

