//
//  BmobMsg.m
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobMsg.h"

#import "BmobIM.h"
@implementation BmobMsg


@synthesize belongAvatar;
@synthesize belongId;
@synthesize belongNick;
@synthesize belongUsername;
@synthesize content;
@synthesize conversationId;
@synthesize isReaded;
@synthesize msgTime;
@synthesize msgType;
@synthesize status;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//发送消息
+(instancetype)createSendMsgWithType:(NSInteger)type
                           receiptId:(NSString *)receiptId
                             content:(NSString *)content{
    
    BmobMsg *tmpMsg       = [[BmobMsg alloc] init];
    tmpMsg.msgType        = type;
    tmpMsg.content        = content;
    tmpMsg.conversationId = [NSString stringWithFormat:@"%@&%@",tmpMsg.belongId,receiptId];
    
    return tmpMsg;
}


//接收消息
+(instancetype)createReciveMsgWithType:(NSInteger)type
                            targerUser:(BmobChatUser *)targerUser
                               content:(NSString *)content{
    
    BmobMsg *tmpMsg       = [[BmobMsg alloc] init];
    tmpMsg.msgType        = type;
    tmpMsg.content        = content;
    tmpMsg.conversationId = [NSString stringWithFormat:@"%@&%@",targerUser.objectId,tmpMsg.belongId];
    tmpMsg.belongAvatar   = targerUser.avatar;
    tmpMsg.belongId       = targerUser.objectId;
    tmpMsg.belongNick     = targerUser.nick;
    tmpMsg.belongUsername = [targerUser objectForKey:@"username"];
    
    return tmpMsg;
}

+(instancetype)createAMessageWithType:(NSInteger)type statue:(NSInteger)statue content:(NSString *)content targetId:(NSString *)targetId{
    
    //当前用户
    BmobUser *user              = [BmobUser getCurrentUser];
    BmobMsg *tmpMsg             = [[BmobMsg alloc] init];
    tmpMsg.msgType              = type;
    tmpMsg.content              = content;
    tmpMsg.belongId             = user.objectId;
    tmpMsg.belongAvatar         = [user objectForKey:@"avatar"];
    tmpMsg.belongNick           = [user objectForKey:@"nick"];
    tmpMsg.belongUsername       = [user objectForKey:@"username"];
    tmpMsg.conversationId       = [NSString stringWithFormat:@"%@&%@",tmpMsg.belongId,targetId];
    tmpMsg.status               = statue;
    tmpMsg.isReaded             = STATE_UNREAD;
    NSString *currentTimeString = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    tmpMsg.msgTime              = currentTimeString;
    return tmpMsg;
}

//创建接收消息的BmobMsg对象
+(instancetype)createReceiveWithUser:(BmobChatUser *)user
                             content:(NSString *)content
                                toId:(NSString *)toId
                                time:(NSString *)time
                                type:(NSInteger)type
                              status:(NSInteger)status{
    
    BmobMsg *tmpMsg       = [[BmobMsg alloc] init];
    tmpMsg.toId = toId;
    tmpMsg.belongAvatar   = user.avatar;
    tmpMsg.belongId       = user.objectId;
    tmpMsg.belongNick     = user.nick;
    tmpMsg.belongUsername = user.username;
    tmpMsg.content        = content;
    tmpMsg.isReaded       = STATE_UNREAD;
    tmpMsg.conversationId = [NSString stringWithFormat:@"%@&%@",user.objectId,toId];
    tmpMsg.msgType        = type;
    tmpMsg.status         = status;
    tmpMsg.msgTime        = time;
    return tmpMsg;
}

@end
