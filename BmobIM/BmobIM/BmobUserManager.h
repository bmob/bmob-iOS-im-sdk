//
//  BmobUserManager.h
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>
#import "BmobIM.h"


@interface BmobUserManager : NSObject

/**
 *  单例模式创建BmobUserManager实例
 *
 *  @return BmobUserManager实例
 */
+(instancetype)currentUserManager;

/**
 *  发送添加好友请求之后的对方回应：默认添加成功之后会存储到本地好友数据库中
 *
 *  @param targetName 好友名
 *  @param block      列表
 */
-(void)addContactAfterAgreeWithUsername:(NSString*)targetName block:(BmobObjectArrayResultBlock)block;

/**
 *  同意对方的添加好友请求:此方法默认在添加成功之后：1、更新本地好友数据库，2、向请求方发生同意tag请求，3、保存该好友到本地好友库
 *
 *  @param message 邀请的信息
 *  @param block   更新状态是否成功
 */
-(void)agreeAddContactWithInvitation:(BmobInvitation*)message block:(BmobBooleanResultBlock)block;

/**
 *  绑定设备
 *
 *  @param deviceToken 设备的DeviceToken
 */
-(void)bindDeviceToken:(NSData*)deviceToken;

/**
 *  检测并绑定设备-用于每次登陆时候的检测操作：1、通知其他设备下线，2、若未绑定则用户与设备绑定
 *
 *  @param deviceToken 设备的DeviceToken
 */
-(void)checkAndBindDeviceToken:(NSData*)deviceToken;

/**
 *  删除指定联系人--不携带回调
 *
 *  @param targetId 指定联系人的id
 */
-(void)deleteContactWithUid:(NSString*)targetId;

/**
 *  删除指定联系人 默认成功之后删除本地好友、会话表、消息表中与目标用户有关的数据
 *
 *  @param targetId 指定联系人的id
 *  @param block    删除后的回调
 */
-(void)deleteContactWithUid:(NSString *)targetId block:(BmobBooleanResultBlock)block;

/**
 *   获取当前登陆用户对象
 *
 *  @return  当前登陆用户对象
 */
-(BmobChatUser*)currentUser;

/**
 *   登陆-默认登陆成功之后会检测当前账号是否绑定过设备
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param block    登陆的结果
 */
-(void)loginWithUsername:(NSString *)username password:(NSString*)password block:(BmobBooleanResultBlock)block;

/**
 *  退出登陆
 */
-(void)logout;

/**
 *  获取当前用户的好友列表 ,默认按照更新时间降序排列
 *
 *  @param block 当前用户的好友列表
 */
-(void)queryCurrentContactArray:(BmobObjectArrayResultBlock)block;

/**
 *   模糊查询指定名称的用户:默认过滤掉本人和好友
 *
 *  @param name  查询的名称
 *  @param block 查询的结果
 */
-(void)queryUserByName:(NSString*)name block:(BmobObjectArrayResultBlock)block;


/**
 *  查看附近的人总数
 *
 *  @param key      存放位置的列
 *  @param location 地理位置
 *  @param block    返回查询结果和错误信息
 */
-(void)countNearbyWithKey:(NSString *)key location:(BmobGeoPoint *)location block:(BmobIntegerResultBlock)block;

/**
 *  查看附近的人
 *
 *  @param key      存放位置的列
 *  @param location 地理位置
 *  @param page     页码，从0开始
 *  @param block    返回查询的数组和错误信息
 */
-(void)queryNearbyWithKey:(NSString *)key location:(BmobGeoPoint *)location page:(NSInteger)page block:(BmobObjectArrayResultBlock)block;

@end
