//
//  BmobIMSaveMessage.m
//  BmobIM
//
//  Created by Bmob on 14-7-1.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobIMSaveMessage.h"

@implementation BmobIMSaveMessage


+(void)saveMessage:(BmobMsg *)msg resultBlock:(BmobBooleanResultBlock)block{

    //保存聊天信息到服务器
    BmobObject *msgObj = [[BmobObject alloc] initWithClassName:@"BmobMsg"];
    [msgObj setObject:msg.conversationId forKey:@"conversationId"];
    [msgObj setObject:msg.belongUsername forKey:@"belongusername"];
    [msgObj setObject:msg.content forKey:@"content"];
    [msgObj setObject:[NSNumber numberWithInteger:msg.isReaded ] forKey:@"isRead"];
    [msgObj setObject:[NSNumber numberWithInteger:msg.msgType] forKey:@"msgType"];
    [msgObj setObject:msg.msgTime forKey:@"msgTime"];
    [msgObj setObject:msg.belongId forKey:@"belongId"];
    [msgObj setObject:msg.belongNick forKey:@"belongNick"];
    [msgObj setObject:[NSNumber numberWithInteger:msg.status] forKey:@"status"];
    
    [msgObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (block) {
            block(isSuccessful,error);
        }
        
    }];
}

@end
