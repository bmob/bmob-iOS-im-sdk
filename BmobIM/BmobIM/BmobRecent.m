//
//  BmobRecent.m
//  BmobIM
//
//  Created by Bmob on 14-6-23.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobRecent.h"
#import "BmobIM.h"
@implementation BmobRecent

@synthesize avatar;
@synthesize message;
@synthesize nick;
@synthesize targetId;
@synthesize time;
@synthesize type;
@synthesize targetName;


+(instancetype)recentObejectWithAvatarString:(NSString *)avatar
                                     message:(NSString *)message
                                        nick:(NSString *)nick
                                    targetId:(NSString *)targetId
                                        time:(NSInteger )time
                                        type:(NSInteger)type
                                  targetName:(NSString *)targetName{
    
    BmobRecent *tmpRecent = [[BmobRecent alloc] init];
    tmpRecent.avatar      = avatar;
    tmpRecent.nick        = nick;
    tmpRecent.targetId    = targetId;
    tmpRecent.time        = time;
    tmpRecent.type        = type;
    tmpRecent.targetName  = targetName;
    
    if (tmpRecent.type == MessageTypeImage) {
        tmpRecent.message     =@"[图片]";
    }else if (tmpRecent.type == MessageTypeLocation){
        tmpRecent.message     =@"[位置]";
    }else{
        tmpRecent.message     = message;
    }
    
    
    return tmpRecent;
}

@end
