//
//  BmobIMUtil.m
//  BmobIM
//
//  Created by Bmob on 14-7-11.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobIMUtil.h"
#import "BmobIMUrlRequest.h"
#import "BmobIMSaveMessage.h"
#import "BmobIM.h"

@implementation BmobIMUtil


#define ShortUrlString @"http://s.bmob.cn/create.php?url="

+(void)turnLongUrlToShortWithUrl:(NSString *)urlString
                           block:(void(^)(NSString *shortUrl))block{
    NSString *longUrlString = [NSString stringWithFormat:@"%@%@",ShortUrlString,urlString];
    BmobIMUrlRequest *request = [BmobIMUrlRequest requestWithUrl:[NSURL URLWithString:longUrlString]];
    [request setHttpMethod:@"GET"];
    [request startAsyncConnection];
    __weak BmobIMUrlRequest *tmpRequest = request;
    //成功
    [request setCompletionBlock:^{
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[tmpRequest responseData] options:NSJSONReadingMutableContainers error:nil];
        if (responseDic && [responseDic count] > 0) {
            if ([[responseDic objectForKey:@"r"] boolValue]) {
                NSString *tmpString = [NSString stringWithFormat:@"http://s.bmob.cn/%@",[responseDic objectForKey:@"d"]];
                if (block) {
                    block(tmpString);
                }
            }else{
                if (block) {
                    block(urlString);
                }
            }
        }else{
            if (block) {
                block(urlString);
            }
        }
    }];
    //失败
    [request setFailedBlock:^{
        if (block) {
            block(nil);
        }
    }];
}

//发送tag消息
+(void)pushTagMessageWithCurrentUser:(BmobChatUser *)user
                            targetId:(NSString*)targetId
                          targetUser:(BmobObject *)object
                          messageTag:(BmobIMMsgTag)tag
                        avatarString:(NSString *)avatar
                               block:(BmobBooleanResultBlock)block{
    BmobPush *push   = [BmobPush push];
    BmobQuery *query = [BmobInstallation query];
    if ([[[object objectForKey:@"deviceType"] description] isEqualToString:@"ios"]) {
        [query whereKeyExists:@"deviceToken"];
        [query whereKey:@"deviceToken" equalTo:[object objectForKey:@"installId"]];
    }else{
        [query whereKeyExists:@"installationId"];
        [query whereKey:@"installationId" equalTo:[object objectForKey:@"installId"]];
    }
    NSTimeInterval timeS = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:[NSNumber numberWithInteger:(NSInteger)timeS] forKey:PUSH_ADD_FROM_TIME];
    [dataDic setObject:user.username forKey:PUSH_ADD_FROM_NAME];
    [dataDic setObject:user.objectId forKey:PUSH_ADD_FROM_ID];
    [dataDic setObject:object.objectId forKey:PUSH_ADD_TO_ID];
    if ([user objectForKey:@"nick"]) {
        [dataDic setObject:[user objectForKey:@"nick"] forKey:PUSH_ADD_FROM_NICK];
    }
    if (avatar) {
        [dataDic setObject:avatar forKey:PUSH_ADD_FROM_AVATAR];
    }
    if (tag == TAG_ADD_AGREE) {
        [dataDic setObject:@{@"sound":@"",@"badge":@0,@"alert":[NSString stringWithFormat:@"%@同意添加好友",user.username ]} forKey:@"aps"];
        [dataDic setObject:@"agree" forKey:PUSH_KEY_TAG];
    }else if (TAG_ADD_CONTACT == tag){
        [dataDic setObject:@{@"sound":@"",@"badge":@0,@"alert":[NSString stringWithFormat:@"%@请求添加好友",user.username ]} forKey:@"aps"];
        [dataDic setObject:@"add" forKey:PUSH_KEY_TAG];
    }
    [push setData:dataDic];
    [push setQuery:query];
    [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (block) {
            block(isSuccessful,error);
        }
    }];
}

/**
 *  发送消息
 *
 *  @param user     聊天的对象
 *  @param msg      消息内容
 *  @param block    推送结果
 *  @param callback 是否需要推送
 */
+(void)pushContentMessageWithTargetUser:(BmobChatUser *)user
                                 message:(BmobMsg*)msg
                                   block:(BmobBooleanResultBlock)block
                            needCallback:(BOOL)callback{
    BmobDB *db = [BmobDB currentDatabase];
    [db saveMessage:msg];
    BmobQuery *query = [BmobQuery queryForUser];
    [query selectKeys:@[@"deviceType",@"installId"]];
    [query getObjectInBackgroundWithId:user.objectId block:^(BmobObject *object, NSError *error) {
        BmobQuery *pushQuery = [BmobInstallation query];
        if ([[[object objectForKey:@"deviceType"] description] isEqualToString:@"ios"]) {
            [pushQuery whereKeyExists:@"deviceToken"];
            [pushQuery whereKey:@"deviceToken" equalTo:[object objectForKey:@"installId"]];
        }else{
            [pushQuery whereKeyExists:@"installationId"];
            [pushQuery whereKey:@"installationId" equalTo:[object objectForKey:@"installId"]];
        }
        //推送
        BmobPush *push = [BmobPush push];
        //推送内容
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (msg.msgType == MessageTypeText) {
            [dic setObject:@{@"sound":@"",@"badge":@0,@"alert":@"[消息]"} forKey:@"aps"];
        }else if(msg.msgType == MessageTypeImage){
            [dic setObject:@{@"sound":@"",@"badge":@0,@"alert":@"[图片]"} forKey:@"aps"];
        }else if (msg.msgType == MessageTypeLocation){
            [dic setObject:@{@"sound":@"",@"badge":@0,@"alert":@"[位置]"} forKey:@"aps"];
        }else if (msg.msgType == MessageTypeVoice){
            [dic setObject:@{@"sound":@"",@"badge":@0,@"alert":@"[语音]"} forKey:@"aps"];
        }
        [dic setObject:@"" forKey:PUSH_KEY_TAG];
        if (msg.content) {
            [dic setObject:msg.content forKey:PUSH_KEY_CONTENT];
        }
        [dic setObject:msg.belongId forKey:PUSH_KEY_TARGETID];
        [dic setObject:object.objectId forKey:PUSH_KEY_TOID];
        [dic setObject:[NSNumber numberWithInteger:msg.msgType ] forKey:PUSH_KEY_MSGTYPE];
        if (msg.msgTime) {
            [dic setObject:msg.msgTime forKey:PUSH_KEY_MSGTIME];
        }
        [push setData:dic];
        [push setQuery:pushQuery];
        [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                
                BmobRecent *recent = [[BmobRecent alloc] init];
                recent.avatar      = user.avatar;
                recent.nick        = user.nick;
                recent.message     = msg.content;
                recent.targetId    = user.objectId;
                recent.targetName  = user.username;
                recent.type        = msg.msgType;
                recent.time        = [msg.msgTime integerValue];
                [db saveRecent:recent];
                //保存聊天信息到服务器
                [BmobIMSaveMessage saveMessage:msg resultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                }];
            }
            if (callback) {
                if (block) {
                    block(isSuccessful,error);
                }
            }
        }];
    }];
}

@end
