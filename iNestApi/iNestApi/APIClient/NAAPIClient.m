//
//  NAAPIClient.m
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NAAPIClient.h"
#import "NADefine.h"
#import "NAAuthManager.h"
#import "NAThermostatModel.h"

@implementation NAAPIClient

static NAAPIClient *__sharedInstance;

+(NAAPIClient *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[NAAPIClient alloc] initWithBaseURL:[NSURL URLWithString:_baseURL]];
    });
    return __sharedInstance;
}

-(id)initWithBaseURL:(nullable NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
//        self.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        
//        [self.securityPolicy setAllowInvalidCertificates:YES];
//        [self.securityPolicy setValidatesDomainName:NO];
    }
    return self;
}

#pragma mark -
#pragma mark - InternetConnecting

-(BOOL)isConnectedInternet {
    if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWWAN ||
       [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi){
        return YES;
    }
    return NO;
}

-(void)stopMonitoringInternet {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

-(void)startMonitoringInternet {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"Online");
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                NSLog(@"No Internet connection");
        }
    }];
}

#pragma mark -
#pragma mark - login API
- (void)exchangeCodeForToken:(NSString *)assesURL
                       withSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
                       andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        NSLog(@"redirect URL from login - %@", request.URL);
        return request;
    }];
    [self POST:assesURL parameters:nil progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
           sucsess(task, responseObject);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"\n\noauth faild error.code = %zd %@\n",error.code,error.localizedDescription);
           faild(task, error);
           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       }];
}

#pragma mark -
#pragma mark - getthermostat data API

-(void)getThermostatDataWithToken:(NSString *)assesToken
                      withSuccses:(void (^) (id responce)) result {
    NSString * params = [NSString stringWithFormat:@"Bearer %@", assesToken];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:params forHTTPHeaderField:@"Authorization"];
    [self.requestSerializer setValue:@"en" forHTTPHeaderField:@"User-Agent"];
    NSString *ur = [NSString stringWithFormat:@"%@/devices?auth=%@",_baseURL, assesToken];
    
    [self getThermostatDataWithURL:ur withSuccses:^(NSURLSessionDataTask *task, id responseObject) {
        result(responseObject);
    } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
        result(nil);
    }];
}

-(void)getThermostatDataWithURL:(NSString *)url
                             withSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
                           andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild {

    [self GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        sucsess(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n\nget thermostat data faild error.code = %zd %@\n",error.code, error.localizedDescription);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 401) {
            [self getThermostatDataWithURL:response.URL.absoluteString withSuccses:^(NSURLSessionDataTask *task, id responseObject) {
                sucsess(task, responseObject);
            } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
                faild(task, error);
            }];
        } else {
            faild(task, error);
        }
    }];
}

#pragma mark -
#pragma mark - change thermostate value

-(void)changeValueWithParams:(NSDictionary *)params
             forThermostatID:(NSString *)thermostatID assesToken:(NSString *)token
                 withSuccses:(void (^) (id responce)) result {
    NSString *url = [NSString stringWithFormat:@"%@%@",_thermostatURL, thermostatID];
    NSString * bearer = [NSString stringWithFormat:@"Bearer %@", token];
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:bearer forHTTPHeaderField:@"Authorization"];
    [self.requestSerializer setValue:@"en" forHTTPHeaderField:@"User-Agent"];
    
    [self changeTermostatWithURL:url andParams:params withSuccses:^(NSURLSessionDataTask *task, id responseObject) {
        result(responseObject);
    } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
        result(nil);
    }];
}

-(void)changeTermostatWithURL:(NSString *)url andParams:(NSDictionary *)params
                  withSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
                andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild {
    
    [self PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"chanche data responce - %@", responseObject);
        sucsess(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n\nget thermostat data faild error.code = %zd %@\n",error.code, error.localizedDescription);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 401) {
            [self changeTermostatWithURL:response.URL.absoluteString andParams:params withSuccses:^(NSURLSessionDataTask *task, id responseObject) {
                sucsess(task, responseObject);
            } andWhithFaild:^(NSURLSessionDataTask *task, NSError *error) {
                faild(task, error);
            }];
        } else {
            faild(task, error);
        }
    }];
}

#pragma mark -
#pragma mark - log Out

-(void)logOutwithSuccses:(void (^) (NSURLSessionDataTask *task, id responseObject))sucsess
           andWhithFaild:(void (^) (NSURLSessionDataTask *task, NSError *error))faild {
    NSString *authBearer = [NSString stringWithFormat:@"%@",
                            [[NAThermostatModel sharedManager] accessToken]];
    
    NSString *url = [NSString stringWithFormat:@"https://api.home.nest.com/oauth2/devices?auth=%@", authBearer];
    
    [self DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        sucsess(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n\nget thermostat data faild error.code = %zd %@\n",error.code, error.localizedDescription);
         __unused NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        faild(task, error);
    }];
}
@end
