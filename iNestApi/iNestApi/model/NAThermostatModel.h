//
//  NAThermostatModel.h
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NAThermostatModel : NSObject                                                        

+(NAThermostatModel *)sharedManager;

@property NSString  * accessToken;
@property NSInteger   expire;
@property (nonatomic, strong) NSString *thermostatId;
@property (nonatomic, strong) NSString *nameLong;
@property (nonatomic, strong) NSString *hvacMode;


@property (nonatomic) NSInteger ambientTemperatureF;
@property (nonatomic) NSInteger targetTemperatureF;
@property (nonatomic) NSInteger humidity;

@property (nonatomic) BOOL hasFan;
@property (nonatomic) BOOL fanTimerActive;
@property (nonatomic) BOOL canCool;
@property (nonatomic) BOOL canHeat;
@property (nonatomic) BOOL hvacState;
@property (nonatomic) BOOL hasLeafe;

-(void)parseThermostatData:(NSDictionary *)data withComplition:(void(^)(void))complit;
+(void)updateModelForResponce:(id)responce;

@end

