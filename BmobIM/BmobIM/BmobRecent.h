//
//  BmobRecent.h
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobRecent : NSObject

@property (copy, nonatomic) NSString *mid;

/**
 *  头像
 */
@property(nonatomic,copy)NSString* avatar;

/**
 *  消息头像
 */
@property(nonatomic,copy)NSString* message;

/**
 *  昵称
 */
@property(nonatomic,copy)NSString* nick;

/**
 *  会话对方的id
 */
@property(nonatomic,copy)NSString* targetId;

/**
 *  时间
 */
@property(assign,nonatomic)NSInteger      time;

/**
 *  类型
 */
@property(assign,nonatomic)NSInteger      type;

/**
 *  会话对方的用户名
 */
@property(nonatomic,copy)NSString* targetName;


/**
 *  个数
 */
@property(assign,nonatomic)NSInteger      count;

+(instancetype)recentObejectWithAvatarString:(NSString *)avatar
                                     message:(NSString *)message
                                        nick:(NSString *)nick
                                    targetId:(NSString *)targetId
                                        time:(NSInteger)time
                                        type:(NSInteger)type
                                  targetName:(NSString *)targetName;


@end
