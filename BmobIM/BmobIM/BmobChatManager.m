//
//  BmobChatManager.m
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobChatManager.h"
#import "BmobUserManager.h"
#import <sqlite3.h>
#import "BmobIMUrlRequest.h"
#import "BmobIMUtil.h"


@implementation BmobChatManager

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)currentInstance{
    
    static BmobChatManager *chatManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       chatManager = [[BmobChatManager alloc] init];
    });

    return chatManager;
}


/**
 *   保存收到的消息到本地
 *
 *  @param msg 接收到得消息
 */
-(void)saveReceiveMessageWithMessage:(BmobMsg*)msg{
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        BmobUser *user = [BmobUser getCurrentUser];
        NSString *conversationId = [NSString stringWithFormat:@"%@&%@",msg.belongId,user.objectId];
        NSString *saveChatString = [NSString stringWithFormat:@"insert or replace into chat(conversationid,belongid,belongaccount,belongnick,belongavatar,msgtype,msgtime,content,isreaded,status) vvalues('%@','%@','%@','%@','%@',%ld, %ld,'%@',%ld,%ld)",conversationId,msg.belongId,msg.belongUsername,msg.belongNick,msg.belongAvatar,(long)msg.msgType,(long)[msg.msgTime integerValue],msg.content,(long)msg.isReaded,(long)msg.status];
        sqlite3_exec(db, [saveChatString UTF8String], NULL, NULL, NULL);
        NSString *saveRecentString = [NSString stringWithFormat:@"insert or replace into recent(recent_id,recent_username,recent_nick,recent_avatar,last_message,msgtype,msgtime) values('%@','%@','%@','%@','%@',%ld,%ld)",msg.belongId,msg.belongUsername,msg.belongNick,msg.belongAvatar,msg.content,(long)msg.msgType,(long)[msg.msgTime integerValue]];
        sqlite3_exec(db, [saveRecentString UTF8String], NULL, NULL, NULL);
    }
    sqlite3_close(db);
}



/**
 *  给指定用户发送消息,默认推送成功之后存储消息到数据库（本地和Bmob）
 *
 *  @param user 当前的聊天用户
 *  @param msg  发送的消息内容
 */
-(void)sendMessageWithUser:(BmobChatUser *)user message:(BmobMsg*)msg{
    
    [self sendMessageWithUser:user
                      message:msg
                        block:nil
                 needCallback:NO];

}

/**
 *  给指定objectId的用户发送消息，提供推送回调操作
 *
 *  @param user  当前的聊天用户
 *  @param msg   消息实体
 *  @param block 推送成功与否的回调
 */
-(void)sendMessageWithUser:(BmobChatUser *)user message:(BmobMsg*)msg block:(BmobBooleanResultBlock)block{
    [self sendMessageWithUser:user
                      message:msg
                        block:block
                 needCallback:YES];
}



-(void)sendMessageWithUser:(BmobChatUser *)user message:(BmobMsg*)msg block:(BmobBooleanResultBlock)block needCallback:(BOOL)callback{

    [BmobIMUtil pushContentMessageWithTargetUser:user
                                         message:msg
                                           block:block
                                    needCallback:callback];
    
}



/**
 *  给指定用户推送Tag标记的消息请提供回调操作：添加好友、添加好友请求已同意等类型的回执消息
 *
 *  @param tag       消息类型
 *  @param targetId 目标用户id
 *  @param block    推送成功与否的回调
 */
-(void)sendMessageWithTag:(BmobIMMsgTag)tag targetId:(NSString*)targetId block:(BmobBooleanResultBlock)block{
    
    if (tag == TAG_ADD_AGREE) {
        BmobChatUser *user      = [[BmobUserManager currentUserManager] currentUser];
        BmobQuery    *userQuery = [BmobQuery queryForUser];
        [userQuery getObjectInBackgroundWithId:targetId block:^(BmobObject *object, NSError *error) {
            if ([user objectForKey:@"avatar"]) {
                //长连接转短连接
                [BmobIMUtil turnLongUrlToShortWithUrl:[user objectForKey:@"avatar"] block:^(NSString *shortUrl) {
                    [BmobIMUtil pushTagMessageWithCurrentUser:user
                                                     targetId:targetId
                                                   targetUser:object
                                                   messageTag:TAG_ADD_AGREE
                                                 avatarString:shortUrl
                                                        block:^(BOOL isSuccessful, NSError *error) {
                                                            if (block) {
                                                                block(isSuccessful,error);
                                                            }
                                                        }];
                }];
            }else{
                [BmobIMUtil pushTagMessageWithCurrentUser:user
                                                 targetId:targetId
                                               targetUser:object
                                               messageTag:TAG_ADD_AGREE
                                             avatarString:nil
                                                    block:^(BOOL isSuccessful, NSError *error) {
                                                        if (block) {
                                                            block(isSuccessful,error);
                                                        }
                                                    }];
            }
            
            //同意后添加好友
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sqlite3 *db;
                if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
                    sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                    NSString *saveRecentString = [NSString stringWithFormat:@"insert or replace into recent(recent_id,recent_username,recent_nick,recent_avatar,last_message,msgtype,msgtime) values('%@','%@','%@','%@','%@',%d,%d)",targetId,[object objectForKey:@"username"],[object objectForKey:@"nick"],[object objectForKey:@"avatar"],@"你们已经是好友,可以进行聊天了",MessageTypeText,(int)time];
                    sqlite3_exec(db, [saveRecentString UTF8String], NULL, NULL, NULL);
                    NSString *saveString = [NSString stringWithFormat:@"insert or replace into friends(uid,username,nick,avatar) values('%@','%@','%@','%@')",targetId,[object objectForKey:@"username"],[object objectForKey:@"nick"],[object objectForKey:@"avatar"]];
                    sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
                    NSString *updateString = [NSString stringWithFormat:@"update tab_new_contacts set status = %d where fromid = '%@'",STATUS_ADD_AGREE,targetId];
                    sqlite3_exec(db, [updateString UTF8String], NULL, NULL, NULL);
                    sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
                }
                sqlite3_close(db);
            });
        }];
    }else if (tag == TAG_ADD_CONTACT) {
        BmobChatUser *user = [[BmobUserManager currentUserManager] currentUser];
        BmobQuery *userQuery = [BmobQuery queryForUser];
        [userQuery getObjectInBackgroundWithId:targetId block:^(BmobObject *object, NSError *error) {
            //存在头像
            if ([user objectForKey:@"avatar"]) {
                [BmobIMUtil turnLongUrlToShortWithUrl:[user objectForKey:@"avatar"] block:^(NSString *shortUrl) {
                    [BmobIMUtil pushTagMessageWithCurrentUser:user
                                                     targetId:targetId
                                                   targetUser:object
                                                   messageTag:TAG_ADD_CONTACT
                                                 avatarString:shortUrl
                                                        block:^(BOOL isSuccessful, NSError *error) {
                                                            if (block) {
                                                                block(isSuccessful,error);
                                                            }
                                                        }];
                }];
            }else{
                [BmobIMUtil pushTagMessageWithCurrentUser:user
                                                 targetId:targetId
                                               targetUser:object
                                               messageTag:TAG_ADD_CONTACT
                                             avatarString:nil
                                                    block:^(BOOL isSuccessful, NSError *error) {
                                                        if (block) {
                                                            block(isSuccessful,error);
                                                        }
                                                    }];
            }
        }];
    }
}

-(NSString *)databasePath{
    NSString *databaseName      =  [NSString stringWithFormat:@"%@.db",[[BmobUser getCurrentUser] objectId]];
    NSArray  *paths             =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry =  [paths objectAtIndex:0];
    NSString *path              =  [documentDirecotry stringByAppendingPathComponent:databaseName];
    return path;
}

-(NSString *)filePath{
    NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry =[paths objectAtIndex:0];
    return documentDirecotry;
}


-(void)sendImageMessageWithImagePath:(NSString *)imagePath user:(BmobChatUser *)chatUser block:(BmobBooleanResultBlock)block{
    
    BmobFile *imageFile = [[BmobFile alloc] initWithFilePath:imagePath];
    [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [BmobIMUtil turnLongUrlToShortWithUrl:imageFile.url block:^(NSString *shortUrl) {
                //构建BmobMsg对象
                BmobMsg *msg = [BmobMsg createAMessageWithType:MessageTypeImage statue:STATUS_SEND_SUCCESS content:imagePath targetId:chatUser.objectId];
                msg.content = shortUrl;
                [BmobIMUtil pushContentMessageWithTargetUser:chatUser
                                                     message:msg
                                                       block:nil
                                                needCallback:NO];
            }];
        }else{
            BmobMsg *msg       = [BmobMsg createAMessageWithType:MessageTypeImage statue:STATUS_SEND_FAIL content:imagePath targetId:chatUser.objectId];
            BmobDB *db         = [BmobDB currentDatabase];
            [db saveMessage:msg];
            BmobRecent *recent = [[BmobRecent alloc] init];
            recent.avatar      = chatUser.avatar;
            recent.nick        = chatUser.nick;
            recent.message     = @"[图片]";
            recent.targetId    = chatUser.objectId;
            recent.targetName  = chatUser.username;
            recent.type        = msg.msgType;
            recent.time        = [msg.msgTime integerValue];
            [db saveRecent:recent];
        }
        if (block) {
            block(isSuccessful,error);
        }
    }];
    
}

-(void)sendVoiceMessageWithVoicePath:(NSString *)voicePath
                                time:(NSUInteger)time
                                user:(BmobChatUser *)chatUser block:(BmobBooleanResultBlock)block{
    BmobFile *imageFile = [[BmobFile alloc] initWithFilePath:voicePath];
    [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [BmobIMUtil turnLongUrlToShortWithUrl:imageFile.url block:^(NSString *shortUrl) {
                //构建BmobMsg对象
                BmobMsg *msg = [BmobMsg createAMessageWithType:MessageTypeVoice statue:STATUS_SEND_SUCCESS content:voicePath targetId:chatUser.objectId];
                msg.content = [NSString stringWithFormat:@"%@&%lu" ,shortUrl,(unsigned long)time];
                [BmobIMUtil pushContentMessageWithTargetUser:chatUser
                                                     message:msg
                                                       block:nil
                                                needCallback:NO];
            }];
        }else{
            BmobMsg *msg       = [BmobMsg createAMessageWithType:MessageTypeImage statue:STATUS_SEND_FAIL content:voicePath targetId:chatUser.objectId];
            msg.content = [NSString stringWithFormat:@"%@&%lu" ,voicePath,(unsigned long)time];
            BmobDB *db         = [BmobDB currentDatabase];
            [db saveMessage:msg];
            BmobRecent *recent = [[BmobRecent alloc] init];
            recent.avatar      = chatUser.avatar;
            recent.nick        = chatUser.nick;
            recent.message     = @"[语音]";
            recent.targetId    = chatUser.objectId;
            recent.targetName  = chatUser.username;
            recent.type        = msg.msgType;
            recent.time        = [msg.msgTime integerValue];
            [db saveRecent:recent];
        }
        if (block) {
            block(isSuccessful,error);
        }
    }];
}


/**
 *  查找未读消息
 *
 *  @param uid  用户id
 *  @param block 返回的数组类型
 */
-(void)queryUnreadMessageFromServerWithUserId:(NSString *)uid block:(BmobObjectArrayResultBlock )block{
    BmobQuery *query = [BmobQuery queryWithClassName:@"BmobMsg"];
    query.limit = 1000;
    [query whereKey:@"isReaded" equalTo:@(STATE_UNREAD)];
    [query whereKey:@"toId" equalTo:uid];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (block) {
            block(array,error);
        }
    }];

}


/**
 *  把服务器上的数据设置为已读
 *
 *  @param msg <#msg description#>
 */
-(void)serverMarkAsReaded:(BmobMsg *)msg{
    if (msg.isReaded == STATE_READED) {
        return;
    }
    BmobQuery *query = [BmobQuery queryWithClassName:@"BmobMsg"];
    [query whereKey:@"msgTime" equalTo:msg.msgTime];
    [query whereKey:@"conversationId" equalTo:msg.conversationId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            [obj setObject:[NSNumber numberWithInt:STATE_READED] forKey:@"isReaded"];
            [obj updateInBackground];
        }
    }];
}

@end
