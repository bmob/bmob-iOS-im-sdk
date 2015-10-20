//
//  BmobInvitation.h
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobChatUser.h"

@interface BmobInvitation : NSObject

/**
 *  头像
 */
@property (nonatomic,copy) NSString  * avatar;

/**
 *  邀请的来源id
 */
@property (nonatomic,copy) NSString  * fromId;

/**
 *  邀请的来源用户的用户名
 */
@property (nonatomic,copy) NSString  * fromname;

/**
 *  昵称
 */
@property (nonatomic,copy) NSString  * nick;

/**
 *  状态
 */
@property (assign        ) NSInteger statue;

/**
 *  时间
 */
@property (assign        ) NSInteger time;

-(instancetype)receiverInvitationWithUser:(BmobChatUser*)user time:(NSInteger)time;
@end
