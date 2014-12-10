//
//  main.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "ImageLoader.h"
#import "JSONLoader.h"
#import "RulesLoader.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        JSONLoader *jsonLoader = [[JSONLoader alloc] init];
//        [jsonLoader parseCards1stPass];
//        [jsonLoader parseCards2ndPass];
        [jsonLoader fetchTcgPrices];

//        RulesLoader *rulesLoader = [[RulesLoader alloc] init];
//        [rulesLoader parseRules];

//        ImageLoader *imageLoader = [[ImageLoader alloc] init];
//        [imageLoader downloadSets:@[@"C14"]];
//        [imageLoader downloadSymbols];
//        [imageLoader downloadOtherSymbols];
    }
    return 0;
}

