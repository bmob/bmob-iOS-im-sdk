//
//  BmobDB.m
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobDB.h"
#import <sqlite3.h>
//#import "sqlite3.h"

@interface BmobDB (){
    NSString         *_databaseName;
    
}

@end

@implementation BmobDB

-(instancetype)initWithDatabaseName:(NSString*)databaseName{
    self = [super init];
    if (self) {
        _databaseName = [databaseName copy ];
//        [self createDataBase];
    }
    return self;
}



+(instancetype)databaseWithName:(NSString*)databaseName{
    
    static  BmobDB *tmpDB = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        tmpDB  = [[BmobDB alloc] initWithDatabaseName:databaseName];
        
       
        
//    });
  
    return tmpDB;
}

+(instancetype)currentDatabase{
    
    NSString *username = [[BmobUser getCurrentUser] objectForKey:@"username"];
    
    
    
    NSString *databaseName = [NSString stringWithFormat:@"%@.db",username];
    
    return [self databaseWithName:databaseName];
}


-(NSString*)filePath{
    NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry =[paths objectAtIndex:0];
    return documentDirecotry;
}

-(NSString*)databasePath{
    NSString *path = [[self filePath] stringByAppendingPathComponent:_databaseName];
    return path;
};


#pragma mark util

-(void)createDataBase{

    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
        /*
         "_id";// 自增id
         "conversationid";// 会话id：单聊：fromObjectId+toObjectId  // 群聊：groudId
         "belongid";// 该消息是谁发送的：用于和当前登录用户做比较来区分发送/接收
         "belongaccount";// 消息发送者的账号
         "belongnick";// 消息发送者的昵称
         "belongavatar";// 消息发送者的头像
         "msgtype";// 该消息类型---暂时只有Text类型
         "msgtime";// 时间
         "content";// 消息内容
         "isreaded";// 读取状态：未读 // -0、已读状态-1
         "status";// 发送状态
         */
        //聊天消息内容
        NSString *createChatTableString   = [NSString stringWithFormat:@"create table if not exists chat(id integer primary key autoincrement,conversationid varchar(255),belongid varchar(255),belongaccount varchar(255),belongnick varchar(255),belongavatar text,msgtype integer,msgtime varchar(255),content text,isreaded integer default 0,status integer)"];
        
        sqlite3_exec(db, [createChatTableString UTF8String], NULL, NULL, NULL);
        
        
        /*
         recent_id                  对方id
         recent_username            对方的用户名
         recent_nick                对方的昵称
         recent_avatar              对方的头像
         last_message               最后的信息
         msgtype                    消息类型
         msgtime                    时间
         */
        //消息列表
        NSString *createRecentTableString = [NSString stringWithFormat:@"create table if not exists recent(id integer primary key autoincrement,recent_id varchar(255) unique,recent_username varchar(255),recent_nick varchar(255),recent_avatar text,last_message text,msgtype integer,msgtime varchar(255))"];
        sqlite3_exec(db, [createRecentTableString UTF8String], NULL, NULL, NULL);
        
        //好友请求
        NSString *createContactTableString = [NSString stringWithFormat:@"create table if not exists tab_new_contacts(id integer primary key autoincrement,fromid varchar(255) unique,fromname varchar(255),avatar text,fromnick varchar(255),fromtime varchar(255),status integer)"];
        sqlite3_exec(db, [createContactTableString UTF8String], NULL, NULL, NULL);
        
        //好友列表
        NSString *createFriendsTableString = [NSString stringWithFormat:@"create table if not exists friends(id integer primary key autoincrement,uid varchar(255) unique,username varchar(255),nick varchar(255),avatar text)"];
        sqlite3_exec(db, [createFriendsTableString UTF8String], NULL, NULL, NULL);

        sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
    }
    
    sqlite3_close(db);
}


#pragma mark --interface

/**
 *  数据库升级时,删除所有数据表 用于清空缓存操作--谨慎使用
 */
-(void)clearAllDBCache{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            
            sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
            
            //删除聊天表
            char *deleteChatTable   = "delete from chat";
            sqlite3_exec(db, deleteChatTable, NULL, NULL, NULL);
            //删除最近联系表
            char *deleteRecentTable = "delete from recent";
            sqlite3_exec(db, deleteRecentTable, NULL, NULL, NULL);
            //删除好友请求表
            char *deleteNewContact  = "delete from tab_new_contacts";
            sqlite3_exec(db, deleteNewContact, NULL, NULL, NULL);
            //删除好友列表
            char *deleteFriends     = "delete from friends";
            sqlite3_exec(db, deleteFriends, NULL, NULL, NULL);
            
            sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
            
        }
        
        sqlite3_close(db);
    });
    
}

/**
 *  删除所有的聊天记录-用于清除缓存操作
 */
-(void)deleteAllRecent{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            //删除聊天表
            char *deleteChatTable   = "delete from chat";
            sqlite3_exec(db, deleteChatTable, NULL, NULL, NULL);
            //删除最近联系表
            char *deleteRecentTable = "delete from recent";
            sqlite3_exec(db, deleteRecentTable, NULL, NULL, NULL);
            
        }
         sqlite3_close(db);
    });
}

/**
 *  删除一个联系人
 *
 *  @param uid 联系人的id
 */
-(void)deleteContactWithUid:(NSString*)uid{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            
            NSString *deleteContact = [NSString stringWithFormat:@"delete from friends where uid='%@' ;",uid];
            sqlite3_exec(db, [deleteContact UTF8String], NULL, NULL, NULL);
        }
        sqlite3_close(db);
    });
}

/**
 *  删除指定用户和指定时间的好友请求
 *
 *  @param uid  指定用户的id
 *  @param time 指定的时间
 */
-(void)deleteInviteMsgWithUid:(NSString*)uid time:(NSString*)time{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            NSString *deleteContact = [NSString stringWithFormat:@"delete from tab_new_contacts where fromid='%@' and fromtime='%@' ;",uid,time];
            sqlite3_exec(db, [deleteContact UTF8String], NULL, NULL, NULL);
        }
        sqlite3_close(db);
    });
}

/**
 *   删除指定会话id的所有消息 deleteMessages
 *
 *  @param toId  当前聊天的objectid
 */
-(void)deleteMessagesWithUid:(NSString*)toId{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            BmobUser *currentUser = [BmobUser getCurrentUser];
            NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,toId];
            NSString *conID1 = [NSString stringWithFormat:@"%@&%@",toId,currentUser.objectId];
            NSString *deleteContact = [NSString stringWithFormat:@"delete from chat where conversationid='%@' or conversationid='%@';",conID,conID1];
            sqlite3_exec(db, [deleteContact UTF8String], NULL, NULL, NULL);
        }
        sqlite3_close(db);
    });
}

/**
 *  删除与指定用户之间的会话记录
 *
 *  @param targertId 指定用户的Id
 */
-(void)deleteRecentWithUid:(NSString*)targertId{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            NSString *deleteOneRecent = [NSString stringWithFormat:@"delete from recent where recent_id = '%@'",targertId];
            sqlite3_exec(db, [deleteOneRecent UTF8String], NULL, NULL, NULL);
        }
        sqlite3_close(db);
    });
}

/**
 *  获取本地数据库中存储的好友列表
 *
 *  @return 好友列表
 */
-(NSArray*)contaclList{
    
    NSMutableArray *array = [NSMutableArray array];
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = @"select * from friends";
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                BmobChatUser *user       = [[BmobChatUser alloc] init];
                const char *uid          = (char *)sqlite3_column_text(statement, 1);
                if (uid) {
                    NSString *uidString      = [[NSString alloc] initWithUTF8String:uid];
                    user.objectId            = uidString;
                }
               
                const char *username     = (char*)sqlite3_column_text(statement, 2);
                if (username) {
                    NSString *usernameString = [[NSString alloc] initWithUTF8String:username];
                    user.username            = usernameString;
                }
                
                const char *nick         = (char*)sqlite3_column_text(statement, 3);
                if (nick) {
                    NSString *nickString     = [[NSString alloc] initWithUTF8String:nick];
                    user.nick                = nickString;
                }
                
                const char *avatar = (char *)sqlite3_column_text(statement, 4);
                if (avatar) {
                    NSString *avatarString = [[NSString alloc] initWithUTF8String:avatar];
                    user.avatar = avatarString;
                }
                
                [array addObject:user];
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return array;
}

/**
 *  查找指定聊天对象之间的未读消息数
 *
 *  @param toid 指定聊天对象的id
 *
 *  @return 未读消息数
 */
-(NSInteger)unreadCountWithUid:(NSString*)toId{
    
    NSInteger unread = 0;
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        BmobUser *currentUser = [BmobUser getCurrentUser];
        NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,toId];
        NSString *conID1 = [NSString stringWithFormat:@"%@&%@",toId,currentUser.objectId];
        
        NSString *queryString = [NSString stringWithFormat: @"select count(1) from chat where (conversationid = '%@' or conversationid = '%@') and  isreaded = %d",conID,conID1 ,STATE_UNREAD];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                unread = sqlite3_column_int(statement, 0);
                break;
            }
        }
    
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return unread;
}

/**
 *  是否有新添加好友的请求
 *
 *  @return 是否有新添加好友的请求
 */
-(BOOL)hasNewInvite{
    
    BOOL newInvite  = NO;
    NSInteger count = 0;
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat:@"select count(1) from tab_new_contacts where status='%d'",STATUS_ADD_NO_VALIDATION];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
                break;
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);

    if (count == 0) {
        newInvite = NO;
    }else{
        newInvite = YES;
    }
    
    return newInvite;
}

/**
 *  是否有未读的消息--针对所有用户
 *
 *  @return 未读的消息
 */
-(BOOL)hasUnreadMsg{
    
    NSInteger count = 0;
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat:@"select count(1) from chat where status='%d'",STATE_UNREAD];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
                break;
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    if (count == 0) {
        return NO;
    }else
        return YES;
}

/**
 *  查找好友资料
 *
 *  @param targetId 好友的id
 *
 *  @return BmobChatUser对象
 */
-(BmobChatUser *)queryUserWithUid:(NSString *)targetId{
    BmobChatUser *user = [[BmobChatUser alloc] init];
    user.objectId      = targetId;
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat:@"select * from friends  where uid = '%@'",targetId];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                const char * username = (char *)sqlite3_column_text(statement, 2);
                if (username) {
                    NSString *nameString = [[NSString alloc] initWithUTF8String:username];
                    user.username        = nameString;
                }
                const char *nick = (char *)sqlite3_column_text(statement, 3);
                if (nick) {
                    NSString *nickString = [[NSString alloc] initWithUTF8String:nick];
                    user.nick            = nickString;
                }
                const char * avatar = (char *)sqlite3_column_text(statement, 4);
                if (avatar) {
                    NSString *avatarString = [[NSString alloc] initWithUTF8String:avatar];
                    user.avatar            = avatarString;
                }
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    return user;
}

/**
 *   获取所有的好友请求数据-默认按照时间的先后顺序排列
 *
 *  @return 获取所有的好友请求数据
 */
-(NSArray*)queryBmobInviteList{
    
    NSMutableArray *array = [NSMutableArray array];
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat:@"select * from tab_new_contacts  order by id desc" ];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                BmobInvitation *invitation = [[BmobInvitation alloc] init];
                
                const char *fromId = (char *)sqlite3_column_text(statement, 1);
                if (fromId) {
                    NSString *fromIdString = [[NSString alloc] initWithUTF8String:fromId];
                    invitation.fromId = fromIdString;
                }
                
                const char *fromName = (char *)sqlite3_column_text(statement, 2);
                if (fromName) {
                    NSString *fromNameString = [[NSString alloc] initWithUTF8String:fromName];
                    invitation.fromname = fromNameString;
                }
                
                const char *avatar = (char *)sqlite3_column_text(statement, 3);
                if (avatar) {
                    NSString *avatarString = [[NSString alloc] initWithUTF8String:avatar];
                    invitation.avatar = avatarString;
                }
                
                const char * fromnick = (char *)sqlite3_column_text(statement, 4);
                if (fromnick) {
                    NSString *fromNickString = [[NSString alloc] initWithUTF8String:fromnick];
                    invitation.nick = fromNickString;
                }
                
                const char *fromtime = (char*)sqlite3_column_text(statement, 5);
                if (fromtime) {
                    NSString *fromTimeString = [[NSString alloc] initWithUTF8String:fromtime];
                    invitation.time = [fromTimeString integerValue];
                }
                
                int status = sqlite3_column_int(statement, 6);
                invitation.statue = status;
                
                
                [array addObject:invitation];
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return array;
    
   
}

/**
 *  查询该会话对象的聊天消息记录总数
 *
 *  @param toId 会话对象的Id
 *
 *  @return 该会话对象的聊天消息记录总数
 */
-(NSInteger)queryChatTotalCountWithUid:(NSString*)toId{
    
    NSInteger count = 0;
    
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        BmobUser *currentUser = [BmobUser getCurrentUser];
        NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,toId];
        NSString *conID1 = [NSString stringWithFormat:@"%@&%@",toId,currentUser.objectId];
        
        NSString *queryString = [NSString stringWithFormat: @"select count(1) from chat where conversationid = '%@' or conversationid = '%@'; ",conID,conID1];
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
                break;
            }
        }
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return count;
}

/**
 *  针对单聊 获取指定会话id的所有消息 findMessage，支持分页操作
 *
 *  @param toId 指定用户的id
 *  @param page 页码 0开始
 *
 *  @return 指定用户的消息
 */
-(NSArray*)queryMessagesWithUid:(NSString*)toId page:(int)page{
    
    if (page < 0) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    sqlite3 *db;
    sqlite3_stmt *statement;
    
    BmobUser *currentUser = [BmobUser getCurrentUser];
    NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,toId];
    NSString *conID1 = [NSString stringWithFormat:@"%@&%@",toId,currentUser.objectId];
    
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat: @"select * from chat where conversationid = '%@' or conversationid = '%@' order by id desc  limit %d ; ",conID,conID1,(page+1)*10];
       
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                BmobMsg *msg = [[BmobMsg alloc] init];
                
                const char *conversationid = (char *)sqlite3_column_text(statement, 1);
                if (conversationid) {
                    NSString *conversationIdString = [[NSString alloc] initWithUTF8String:conversationid];
                    msg.conversationId = conversationIdString;
                }
                const char *belongid = (char *)sqlite3_column_text(statement, 2);
                if (belongid) {
                    NSString *belongIdString = [[NSString alloc] initWithUTF8String:belongid];
                    msg.belongId = belongIdString;
                }
                const char *belongaccount = (char *)sqlite3_column_text(statement, 3);
                if (belongaccount) {
                    NSString *belongAccountString = [[NSString alloc] initWithUTF8String:belongaccount];
                    msg.belongUsername = belongAccountString;
                }
                const char *belongnick = (char*)sqlite3_column_text(statement, 4);
                if (belongnick) {
                    NSString *belongNickString = [[NSString alloc] initWithUTF8String:belongnick];
                    msg.belongNick = belongNickString;
                }
                const char *belongavatar = (char *)sqlite3_column_text(statement, 5);
                if (belongavatar) {
                    NSString *belongAvatarString = [[NSString alloc] initWithUTF8String:belongavatar];
                    msg.belongAvatar = belongAvatarString;
                }
                int msgType = sqlite3_column_int(statement, 6);
                if (msgType) {
                    msg.msgType = msgType;
                }
                const char *msgTime = (char *)sqlite3_column_text(statement, 7);
                if (msgTime) {
                    NSString *msgTimeString = [[NSString alloc] initWithUTF8String:msgTime];
                    msg.msgTime = msgTimeString;
                }
                const char *content = (char *)sqlite3_column_text(statement, 8);
                if (content) {
                    NSString *contentString = [[NSString alloc] initWithUTF8String:content];
                    msg.content =contentString;
                }
                
                int isreaded = sqlite3_column_int(statement, 9);
                msg.isReaded = isreaded;
                
                int status = sqlite3_column_int(statement, 10);
                msg.status = status;
                
                [array insertObject:msg atIndex:0];
                
                
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return array;
}

/**
 *  查询登陆用户所有会话列表
 *
 *  @return 查询登陆用户所有会话列表
 */
-(NSArray*)queryRecent{
    
    NSMutableArray *array = [NSMutableArray array];
    sqlite3 *db;
    sqlite3_stmt *statement;
    
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *queryString = @"select * from recent";
        if (sqlite3_prepare_v2(db, [queryString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                BmobRecent *recent = [[BmobRecent alloc] init];
                
                const char *recent_id = (char *)sqlite3_column_text(statement, 1);
                if (recent_id) {
                    NSString *targetId = [[NSString alloc] initWithUTF8String:recent_id];
                    recent.targetId = targetId;
                }
                
                const char *recent_username = (char *)sqlite3_column_text(statement, 2);
                if (recent_username) {
                    NSString *targetName = [[NSString alloc] initWithUTF8String:recent_username];
                    recent.targetName = targetName;
                }
                
                const char *recent_nick = (char *)sqlite3_column_text(statement, 3);
                if (recent_nick) {
                    NSString *nick = [[NSString alloc] initWithUTF8String:recent_nick];
                    recent.nick = nick;
                }
                
                const char *recent_avatar = (char *)sqlite3_column_text(statement, 4);
                if (recent_avatar) {
                    NSString *avatar = [[NSString alloc] initWithUTF8String:recent_avatar];
                    recent.avatar = avatar;
                }
                
                const char *last_message = (char *)sqlite3_column_text(statement, 5);
                if (last_message) {
                    NSString *message = [[NSString alloc] initWithUTF8String:last_message];
                    recent.message = message;
                }
                
                int msgtype = sqlite3_column_int(statement, 6);
                recent.type = msgtype;
                
                const char *time = (char *)sqlite3_column_text(statement, 7);
                if (time) {
                    NSString *timeString = [[NSString alloc] initWithUTF8String:time];
                    recent.time = [timeString integerValue];
                }
                
                [array addObject:recent];
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    return array;
}

/**
 *  重置未读消息
 *
 *  @param toId 指定用户的id
 */
-(void)resetUnreadWithUid:(NSString*)toId{
    
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        BmobUser *currentUser = [BmobUser getCurrentUser];
        NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,toId];
        NSString *conID1 = [NSString stringWithFormat:@"%@&%@",toId,currentUser.objectId];

        
        NSString *updateString = [NSString stringWithFormat:@"update chat set isreaded= %d where conversationid = '%@' or conversationid = '%@'",STATE_READED,conID,conID1];
        
        sqlite3_exec(db, [updateString UTF8String], NULL, NULL, NULL);
        
    }
    sqlite3_close(db);
    
    
}

/**
 *  保存好友
 *
 *  @param user 好友
 */
-(void)saveContactWithUser:(BmobChatUser*)user{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            
            NSString *saveString = [NSString stringWithFormat:@"insert or replace into friends(uid,username,nick,avatar) values('%@','%@','%@','%@')",user.objectId,user.username,user.nick,user.avatar];
            
            sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
            
        }
        sqlite3_close(db);
    });
    

    
    

}

/**
 *  保存好友
 *
 *  @param message 邀请的信息
 */
-(void)saveContactWithMessage:(BmobInvitation *)message{
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        NSString *saveString = [NSString stringWithFormat:@"insert or replace into friends(uid,username,nick,avatar) values('%@','%@','%@','%@')",message.fromId,message.fromname ,message.nick,message.avatar];
        
        sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
        
        NSString *saveRecentString = [NSString stringWithFormat:@"insert or replace into recent(recent_id,recent_username,recent_nick,recent_avatar,last_message,msgtype,msgtime) values('%@','%@','%@','%@','%@',%d,'%@')",message.fromId,message.fromname,message.nick,message.avatar,@"你们已经是好友,可以进行聊天了",1,[NSString stringWithFormat:@"%ld", (long)message.time]];
        
       
        sqlite3_exec(db, [saveRecentString UTF8String], NULL, NULL, NULL);
        
    }else{
        NSLog(@"can opent");
    }
    sqlite3_close(db);

}

/**
 *  保存好友请求
 *
 *  @param messages 邀请的信息
 */
-(void)saveInviteMessage:(BmobInvitation*)message{
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        NSString *saveString = [NSString stringWithFormat:@"insert or replace into tab_new_contacts(fromid,fromname,avatar,fromnick,fromtime,status) values('%@','%@','%@','%@','%@',%ld)",message.fromId,message.fromname ,message.avatar,message.nick,[NSString stringWithFormat:@"%ld", (long)message.time],(long)message.statue];
       
        
        sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
        
    }
    sqlite3_close(db);
}

/**
 *  保存聊天消息
 *
 *  @param message 聊天的信息
 */
-(void)saveMessage:(BmobMsg*)message{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            
            NSString *saveString = [NSString stringWithFormat:@"insert or replace into chat(conversationid,belongid,belongaccount,belongnick,belongavatar,msgtype,msgtime,content,isreaded,status) values('%@','%@','%@','%@','%@',%ld,'%@','%@',%ld,%ld)",message.conversationId,message.belongId,message.belongUsername,message.belongNick,message.belongAvatar,(long)message.msgType,message.msgTime,message.content,(long)message.isReaded,(long)message.status];
            sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
            
        }
        sqlite3_close(db);
//    });
}

/**
 *   保存或更新用户好友列表到本地数据
 *
 *  @param array BmobChatuser的数组
 */
-(void)saveOrCheckContactList:(NSArray*)array{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
            
            for (BmobChatUser *user  in array) {
                
                NSString *saveString = [NSString stringWithFormat:@"insert or replace into friends(uid,username,nick,avatar) values('%@','%@','%@','%@')",user.objectId,user.username,user.nick,user.avatar];
                
                sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
            }
            
            sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
        }
        sqlite3_close(db);
    });
    
    
}

/**
 *  保存本地会话
 *
 *  @param recent 会话
 */
-(void)saveRecent:(BmobRecent*)recent{
    
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *saveString = [NSString stringWithFormat:@"insert or replace into recent(recent_id,recent_username,recent_nick,recent_avatar,last_message,msgtype,msgtime) values('%@','%@','%@','%@','%@',%ld,'%@')",recent.targetId,recent.targetName,recent.nick,recent.avatar,recent.message,(long)recent.type,[NSString stringWithFormat:@"%ld", (long)recent.time ]];
        sqlite3_exec(db, [saveString UTF8String], NULL, NULL, NULL);
        
    }
    sqlite3_close(db);
}

/**
 *  更新来自指定用户的好友请求的状态
 *
 *  @param fromname 指定好友的用户名
 */
-(void)updateAgreeMessage:(NSString *)fromname{
    sqlite3 *db;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        
        NSString *updateString = [NSString stringWithFormat:@"update tab_new_contacts set status = %d where fromname = '%@'",STATUS_ADD_AGREE,fromname];
        
        sqlite3_exec(db, [updateString UTF8String], NULL, NULL, NULL);
        
    }
    sqlite3_close(db);
}

@end
