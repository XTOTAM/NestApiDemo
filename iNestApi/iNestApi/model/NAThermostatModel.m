//
//  NAThermostatModel.m
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NAThermostatModel.h"
#import "NADefine.h"

@implementation NAThermostatModel

static NAThermostatModel *__sharedInstance;


+(NAThermostatModel *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[NAThermostatModel alloc] init];
    });
    return __sharedInstance;
}

-(void)parseThermostatData:(NSDictionary *)data withComplition:(void(^)(void))complit {
    NSDictionary *dictResponce = [[data objectForKey:@"devices"] objectForKey:@"thermostats"];
    NSString *device_id = [[dictResponce allKeys] firstObject];
    
    NSDictionary *dict = [dictResponce objectForKey:device_id];
    
    self.thermostatId = device_id;
    self.ambientTemperatureF = [[dict valueForKey:@"ambient_temperature_f"] integerValue];
    self.targetTemperatureF = [[dict valueForKey:@"target_temperature_f"] integerValue];
    self.nameLong = [dict objectForKey:@"name_long"];
    self.hasFan = [[dict objectForKey:@"has_fan"] boolValue];
    self.fanTimerActive = [[dict objectForKey:@"fan_timer_active"] boolValue];
    self.hvacMode = [dict objectForKey:@"hvac_mode"];
    
    self.canCool = [[dict objectForKey:@"can_cool"] boolValue];
    self.canHeat = [[dict objectForKey:@"can_heat"] boolValue];
    self.hvacState = [[dict objectForKey:@"hvac_state"] boolValue];
    self.hasLeafe = [[dict objectForKey:@"has_leaf"] boolValue];
    self.humidity = [[dict objectForKey:@"humidity"] integerValue];
    
    complit();
}

+(void)updateModelForResponce:(id)responce {
    NSString * key = [[responce allKeys] firstObject];
    switch ([NAThermostatModel getTagByKey:key]) {
        case TAG_AMBIENT_F:
            [NAThermostatModel sharedManager].ambientTemperatureF = [[responce valueForKey:key] integerValue];
            break;
        case TAG_TARGET_F:
            [NAThermostatModel sharedManager].targetTemperatureF = [[responce valueForKey:key] integerValue];
            break;
        default:
            break;
    }
}

+(int)getTagByKey:(NSString *)key {
    if ([key isEqualToString:@"ambient_temperature_f"]){
        return TAG_AMBIENT_F;
    }
    if ([key isEqualToString:@"target_temperature_f"]){
        return TAG_TARGET_F;
    }
    return 0;
}

@end
//devices =     {
//    thermostats =         {
//        "bl0OagSb4W854scztJsNO-bYh0O0iT52" =             {
//            "ambient_temperature_c" = "37.5";
//            "ambient_temperature_f" = 100;
//            "away_temperature_high_c" = 24;
//            "away_temperature_high_f" = 76;
//            "away_temperature_low_c" = "12.5";
//            "away_temperature_low_f" = 55;
//            "can_cool" = 1;
//            "can_heat" = 1;
//            "device_id" = "bl0OagSb4W854scztJsNO-bYh0O0iT52";
//            "eco_temperature_high_c" = 24;
//            "eco_temperature_high_f" = 76;
//            "eco_temperature_low_c" = "12.5";
//            "eco_temperature_low_f" = 55;
//            "fan_timer_active" = 0;
//            "fan_timer_duration" = 15;
//            "fan_timer_timeout" = "1970-01-01T00:00:00.000Z";
//            "has_fan" = 1;
//            "has_leaf" = 1;
//            humidity = 70;
//            "hvac_mode" = heat;
//            "hvac_state" = off;
//            "is_locked" = 0;
//            "is_online" = 1;
//            "is_using_emergency_heat" = 0;
//            label = 987F;
//            locale = "en-US";
//            "locked_temp_max_c" = 22;
//            "locked_temp_max_f" = 72;
//            "locked_temp_min_c" = 20;
//            "locked_temp_min_f" = 68;
//            name = "Guest House (987F)";
//            "name_long" = "Guest House Thermostat (987F)";
//            "previous_hvac_mode" = "";
//            "software_version" = "5.6.1";
//            "structure_id" = "TmPDDFY2eWeXFEFnsA74JJ6ElBqcOynd38va46ahEE-3pk0wcN2BVA";
//            "sunlight_correction_active" = 0;
//            "sunlight_correction_enabled" = 1;
//            "target_temperature_c" = "21.5";
//            "target_temperature_f" = 71;
//            "target_temperature_high_c" = 26;
//            "target_temperature_high_f" = 79;
//            "target_temperature_low_c" = 19;
//            "target_temperature_low_f" = 66;
//            "temperature_scale" = C;
//            "time_to_target" = "~0";
//            "time_to_target_training" = ready;
//            "where_id" = "VeTOyvXBxxAYEZL7cmK3_aWEB_Ju9mI_iDIjAWPA9IgfIWMnKwwA9A";
//            "where_name" = "Guest House";
//        };
//    };
//};
//metadata =     {
//    "access_token" = "c.B1y6dOWroXg0fjvQm4wde2NTtZ8YgCP3Yochh7uGZYYsKepZ9feoXB6WCAlaONfwzQ1lC3XBrR5zZ3EpsykIiX655LTumVjM1RdbXpqsmiUVmdRQYDowJM2Hg3VegLXJ7K7m0TYBhZ95vkEW";
//    "client_version" = 2;
//    "user_id" = "z.1.1.wuPUDuR7THQfcdLIS0OL6ZMP/a/lw1SWrW/cPiBnS5I=";
//};

