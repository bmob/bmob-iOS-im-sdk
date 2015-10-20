//
//  BmobIMSaveMessage.h
//  BmobIM
//
//  Created by Bmob on 14-7-1.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobMsg.h"
#import <BmobSDK/Bmob.h>

@interface BmobIMSaveMessage : NSObject

+(void)saveMessage:(BmobMsg *)msg resultBlock:(BmobBooleanResultBlock)block;

@end
