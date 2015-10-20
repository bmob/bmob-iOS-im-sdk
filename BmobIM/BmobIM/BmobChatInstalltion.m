//
//  BmobChatInstalltion.m
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobChatInstalltion.h"

@implementation BmobChatInstalltion
@synthesize uid =_uid;

-(void)setUid:(NSString *)uid{
    if (_uid != uid) {
        _uid = nil;
        _uid = [uid copy];
    }
    if (!_uid) {
        [self setObject:_uid forKey:@"uid"];
    }
    
}

-(NSString*)uid{
    if (!_uid) {
        _uid = [self objectForKey:@"uid"];
        return _uid;
    }
    
    return _uid;
}

@end
