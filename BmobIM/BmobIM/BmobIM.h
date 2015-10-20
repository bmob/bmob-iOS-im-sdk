
//
//  BmobIM.h
//  BmobIM
//
//  Created by Bmob on 14-6-20.
//  Copyright (c) 2014年 bmob. All rights reserved.
//
#import <Foundation/Foundation.h>



#ifndef BmobIM_BmobIMConfig_h
#define BmobIM_BmobIMConfig_h

#import "BmobChatUser.h"
#import "BmobChat.h"
#import "BmobChatInstalltion.h"
#import "BmobMsg.h"
#import "BmobChatUser.h"
#import "BmobDB.h"
#import "BmobInvitation.h"
#import "BmobRecent.h"
#import "BmobUserManager.h"

//BmobIMSDKVersion   1.0.2

typedef enum {
    TAG_ADD_CONTACT          = 0, //标签消息种类:添加好友
    TAG_ADD_AGREE            = 1, //标签消息种类:同意添加好友
    TAG_READED               = 2, //标签消息种类:已读
    TAG_RECEIVERED           = 3, //标签消息种类:已收到
    TAG_OFFLINE              = 4  //标签消息种类:下线
}BmobIMMsgTag;

typedef enum {
    STATE_UNREAD             = 0, //消息是未读状态的
    STATE_READED             = 1  //消息是已读状态的
}BmobIMMessageState;

typedef enum {
    STATUS_ADD_AGREE         = 5, //消息发送状态：对方同意添加好友
    STATUS_ADD_IGNORE        = 6, //消息发送状态：对方忽略好友请求
    STATUS_ADD_NO_VALIDATION = 4, //消息发送状态：发送添加好友请求时候的状态是未验证
    STATUS_RECEIVER_SUCCESS  = 3, //消息发送状态：已送达
    STATUS_SEND_FAIL         = 2, //消息发送状态：失败
    STATUS_SEND_SUCCESS      = 1  //消息发送状态：成功
}BmobIMMessageRequestStatus;

typedef enum {
    MessageTypeText = 1,           //文本类型
    MessageTypeImage=2,            //图片
    MessageTypeLocation,           //位置
    MessageTypeVoice               //声音
}BmobIMMessageType;


#define  PUSH_ADD_FROM_AVATAR       @"fa"
#define  PUSH_ADD_FROM_NAME         @"fu"
#define  PUSH_ADD_FROM_NICK         @"fn"
#define  PUSH_ADD_FROM_TIME         @"ft"
#define  PUSH_ADD_FROM_ID           @"fId"
#define  PUSH_ADD_TO_ID             @"tId"

#define  PUSH_KEY_CONTENT           @"mc"
#define  PUSH_KEY_MSGTIME           @"ft"
#define  PUSH_KEY_MSGTYPE           @"mt"
#define  PUSH_KEY_TAG               @"tag"
#define  PUSH_KEY_TARGETAVATAR      @"fa"
#define  PUSH_KEY_TARGETID          @"fId"
#define  PUSH_KEY_TOID              @"tId"
#define  PUSH_KEY_TARGETNICK        @"fn"
#define	 PUSH_KEY_TARGETUSERNAME    @"fu"

#define  PUSH_RESPONSE              @"response"

#endif
