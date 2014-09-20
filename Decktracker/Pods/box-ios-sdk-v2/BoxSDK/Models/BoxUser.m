//
//  BoxUser.m
//  BoxSDK
//
//  Created on 3/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxUser.h"

#import "BoxCollection.h"
#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxUser

- (NSString *)name
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyName
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSString *)login
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyLogin
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSDate *)createdAt
{
    NSString *timestamp = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyCreatedAt
                                                     inDictionary:self.rawResponseJSON
                                                  hasExpectedType:[NSString class]
                                                      nullAllowed:NO];
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)modifiedAt
{
    NSString *timestamp = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyModifiedAt
                                                     inDictionary:self.rawResponseJSON
                                                  hasExpectedType:[NSString class]
                                                      nullAllowed:NO];
    return [self dateWithISO8601String:timestamp];
}

- (NSString *)role
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyRole
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSString *)language
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyLanguage
                                                     inDictionary:self.rawResponseJSON
                                                  hasExpectedType:[NSString class]
                                                      nullAllowed:NO];
}

- (NSNumber *)spaceAmount
{
    NSNumber *spaceAmount = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeySpaceAmount
                                                       inDictionary:self.rawResponseJSON
                                                    hasExpectedType:[NSNumber class]
                                                        nullAllowed:NO];
    if (spaceAmount != nil)
    {
        spaceAmount = [NSNumber numberWithDouble:[spaceAmount doubleValue]];
    }
    return spaceAmount;
}

- (NSNumber *)spaceUsed
{
    NSNumber *spaceUsed = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeySpaceUsed
                                                     inDictionary:self.rawResponseJSON
                                                  hasExpectedType:[NSNumber class]
                                                      nullAllowed:NO];
    if (spaceUsed != nil)
    {
        spaceUsed = [NSNumber numberWithDouble:[spaceUsed doubleValue]];
    }
    return spaceUsed;
}

- (NSNumber *)maxUploadSize
{
    NSNumber *maxUploadSize = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyMaxUploadSize
                                                         inDictionary:self.rawResponseJSON
                                                      hasExpectedType:[NSNumber class]
                                                          nullAllowed:NO];
    if (maxUploadSize != nil)
    {
        maxUploadSize = [NSNumber numberWithDouble:[maxUploadSize doubleValue]];
    }
    return maxUploadSize;
}

- (id)trackingCodes
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyTrackingCodes
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSDictionary class]
                                       nullAllowed:NO];
}

- (NSNumber *)canSeeManagedUsers
{
    NSNumber *canSeeManagedUsers = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyCanSeeManagedUsers
                                                              inDictionary:self.rawResponseJSON
                                                           hasExpectedType:[NSNumber class]
                                                               nullAllowed:NO];
    if (canSeeManagedUsers != nil)
    {
        canSeeManagedUsers = [NSNumber numberWithBool:[canSeeManagedUsers boolValue]];
    }
    return canSeeManagedUsers;
}

- (NSNumber *) isSyncEnabled
{
    NSNumber *isSyncEnabled = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsSyncEnabled
                                                         inDictionary:self.rawResponseJSON
                                                      hasExpectedType:[NSNumber class]
                                                          nullAllowed:NO];
    if (isSyncEnabled != nil)
    {
        isSyncEnabled = [NSNumber numberWithBool:[isSyncEnabled boolValue]];
    }
    return isSyncEnabled;
}

- (NSString *) status
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyStatus
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSString *) jobTitle
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyJobTitle
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSString *)phone
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyPhone
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSString *)address
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyAddress
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSURL *)avatarURL
{
    NSString *avatarURLStr = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyAvatarURL
                                                     inDictionary:self.rawResponseJSON
                                                  hasExpectedType:[NSString class]
                                                      nullAllowed:NO];
    NSURL *avatarURL = nil;
    
    if (avatarURLStr != nil)
    {
        avatarURL = [NSURL URLWithString:avatarURLStr];
    }
    
    return avatarURL;
}

- (NSNumber *)isExemptFromDeviceLimits
{
    NSNumber *isExemptFromDeviceLimits = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsExemptFromDeviceLimits
                                                                    inDictionary:self.rawResponseJSON
                                                                 hasExpectedType:[NSNumber class]
                                                                     nullAllowed:NO];
    if (isExemptFromDeviceLimits != nil)
    {
        isExemptFromDeviceLimits = [NSNumber numberWithBool:[isExemptFromDeviceLimits boolValue]];
    }
    return isExemptFromDeviceLimits;
}

- (NSNumber *)isExemptFromLoginVerification
{
    NSNumber *isExemptFromLoginVerification = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsExemptFromLoginVerification
                                                                         inDictionary:self.rawResponseJSON
                                                                      hasExpectedType:[NSNumber class]
                                                                          nullAllowed:NO];
    if (isExemptFromLoginVerification != nil)
    {
        isExemptFromLoginVerification = [NSNumber numberWithBool:[isExemptFromLoginVerification boolValue]];
    }
    return isExemptFromLoginVerification;
}

- (NSNumber *)isDeactivated
{
    NSNumber *isDeactivated = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsDeactivated
                                                         inDictionary:self.rawResponseJSON
                                                      hasExpectedType:[NSNumber class]
                                                          nullAllowed:NO];
    if (isDeactivated != nil)
    {
        isDeactivated = [NSNumber numberWithBool:[isDeactivated boolValue]];
    }
    return isDeactivated;
}

- (NSNumber *)isPasswordResetRequired
{
    NSNumber *isPasswordResetRequired = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsPasswordResetRequired
                                                                   inDictionary:self.rawResponseJSON
                                                                hasExpectedType:[NSNumber class]
                                                                    nullAllowed:NO];
    if (isPasswordResetRequired != nil)
    {
        isPasswordResetRequired = [NSNumber numberWithBool:[isPasswordResetRequired boolValue]];
    }
    return isPasswordResetRequired;
}

- (NSString *)deactivatedReason
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyRole
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

- (NSNumber *)hasCustomAvatar
{
    NSNumber *hasCustomAvatar = [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeyIsPasswordResetRequired
                                                           inDictionary:self.rawResponseJSON
                                                        hasExpectedType:[NSNumber class]
                                                            nullAllowed:NO];
    if (hasCustomAvatar != nil)
    {
        hasCustomAvatar = [NSNumber numberWithBool:[hasCustomAvatar boolValue]];
    }
    return hasCustomAvatar;
}

@end
