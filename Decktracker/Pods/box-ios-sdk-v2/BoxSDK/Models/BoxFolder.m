//
//  BoxFolder.m
//  BoxSDK
//
//  Created on 3/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFolder.h"

#import "BoxCollection.h"
#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxFolder

- (id)folderUploadEmail
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyFolderUploadEmail
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSDictionary class]
                                       nullAllowed:YES];
}

- (BoxCollection *)itemCollection
{
    NSDictionary *itemCollectionJSON = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyItemCollection
                                                                  inDictionary:self.rawResponseJSON
                                                               hasExpectedType:[NSDictionary class]
                                                                   nullAllowed:NO];

    BoxCollection *itemCollection = nil;
    if (itemCollectionJSON != nil)
    {
        itemCollection = [[BoxCollection alloc] initWithResponseJSON:itemCollectionJSON mini:YES];
    }
    return itemCollection;
}

- (NSString *)syncState
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeySyncState
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

@end
