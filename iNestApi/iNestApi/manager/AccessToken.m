//
//  AccessToken.m
//  iNestApi
//
//  Created by XTOTAM on 10/25/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "AccessToken.h"

@interface AccessToken () <NSCoding>

@property (nonatomic, strong) NSDate *expiresOn;

@end

@implementation AccessToken
- (BOOL)isValid
{
    if (self.token){
        if ([[NSDate date] compare:self.expiresOn] == NSOrderedAscending) {
            return YES;
        }
    }
    
    return NO;
}

/**
 * Sets the token and expiration date.
 * @param token The token string.
 * @param expiration The amount of time (in seconds) the token has until it expires.
 */
+ (AccessToken *)tokenWithToken:(NSString *)token expiresIn:(long)expiration;
{
    AccessToken *accessToken = [[AccessToken alloc] init];
    accessToken.token = token;
    accessToken.expiresOn = [[NSDate date] dateByAddingTimeInterval:expiration];
    return accessToken;
}

/**
 * Encode the access token.
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.expiresOn forKey:@"expiresOn"];
}

/**
 * Decode the access token.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.token = [decoder decodeObjectForKey:@"token"];
        self.expiresOn = [decoder decodeObjectForKey:@"expiresOn"];
    }
    return self;
}
@end
