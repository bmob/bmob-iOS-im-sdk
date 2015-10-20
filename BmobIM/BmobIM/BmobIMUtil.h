//
//  BmobIMUtil.h
//  BmobIM
//
//  Created by Bmob on 14-7-11.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobChatUser.h"
#import "BmobIM.h"

@interface BmobIMUtil : NSObject

/**
 *  长连接变短连接
 *
 *  @param urlString 源地址
 *  @param block     短地址
 */
+(void)turnLongUrlToShortWithUrl:(NSString *)urlString
                           block:(void(^)(NSString *shortUrl))block;


/**
 *  推送添加好友、同意添加好友
 *
 *  @param user     当前用户
 *  @param targetId 目标用户id
 *  @param object   目标object
 *  @param tag      添加好友，同意添加好友的tag
 *  @param avatar   头像
 *  @param block    推送结果
 */
+(void)pushTagMessageWithCurrentUser:(BmobChatUser *)user
                  targetId:(NSString*)targetId
                targetUser:(BmobObject *)object
                messageTag:(BmobIMMsgTag)tag
              avatarString:(NSString *)avatar
                     block:(BmobBooleanResultBlock)block;


/**
 *  推送内容类型消息
 *
 *  @param user     聊天对象
 *  @param msg      消息
 *  @param block    推送结果
 *  @param callback 是否需要返回
 */
+(void)pushContentMessageWithTargetUser:(BmobChatUser *)user
                                 message:(BmobMsg*)msg
                                   block:(BmobBooleanResultBlock)block
                            needCallback:(BOOL)callback;

@end
