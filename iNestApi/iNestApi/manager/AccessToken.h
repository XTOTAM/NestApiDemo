//
//  AccessToken.h
//  iNestApi
//
//  Created by XTOTAM on 10/25/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic, strong) NSString *token;

- (BOOL)isValid;

+ (AccessToken *)tokenWithToken:(NSString *)token expiresIn:(long)expiration;

@end
