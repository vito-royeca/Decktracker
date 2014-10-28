//
//  main.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "ImageLoader.h"
#import "JSONLoader.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        JSONLoader *jsonLoader = [[JSONLoader alloc] init];
        [jsonLoader parseJSON];

//        ImageLoader *imageLoader = [[ImageLoader alloc] init];
//        [imageLoader downloadSets:@[@"8BS", @"9BS", @"MGB"]];
        
//        [imageLoader downloadSymbols];
//        [imageLoader downloadOtherSymbols];
    }
    return 0;
}

