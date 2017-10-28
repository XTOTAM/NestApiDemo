//
//  NAAuthManager.m
//  iNestApi
//
//  Created by XTOTAM on 10/25/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NAAuthManager.h"
#import "NADefine.h"
#import "NAAPIClient.h"
#import "MBProgressHUD.h"
#import "AccessToken.h"
#import "NAThermostatModel.h"

@implementation NAAuthManager {
    NAThermostatModel *thermModel;
}

+ (NAAuthManager *)sharedManager {
    static dispatch_once_t once;
    static NAAuthManager *instance;
    dispatch_once(&once, ^{
        instance = [[NAAuthManager alloc] init];
    });
    
    return instance;
}

#pragma mark -
#pragma mark - form URL

- (BOOL)isValidSession {
    if (thermModel.accessToken.length > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)authorizationURL {
    NSString *clientId = _productID;
    if (clientId) {
        return [NSString stringWithFormat:@"https://%@/login/oauth2?client_id=%@&state=%@", NestCurrentAPIDomain, clientId, NestState];
    } else {
        NSLog(@"Missing the Client ID");
        return nil;
    }
}

- (NSString *)deauthorizationURL {
    NSString *authBearer = [NSString stringWithFormat:@"%@",
                            [thermModel accessToken]];
    return [NSString stringWithFormat:@"https://api.%@/oauth2/access_tokens/%@", NestCurrentAPIDomain, authBearer];
}

- (NSString *)accessURLForAuthCod:(NSString *)authCode {
    NSString *clientId = _productID;
    NSString *clientSecret = _ProductSecret;
    NSString *authorizationCode = authCode;

    if (clientId && clientSecret && authorizationCode) {
        return [NSString stringWithFormat:@"https://api.%@/oauth2/access_token?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code", NestCurrentAPIDomain, authorizationCode, clientId, clientSecret];
    } else {
        if (!clientSecret) {
            NSLog(@"Missing Client Secret");
        }
        if (!clientId) {
            NSLog(@"Missing Client ID");
        }
        if (!authorizationCode) {
            NSLog(@"Missing authorization code");
        }
        return nil;
    }
}

#pragma mark -
#pragma mark - logi API

- (void)exchangeCodeForToken:(NSString *)authorizationCode withComplition:(void(^)(BOOL isSucsses))complit {
    [MBProgressHUD show];
    [[NAAPIClient sharedInstance] exchangeCodeForToken:[self accessURLForAuthCod:authorizationCode]
                                           withSuccses:^(NSURLSessionDataTask *task, id responseObject) {
                                            long expiresIn = [[responseObject objectForKey:@"expires_in"] longValue];
                                            NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                               thermModel = [NAThermostatModel sharedManager];
                                               thermModel.expire = *(&(expiresIn));
                                           thermModel.accessToken = accessToken;
                                           [MBProgressHUD hide];
                                              complit(YES);
                                           } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
                                               [MBProgressHUD showModeText:[NSString stringWithFormat:@"%ld", (long)error.code]];
                                                  [MBProgressHUD hide];
                                               complit(NO);
                                           }];
}

#pragma mark -
#pragma mark - get thermostat data

-(void)getThermostatDataWithComplition:(void(^)(BOOL isSucsses))complit {
    [[NAAPIClient sharedInstance] getThermostatDataWithToken:thermModel.accessToken withSuccses:^(id responce) {
        if (nil != responce) {
            [thermModel parseThermostatData:responce withComplition:^{
                complit(YES);
            }];
        } else {
            complit(NO);
        }
    }];
}

#pragma mark -
#pragma mark - change thermostate value

-(void)changeThermostatValue:(NSDictionary *)value withComplit:(void(^)(id valueWasChange)) complit {
    [[NAAPIClient sharedInstance] changeValueWithParams:value
                                        forThermostatID:thermModel.thermostatId
                                             assesToken:thermModel.accessToken
                                            withSuccses:^(id responce) {
                                                if (nil != responce) {
                                                    complit(responce);
                                                } else {
                                                    complit(nil);
                                                }
                                            }];
}


#pragma mark -
#pragma mark - log Out

-(void)logOutwithComplit:(void(^)(BOOL valueWasChange)) complit {
    [[NAAPIClient sharedInstance] logOutwithSuccses:^(NSURLSessionDataTask *task, id responseObject) {
        complit(YES);
    } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
        complit(NO);
    }];
}

@end
