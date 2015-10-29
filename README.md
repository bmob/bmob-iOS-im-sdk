# Bmob-IMSDK
IMSDK source code

## iOS相关内容


### 使用方法
cmd + b 可以直接生成framework，开发者也可以直接把源码拷到自己项目中，按需更改。
数据库升级遇到的问题可参照 http://www.sqlite.org/faq.html#q11 进行处理

### 版本1.0.1

#### 修复的内容
1. 修复保存到聊天表中没有添加toId和belongAvatar的bug
2. 更改为先保存信息，保存成功后再发送推送，如果用户没有允许推送的话，则只会在服务器保存信息，不会发送推送
3. 
```
PUSH_KEY_TARGETID 更换为PUSH_KEY_FROMID 
```

#### 添加的内容
__BmobChatManager类__

1)添加查找获取未读消息的方法：

```
-(void)queryUnreadMessageFromServerWithUserId:(NSString *)uid block:(BmobObjectArrayResultBlock )block;
```
2)添加设置已读的方法

```
-(void)serverMarkAsReaded:(BmobMsg *)msg;
```

__BmobDB类__

数据库名称更换为用objectId命名，避免用户名更改后数据库名称变化,如果之前用过BmobIM,请注意数据库名称的变化

聊天表添加fttime字段以确保信息唯一

__BmobMsg类__
 
添加toId属性

__BmobRecent类__

添加count 属性

__BmobUserManager类__

1)添加  添加到黑名单的方法

```
-(void)addToBlackListWithUserID:(NSString *)objectId completion:(BmobBooleanResultBlock)block;
```

2)添加 移除黑名单的方法

```
-(void)removeBlackListWithUserID:(NSString *)objectId completion:(BmobBooleanResultBlock)block;
```
依赖的SDK更换为1.6.5版本的BmobSDK