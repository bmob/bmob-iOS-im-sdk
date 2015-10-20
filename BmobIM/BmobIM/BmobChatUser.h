//
//  BmobChatUser.h
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface BmobChatUser : BmobUser
/**
 *  头像
 */
@property(nonatomic,copy)NSString *avatar;

/**
 *  关系
 */
@property(nonatomic,strong)BmobRelation *contacts;
/**
 *  昵称
 */
@property(nonatomic,copy)NSString *nick;

/**
 *  用户名
 */
@property(nonatomic,copy)NSString *username;
@end
