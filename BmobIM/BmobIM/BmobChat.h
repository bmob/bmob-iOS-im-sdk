//
//  BmobChat.h
//  BmobIM
//
//  Created by Bmob on 14-6-19.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BmobChat : NSObject

/**
 *  注册应用
 *
 *  @param appkey Bmob提供的ApplicationID
 */
+(void)registerAppWithAppKey:(NSString*)appkey;

/**
 *  向installation表注册设备
 *
 *  @param deviceToken 设备的DeviceToken
 */
+(void)regisetDeviceWithDeviceToken:(NSData*)deviceToken;

@end
