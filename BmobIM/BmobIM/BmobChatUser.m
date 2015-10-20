//
//  BmobChatUser.m
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "BmobChatUser.h"

@implementation BmobChatUser

@synthesize avatar   = _avatar;
@synthesize contacts = _contacts;
@synthesize nick     = _nick;
@synthesize username = _username;

-(void)setAvatar:(NSString *)avatar{
    if (_avatar != avatar) {
        _avatar = nil;
        _avatar = [avatar copy];
    }
    
    if (!_avatar) {
        [self setObject:_avatar forKey:@"avatar"];
    }
}

-(NSString*)avatar{
    if (!_avatar) {
        _avatar = [self objectForKey:@"avatar"];
    }
    
    return _avatar;
}

-(void)setNick:(NSString *)nick{
    if (_nick != nick) {
        _nick = nil;
        _nick = [nick copy];
    }
    
    if (!_nick) {
        [self setObject:_nick forKey:@"nick"];
    }
}

-(NSString*)nick{
    if (!_nick) {
        _nick = [self objectForKey:@"nick"];
    }
    return _nick;
}


-(void)setUsername:(NSString *)username{
    if (_username != username) {
        _username = nil;
        _username = [username copy];
        
        [self setUserName:username];
    }
}

-(NSString*)username{
    if (!_username) {
        _username = [self objectForKey:@"username"];
    }
    
    return _username;
}


@end
