//
//  BmobChat.m
//  BmobIM
//
//  Created by Bmob on 14-6-19.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobChat.h"
#import <BmobSDK/Bmob.h>

@implementation BmobChat

+(void)registerAppWithAppKey:(NSString *)appkey{
    [Bmob registerWithAppKey:appkey];

}

+(void)regisetDeviceWithDeviceToken:(NSData *)deviceToken{
    BmobInstallation *installation = [BmobInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];

    [installation saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (!error) {
            
        }
    }];
}

@end
