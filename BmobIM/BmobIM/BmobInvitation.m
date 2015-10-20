//
//  BmobInvitation.m
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobInvitation.h"
#import "BmobIM.h"

@implementation BmobInvitation

@synthesize avatar   = _avatar;
@synthesize fromId   = _fromId;
@synthesize fromname = _fromname;
@synthesize nick     = _nick;
@synthesize statue   = _statue;
@synthesize time     = _time;



-(instancetype)receiverInvitationWithUser:(BmobChatUser*)user time:(NSInteger)time{

    BmobInvitation *tmpIvitation = [[BmobInvitation alloc] init];
    tmpIvitation.time            = time;
    tmpIvitation.fromId          = user.objectId;
    tmpIvitation.fromname        = [user objectForKey:@"username"];
    tmpIvitation.nick            = user.nick;
    tmpIvitation.statue          = STATUS_ADD_NO_VALIDATION;
    
    return tmpIvitation;
}

@end
