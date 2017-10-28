//
//  NAAPIClient.h
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface NAAPIClient : AFHTTPSessionManager

+(NAAPIClient *)sharedInstance;

#pragma mark -
#pragma mark - network status

-(BOOL)isConnectedInternet;
-(void)stopMonitoringInternet;
-(void)startMonitoringInternet;

#pragma mark -
#pragma mark - login API

- (void)exchangeCodeForToken:(NSString *)assesURL
                 withSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
               andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild;

#pragma mark -
#pragma mark - getthermostat data API

-(void)getThermostatDataWithToken:(NSString *)assesToken
                      withSuccses:(void (^) (id responce)) result;

#pragma mark -
#pragma mark - change thermostate value

-(void)changeValueWithParams:(NSDictionary *)params
             forThermostatID:(NSString *)thermostatID assesToken:(NSString *)token
                 withSuccses:(void (^) (id responce)) result;

#pragma mark -
#pragma mark - log Out

-(void)logOutwithSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
           andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild;
@end
