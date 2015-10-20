//
//  BmobMsg.h
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobChatUser.h"



@interface BmobMsg : NSObject

/**
 *  消息发布者的头像
 */
@property (nonatomic,copy) NSString  *belongAvatar;

/**
 *  消息发布者的id
 */
@property (nonatomic,copy) NSString  *belongId;
/**
 *  消息发布者的昵称
 */
@property (nonatomic,copy) NSString  *belongNick;

/**
 *  消息发布者的用户名
 */
@property (nonatomic,copy) NSString  *belongUsername;

/**
 *  消息的内容
 */
@property (nonatomic,copy) NSString  *content;

/**
 *  消息的会话id
 */
@property (nonatomic,copy) NSString  *conversationId;

/**
 *  消息是否已读
 */
@property (assign        ) NSInteger isReaded;

/**
 *  消息的时间
 */
@property (nonatomic,copy) NSString  *msgTime;

/**
 *  消息类型
 */
@property (assign        ) NSInteger msgType;

/**
 *  消息状态
 */
@property (assign        ) NSInteger status;

/**
 *  创建消息对象
 *
 *  @param type     类型
 *  @param statue   状态
 *  @param content  内容
 *  @param targetId 接收方
 *
 *  @return 发送的消息体
 */
+(instancetype)createAMessageWithType:(NSInteger)type
                               statue:(NSInteger)statue
                              content:(NSString *)content
                             targetId:(NSString *)targetId;

/**
 *  创建接收消息的对象
 *
 *  @param user    当前的聊天对象
 *  @param content 消息内容
 *  @param toId    消息的toId
 *  @param time    消息时间
 *  @param type    消息类型
 *  @param status  状态
 *
 *  @return BmobMsg对象
 */
+(instancetype)createReceiveWithUser:(BmobChatUser *)user
                             content:(NSString *)content
                                toId:(NSString *)toId
                                time:(NSString *)time
                                type:(NSInteger)type
                              status:(NSInteger)status;

@end
