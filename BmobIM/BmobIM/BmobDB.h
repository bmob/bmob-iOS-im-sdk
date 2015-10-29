//
//  BmobDB.h
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BmobIM.h"
#import "BmobRecent.h"
#import "BmobInvitation.h"

@interface BmobDB : NSObject

/**
 *  创建BmobDB对象
 *
 *  @param databaseName 数据库名称
 *
 *  @return BmobDB对象
 */
-(instancetype)initWithDatabaseName:(NSString*)databaseName;

/**
 *  创建BmobDB对象
 *
 *  @param databaseName 数据库名称
 *
 *  @return BmobDB对象
 */
+(instancetype)databaseWithName:(NSString*)databaseName;


/**
 *  创建以用户名为名的数据库,默认使用
 *
 *  @return BmobDB对象
 */
+(instancetype)currentDatabase;

/**
 *  创建数据库
 */
-(void)createDataBase;

/**
 *  数据库升级时,删除所有数据表 用于清空缓存操作--谨慎使用
 */
-(void)clearAllDBCache;


#pragma mark - recent 表操作

/**
 *  删除所有的聊天记录-用于清除缓存操作
 */
-(void)deleteAllRecent;

/**
 *  删除与指定用户之间的会话记录
 *
 *  @param targertId 指定用户的Id
 */
-(void)deleteRecentWithUid:(NSString*)targertId;

/**
 *  查询登陆用户所有会话列表
 *
 *  @return 查询登陆用户所有会话列表
 */
-(NSArray*)queryRecent;

/**
 *  是否已存在聊天用户列表那里
 *
 *  @return 未读的消息
 */
-(BOOL)hasRecentWithUserId:(NSString *)toId;

/**
 *  更新聊天列表
 */
-(void)updateRecentTable:(NSArray *)array;

/**
 *  更新聊天的信息和时间
 *
 *  @param toId    用户
 *  @param content 聊天的内容
 *  @param msgTime 聊天的时间
 */
-(void)updateRecentTableWithUserId:(NSString *)toId content:(NSString *)content msgTime:(NSUInteger)msgTime type:(NSUInteger)type;


/**
 *  查找用户的最近的聊天信息
 *
 *  @param toId 某个用户
 *
 *  @return
 */
-(BmobRecent *)queryRecentWithUserId:(NSString *)toId;

/**
 *  保存本地会话
 *
 *  @param recent 会话
 */
-(void)saveRecent:(BmobRecent*)recent;
#pragma mark - 联系人 表操作

/**
 *  删除一个联系人
 *
 *  @param uid 联系人的id
 */
-(void)deleteContactWithUid:(NSString*)uid;

/**
 *  删除指定用户和指定时间的好友请求
 *
 *  @param uid  指定用户的id
 *  @param time 指定的时间
 */

-(void)deleteInviteMsgWithUid:(NSString*)uid time:(NSString*)time;

/**
 *  获取本地数据库中存储的好友列表
 *
 *  @return 好友列表
 */
-(NSArray*)contaclList;



/**
 *  是否有新添加好友的请求
 *
 *  @return 是否有新添加好友的请求
 */
-(BOOL)hasNewInvite;


/**
 *  查找好友资料
 *
 *  @param targetId 好友的id
 *
 *  @return BmobChatUser对象
 */
-(BmobChatUser *)queryUserWithUid:(NSString *)targetId;

/**
 *   获取所有的好友请求数据-默认按照时间的先后顺序排列
 *
 *  @return 获取所有的好友请求数据
 */
-(NSArray*)queryBmobInviteList;

/**
 *  保存好友
 *
 *  @param user 好友
 */
-(void)saveContactWithUser:(BmobChatUser*)user;

/**
 *  保存好友
 *
 *  @param message 邀请的信息
 */
-(void)saveContactWithMessage:(BmobInvitation *)message;

/**
 *  保存好友请求
 *
 *  @param messages 邀请的信息
 */
-(void)saveInviteMessage:(BmobInvitation*)message;


/**
 *   保存或更新用户好友列表到本地数据
 *
 *  @param array BmobChatuser的数组
 */
-(void)saveOrCheckContactList:(NSArray*)array;



/**
 *  更新来自指定用户的好友请求的状态
 *
 *  @param fromname 指定好友的用户名
 */
-(void)updateAgreeMessage:(NSString *)fromname;
#pragma mark - 聊天内容 表操作

/**
 *   删除指定会话id的所有消息 deleteMessages
 *
 *  @param toId  当前聊天的objectid
 */
-(void)deleteMessagesWithUid:(NSString*)toId;

/**
 *  查询该会话对象的聊天消息记录总数
 *
 *  @param toId 会话对象的Id
 *
 *  @return 该会话对象的聊天消息记录总数
 */
-(NSInteger)queryChatTotalCountWithUid:(NSString*)toId;

/**
 *  针对单聊 获取指定会话id的所有消息 findMessage，支持分页操作
 *
 *  @param toId 指定用户的id
 *  @param page 页码
 *
 *  @return 指定用户的消息
 */
-(NSArray*)queryMessagesWithUid:(NSString*)toId page:(int)page;


/**
 *  针对单聊 获取指定会话id的所有消息 findMessage，支持分页操作
 *
 *  @param toId 指定用户的id
 *  @param limit 限制的条数
 *
 *  @return 指定用户的消息
 */
-(NSArray*)queryMessagesWithUid:(NSString*)toId limt:(int)limit;

/**
 *  是否有未读的消息--针对所有用户
 *
 *  @return 是否有未读的消息--针对所有用户
 */
-(BOOL)hasUnreadMsg;

/**
 *  重置未读消息
 *
 *  @param toId 指定用户的id
 */
-(void)resetUnreadWithUid:(NSString*)toId;

/**
 *  设置未读消息为已读
 */
-(void)resetUnread;

/**
 *  保存聊天消息
 *
 *  @param message 聊天的信息
 */
-(void)saveMessage:(BmobMsg*)message;


/**
 *  保存聊天数组
 *
 *  @param array <#array description#>
 */
-(void)saveMessageFromServerWithArray:(NSArray *)array;

/**
 *  查找指定聊天对象之间的未读消息数
 *
 *  @param toid 指定聊天对象的id
 *
 *  @return 未读消息数
 */
-(NSInteger)unreadCountWithUid:(NSString*)toId;


//删除某个人的聊天记录等
-(void)deleteRecentAndChatWithUid:(NSString *)targertId;

@end
