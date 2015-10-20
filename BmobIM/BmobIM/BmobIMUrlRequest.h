//
//  BmobUrlRequest.h
//  BmobSDK
//
//  Created by Bmob on 14-2-19.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^B_BmobBasicBlock)(void);
typedef void (^B_BmobProgressBlock)(float progress);

@interface BmobIMUrlRequest : NSObject{

    NSError                 *_error;
    NSMutableData           *_resopnseData;
    NSMutableString         *_resopnseString;

}

@property (retain,nonatomic)NSMutableString     *responseString;
@property (retain,nonatomic)NSMutableData       *responseData;
@property (retain,nonatomic)NSError             *error;
//@property (nonatomic,assign)float               postProgress;

-(id)initWithUrl:(NSURL*)url;

+ (instancetype)requestWithUrl:(NSURL* )url;

/**
 *  post内容
 *
 *  @param value 值
 *  @param key   键
 */
- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key;

/**
 *  头部信息
 *
 *  @param value 值
 *  @param field 键
 */
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

- (void)setPostBody:(NSData*)data;


- (void)setHttpMethod:(NSString*)method;

/**
 *  异步启动
 */
- (void)startAsyncConnection;

- (void)startSyncConnection;

- (void)cancle;

/**
 *  connection 成功
 *
 *  @param aCompletionBlock 成功
 */
- (void)setCompletionBlock:(B_BmobBasicBlock)aCompletionBlock;

/**
 *  connection 失败
 *
 *  @param aFailedBlock 失败block
 */
- (void)setFailedBlock:(B_BmobBasicBlock)aFailedBlock;

/**
 *  post上传进度
 *
 *  @param aProgressBlock post上传进度
 */
- (void)getProgressBlock:(B_BmobProgressBlock)aProgressBlock;
@end
