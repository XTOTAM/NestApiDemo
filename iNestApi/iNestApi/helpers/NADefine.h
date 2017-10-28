//
//  NADefine.h
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#ifndef NADefine_h
#define NADefine_h

#define _baseURL  @"https://developer-api.nest.com/"
#define _loginBaseURL  @"https://api.home.nest.com/oauth2/access_token"
#define _thermostatURL @"https://developer-api.nest.com/devices/thermostats/"
#define NestCurrentAPIDomain  @"home.nest.com"
#define NestState  @"STATE"

#define _productID  @"e8ccc3a4-7e73-4d6a-8145-1fe4f926f932"
#define _ProductSecret  @"8oZJ13syqfNmCetMuvjwe4Lfx"

typedef NS_ENUM(NSInteger, CHANGED_VALUE_TAG){
    TAG_CAN_COOL = 1,
    TAG_CAN_HEAT,
    TAG_HVAC_STATE,
    TAG_HAS_FAN,
    TAG_HAS_LEAF,
    TAG_TARGET_F,
    TAG_AMBIENT_F,
    TAG_NAME_LONG,
    TAG_FAN_TIMER_ACTIVE_F,
    TAG_HVAC_MODE,
};

#endif /* NADefine_h */
