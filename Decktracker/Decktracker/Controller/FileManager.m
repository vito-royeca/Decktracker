//
//  FileManager.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

static FileManager *_me;

+(id) sharedInstance
{
    if (!_me)
    {
        _me = [[FileManager alloc] init];
    }
    
    return _me;
}

-(id) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

-(void) saveAdvanceQuery:(NSString*) name
             withFilters:(NSDictionary*) dictQuery
              andSorters:(NSDictionary*) dictSorter
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSString *fileName = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", name]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    
    NSArray *arrData = @[dictQuery, dictSorter];
    [arrData writeToFile:fileName atomically:YES];
}

-(NSArray*) findAdvanceSearchFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSMutableArray *arrSearchFiles = [[NSMutableArray alloc] init];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
    {
        if ([[[file lastPathComponent] pathExtension] isEqualToString:@"plist"])
        {
            NSString *key = [[file lastPathComponent] stringByDeletingPathExtension];
            NSString *value = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            
            [arrSearchFiles addObject:@{key : value}];
        }
    }
    
    return arrSearchFiles;
}

-(void) deleteAdvanceSearchFile:(NSString*) name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSString *file = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
}

@end
