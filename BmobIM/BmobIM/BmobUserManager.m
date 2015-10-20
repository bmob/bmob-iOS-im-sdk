//
//  BmobUserManager.m
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobUserManager.h"
#import "BmobChatManager.h"
#import <sqlite3.h>

@implementation BmobUserManager


+(instancetype)currentUserManager{
    
    static BmobUserManager *userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userManager = [[BmobUserManager alloc] init];
    });
    
    return userManager;
}


/**
 *  发送添加好友请求之后的对方回应：默认添加成功之后会存储到本地好友数据库中
 *
 *  @param targetName 好友名
 *  @param block      列表
 */
-(void)addContactAfterAgreeWithUsername:(NSString*)targetName block:(BmobObjectArrayResultBlock)block{
    BmobQuery *query = [BmobQuery queryForUser];
    [query whereKey:@"username" equalTo:targetName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (block) {
            block(array,error);
        }
    }];
    
}
/**
 *  同意对方的添加好友请求:此方法默认在添加成功之后：1、更新本地好友数据库，2、向请求方发生同意tag请求，3、保存该好友到本地好友库
 *
 *  @param message 邀请的信息
 *  @param block   更新状态是否成功
 */
-(void)agreeAddContactWithInvitation:(BmobInvitation*)message block:(BmobBooleanResultBlock)block{
    

    
    BmobChatManager *chatManager = [BmobChatManager currentInstance];
    [chatManager sendMessageWithTag:TAG_ADD_AGREE targetId:message.fromId block:^(BOOL isSuccessful, NSError *error) {
        
        
        if (block) {
            block(isSuccessful,error);
        }
    }];
        

    BmobUser *tmpUser = [BmobUser objectWithoutDatatWithClassName:@"User" objectId:message.fromId];
    BmobRelation *relation = [BmobRelation relation];
    [relation addObject:tmpUser];
    
    BmobUser *currentUser = [BmobUser getCurrentUser];
    [currentUser addRelation:relation forKey:@"contacts"];
    [currentUser updateInBackground];
}
/**
 *  绑定设备
 *
 *  @param deviceToken 设备的DeviceToken
 */
-(void)bindDeviceToken:(NSData*)deviceToken{
    BmobUserManager *userManager = [BmobUserManager currentUserManager];
    BmobChatUser *user           = [userManager currentUser];
    NSString *deviceTokenString  = [self hexStringFromData:deviceToken];
    [user setObject:deviceTokenString forKey:@"installId"];
    [user setObject:@"ios" forKey:@"deviceType"];
    [user updateInBackground];
}

/**
 *  检测并绑定设备-用于每次登陆时候的检测操作：1、通知其他设备下线，2、若未绑定则用户与设备绑定
 *
 *  @param deviceToken 设备的DeviceToken
 */
-(void)checkAndBindDeviceToken:(NSData*)deviceToken{
    BmobUserManager *userManager = [BmobUserManager currentUserManager];
    BmobChatUser *user           = [userManager currentUser];
    NSString *deviceTokenString  = [self hexStringFromData:deviceToken];
    
   
    
    [user setObject:deviceTokenString forKey:@"installId"];
    [user setObject:@"ios" forKey:@"deviceType"];
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
       
    }];

    //绑定
    BmobQuery *bQuery = [BmobInstallation query];
    [bQuery whereKey:@"deviceToken" equalTo:deviceTokenString];
    [bQuery selectKeys:@[@"uid"]];
    [bQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        
        BmobInstallation *obj = [array firstObject];
        [obj setObject:user.username forKey:@"uid"];
        [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
           
        }];
    }];
    
    
    
    //通知其他设备下线
    BmobQuery *query = [BmobInstallation query];
    [query whereKey:@"uid" equalTo:user.username];
    [query whereKey:@"deviceToken" notEqualTo:deviceTokenString];
    
    NSDictionary *dataDic = @{@"tag":@"offline"};
    BmobPush *push = [BmobPush push];
    [push setQuery:query];
    [push setData:dataDic];
    [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
    
    }];
}

/**
 *  删除指定联系人--不携带回调
 *
 *  @param targetId 指定联系人的id
 */
-(void)deleteContactWithUid:(NSString*)targetId{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            NSString *deleteOneContactString = [NSString stringWithFormat:@"delete from friends where uid = '%@'",targetId];
            sqlite3_exec(db, [deleteOneContactString UTF8String], NULL, NULL, NULL);
            
            BmobUser *currentUser           = [BmobUser getCurrentUser];
            NSString *conID                 = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,targetId];
            NSString *conID1                = [NSString stringWithFormat:@"%@&%@",targetId,currentUser.objectId];

            NSString *deleteOneChatsString  = [NSString stringWithFormat:@"delete from chat  where conversationid = '%@' or conversationid = '%@'",conID,conID1];
            sqlite3_exec(db, [deleteOneChatsString UTF8String], NULL, NULL, NULL);

            NSString *deleteOneRecentString = [NSString stringWithFormat:@"delete from recent where uid = '%@'",targetId];
            sqlite3_exec(db, [deleteOneRecentString UTF8String], NULL, NULL, NULL);
            
        }
        sqlite3_close(db);
    });
    
    BmobUser *tmpUser      = [BmobUser objectWithoutDatatWithClassName:@"User" objectId:targetId];
    BmobRelation *relation = [BmobRelation relation];
    [relation removeObject:tmpUser];

    BmobUser *currentUser  = [BmobUser getCurrentUser];
    [currentUser addRelation:relation forKey:@"contacts"];
    [currentUser updateInBackground];
}

/**
 *  删除指定联系人 默认成功之后删除本地好友、会话表、消息表中与目标用户有关的数据
 *
 *  @param targetId 指定联系人的id
 *  @param block    删除后的回调
 */
-(void)deleteContactWithUid:(NSString *)targetId block:(BmobBooleanResultBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sqlite3 *db;
        if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
            NSString *deleteOneContactString = [NSString stringWithFormat:@"delete from friends where uid = '%@'",targetId];
            sqlite3_exec(db, [deleteOneContactString UTF8String], NULL, NULL, NULL);
            
            BmobUser *currentUser = [BmobUser getCurrentUser];
            NSString *conID  = [NSString stringWithFormat:@"%@&%@",currentUser.objectId,targetId];
            NSString *conID1 = [NSString stringWithFormat:@"%@&%@",targetId,currentUser.objectId];
            
            NSString *deleteOneChatsString = [NSString stringWithFormat:@"delete from chat  where conversationid = '%@' or conversationid = '%@'",conID,conID1];
            sqlite3_exec(db, [deleteOneChatsString UTF8String], NULL, NULL, NULL);
            
            NSString *deleteOneRecentString = [NSString stringWithFormat:@"delete from recent where uid = '%@'",targetId];
            sqlite3_exec(db, [deleteOneRecentString UTF8String], NULL, NULL, NULL);
            
        }
        sqlite3_close(db);
    });
    
    BmobUser *tmpUser = [BmobUser objectWithoutDatatWithClassName:@"User" objectId:targetId];
    BmobRelation *relation = [BmobRelation relation];
    [relation removeObject:tmpUser];
    
    BmobUser *currentUser = [BmobUser getCurrentUser];
    [currentUser addRelation:relation forKey:@"contacts"];
    [currentUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (block) {
            block(isSuccessful,error);
        }
    }];
}

-(BmobChatUser*)currentUser{
    
    BmobUser *user         = [BmobUser getCurrentUser];
    BmobChatUser *chatUser = [[BmobChatUser alloc] init];
    chatUser.objectId      = user.objectId;
    chatUser.updatedAt     = user.updatedAt;
    chatUser.createdAt     = user.updatedAt;
    chatUser.avatar        = [user objectForKey:@"avatar"];
    chatUser.nick          = [user objectForKey:@"nick"];
    chatUser.username      = [user objectForKey:@"username"];
    
    return chatUser;
}


/**
 *   登陆-默认登陆成功之后会检测当前账号是否绑定过设备
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param block    登陆的结果
 */

-(void)loginWithUsername:(NSString *)username password:(NSString*)password block:(BmobBooleanResultBlock)block{
    
    [BmobUser logInWithUsernameInBackground:username password:password block:^(BmobUser *user, NSError *error) {
        if (!error) {
            block(YES,nil);
        }else{
            block(NO,error);
        }
    }];
    
}
/**
 *  退出登陆
 */
-(void)logout{
    [BmobUser logout];
}

/**
 *  获取当前用户的好友列表 ,默认按照更新时间降序排列
 *
 *  @param block 当前用户的好友列表
 */
-(void)queryCurrentContactArray:(BmobObjectArrayResultBlock)block{
    BmobQuery *query = [BmobQuery queryForUser];
//    [query includeKey:@"contacts"];
    BmobUser *user = [BmobUser getCurrentUser];

    [query whereObjectKey:@"contacts" relatedTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (block) {
            block(array,error);
        }
    }];
}

/**
 *   模糊查询指定名称的用户:默认过滤掉本人和好友
 *
 *  @param name  查询的名称
 *  @param block 查询的结果
 */
-(void)queryUserByName:(NSString *)name block:(BmobObjectArrayResultBlock)block{
    BmobQuery *query          = [BmobQuery queryForUser];
    query.limit               = 20;
    NSDictionary *dic =@{@"$and":@[@{@"username":@{@"$nin":[self selfAndFriendArray]}},@{@"username":@{@"$regex":[NSString stringWithFormat:@"%@",name] }}]};
    [query queryWithAllConstraint:dic];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (block) {
            block(array,error);
        }
    }];
    
}


-(NSString *)hexStringFromData:(NSData *)data{
    NSData *myD = data;//[string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

-(NSString *)databasePath{
    NSString *databaseName = [NSString stringWithFormat:@"%@.db",[[BmobUser getCurrentUser] objectForKey:@"username"]];
    NSArray  *paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirecotry =[paths objectAtIndex:0];
    NSString *path         = [documentDirecotry stringByAppendingPathComponent:databaseName];
    return path;
}


-(void)countNearbyWithKey:(NSString *)key location:(BmobGeoPoint *)location block:(BmobIntegerResultBlock)block{
    if (!key || [key isEqualToString:@""]) {
        return;
    }
    BmobQuery *query = [BmobQuery queryForUser];
    [query whereKey:key nearGeoPoint:location];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (block) {
            block(number,error);
        }
    }];
}

/**
 *  查看附近的人
 *
 *  @param key      存放位置的列
 *  @param location 地理位置
 *  @param page     页码，从0开始
 *  @param block    返回查询的数组和错误信息
 */
-(void)queryNearbyWithKey:(NSString *)key location:(BmobGeoPoint *)location page:(NSInteger)page block:(BmobObjectArrayResultBlock)block{
    if (!key || [key isEqualToString:@""]) {
        block([NSArray array],nil);
        return;
    }
    if (page < 0) {
        block([NSArray array],nil);
        return;
    }
    
 
    
    BmobQuery *query = [BmobQuery queryForUser];
    query.limit      = 20;
//    query.skip       = page * 10;
    [query whereKeyExists:key];
    [query whereKey:@"sex" notEqualTo:[NSNumber numberWithBool:YES]];
    [query whereKey:key nearGeoPoint:location ];
//    [query whereKey:@"username" notContainedIn:[self selfAndFriendArray]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (block) {
            
            block(array,error);
        }
    }];
    
    
    
}


-(NSArray *)selfAndFriendArray{
    BmobUser *user            = [BmobUser getCurrentUser];
    NSString *loginUsername   = [user objectForKey:@"username"];
    NSMutableArray *nameArray = [NSMutableArray array];
    [nameArray addObject:loginUsername];
    sqlite3 *db;
    sqlite3_stmt *statement;
    if (sqlite3_open([[self databasePath] UTF8String], &db) == SQLITE_OK) {
        NSString *sqlString = [NSString stringWithFormat:@"select username from friends"];
        if (sqlite3_prepare_v2(db, [sqlString UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                const char *tmpUsername = (char *)sqlite3_column_text(statement, 0);
                if (tmpUsername) {
                    NSString *tmpUsernameString = [[NSString alloc] initWithUTF8String:tmpUsername];
                    [nameArray addObject:tmpUsernameString];
                }
            }
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    return nameArray;
}

@end
