//
//  BmobChatManager.h
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobIM.h"
#import "BmobChatUser.h"
#import "BmobMsg.h"
#import <BmobSDK/Bmob.h>

@interface BmobChatManager : NSObject

/**
 *  初始化
 *
 *  @return BmobChatManager对象
 */
-(instancetype)init;

/**
 *  创建一个BmobChatManager对象
 *
 *  @return BmobChatManager对象
 */
+(instancetype)currentInstance;

/**
 *   保存收到的消息到本地
 *
 *  @param msg 接收到得消息
 */
-(void)saveReceiveMessageWithMessage:(BmobMsg*)msg;



/**
 *  给指定用户发送消息,默认推送成功之后存储消息到数据库（本地和Bmob）
 *
 *  @param user 当前的聊天用户
 *  @param msg  发送的消息内容
 */
-(void)sendMessageWithUser:(BmobChatUser *)user message:(BmobMsg*)msg;

/**
 *  给指定objectId的用户发送消息，提供推送回调操作
 *
 *  @param user  当前的聊天用户
 *  @param msg   消息实体
 *  @param block 推送成功与否的回调
 */
-(void)sendMessageWithUser:(BmobChatUser *)user message:(BmobMsg*)msg block:(BmobBooleanResultBlock)block;

/**
 *  给指定用户推送Tag标记的消息请提供回调操作：添加好友、添加好友请求已同意等类型的回执消息
 *
 *  @param tag       消息类型
 *  @param targetId 目标用户id
 *  @param block    推送成功与否的回调
 */
-(void)sendMessageWithTag:(BmobIMMsgTag)tag targetId:(NSString*)targetId block:(BmobBooleanResultBlock)block;

/**
 *  给指定用户发送图片消息，提供图片上传回调操作
 *
 *  @param imagePath 图片的连接地址
 *  @param chatUser  当前的聊天用户
 *  @param block     上传图片到Bmob的结果和错误信息
 */
-(void)sendImageMessageWithImagePath:(NSString *)imagePath user:(BmobChatUser *)chatUser block:(BmobBooleanResultBlock)block;


/**
 *  给指定用户发送语音消息，提供文件上传回调操作
 *
 *  @param voicePath 声音文件的地址
 *  @param time      语音文件的时间长度
 *  @param chatUser  当前的聊天用户
 *  @param block     上传语音到Bmob的结果和错误信息
 */
-(void)sendVoiceMessageWithVoicePath:(NSString *)voicePath
                                time:(NSUInteger)time
                                user:(BmobChatUser *)chatUser
                               block:(BmobBooleanResultBlock)block;

@end
