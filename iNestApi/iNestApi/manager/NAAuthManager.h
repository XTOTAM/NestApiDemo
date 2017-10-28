//
//  NAAuthManager.h
//  iNestApi
//
//  Created by XTOTAM on 10/25/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAAuthManager : NSObject

+(NAAuthManager *)sharedManager;

@property NSString *clientID;

#pragma mark -
#pragma mark - form URL

- (NSString *)authorizationURL;
- (NSString *)deauthorizationURL;
- (NSString *)accessURLForAuthCod:(NSString *)authCode;

- (BOOL)isValidSession;

#pragma mark -
#pragma mark - logi API

- (void)exchangeCodeForToken:(NSString *)authorizationCode withComplition:(void(^)(BOOL isSucsses))complit;

#pragma mark -
#pragma mark - get thermostat data

-(void)getThermostatDataWithComplition:(void(^)(BOOL isSucsses))complit;
#pragma mark -
#pragma mark - change thermostate value

-(void)changeThermostatValue:(NSDictionary *)value withComplit:(void(^)(id valueWasChange)) complit;
#pragma mark -
#pragma mark - log Out

-(void)logOutwithComplit:(void(^)(BOOL valueWasChange)) complit;

@end
