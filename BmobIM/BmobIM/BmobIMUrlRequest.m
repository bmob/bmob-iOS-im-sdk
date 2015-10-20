//
//  BmobUrlRequest.m
//  BmobSDK
//
//  Created by Bmob on 14-2-19.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import "BmobIMUrlRequest.h"


@interface BmobIMUrlRequest()<NSURLConnectionDataDelegate>{
    
    NSMutableURLRequest     *_bUrlRequest;
    NSMutableData           *_bMutableData;
    B_BmobBasicBlock        _completeBlock;
    B_BmobBasicBlock        _failetedBlock;
    B_BmobProgressBlock     _progressBlock;
    NSURLConnection         *_bConnection;
    NSMutableDictionary     *_bMutableDic;
    NSMutableString         *_httpMethod;
    BOOL                    _isSetHttpBody;
//    NSRecursiveLock         *_lock;
}


@end



@implementation BmobIMUrlRequest

@synthesize responseData=_resopnseData,responseString=_resopnseString,error=_error;
//@synthesize postProgress = _postProgress;

-(id)initWithUrl:(NSURL*)url{
    self = [super init];
    if (self) {
        _bUrlRequest   = [[NSMutableURLRequest alloc] initWithURL:url];
        _bMutableDic   = [[NSMutableDictionary alloc] init];
        _bMutableData  = [[NSMutableData alloc] init];
        _error         = [[NSError alloc] init];
        _httpMethod    = [[NSMutableString alloc] init];
        self.error     = _error;
        _isSetHttpBody = NO;
        [_httpMethod setString:@"POST"];
    }
    return self;
}

+(instancetype)requestWithUrl:(NSURL* )url{
    BmobIMUrlRequest  *request = [[BmobIMUrlRequest alloc] initWithUrl:url];
    return request ;
}

-(void)dealloc{
    
    _completeBlock     = nil;
    _failetedBlock     = nil;
    _progressBlock     = nil;
    _bMutableData      = nil;
    _bMutableDic       = nil;
    _httpMethod        = nil;
    
    if (_bConnection) {
        [_bConnection cancel];
        
        _bConnection = nil;
    }
    
    
    self.responseString = nil;
    self.responseData   = nil;
    self.error          = nil;

   
}

#pragma some method

- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key{
    
    
    if (!key) {
        return;
    }
    
    if (!value) {
        return;
    }
    
    [_bMutableDic setObject:value forKey:key];
    
    
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    [_bUrlRequest addValue:value forHTTPHeaderField:field];
    
}

-(void)setPostBody:(NSData*)data{
    
    _isSetHttpBody = YES;
    
    
    [_bUrlRequest setHTTPBody:data];
}


- (void)setHttpMethod:(NSString*)method{

    [_httpMethod setString:method];
}

-(NSMutableString*)postString{

    NSMutableString *postString = [NSMutableString string ];
    
    if ([_bMutableDic count] > 0) {
        for (NSString *key in [_bMutableDic allKeys]) {
            
            [postString appendString:[NSString stringWithFormat:@"%@=%@&",key,[_bMutableDic objectForKey:key]]];
            
        }
    }
    
    return postString;

}



- (void)startAsyncConnection{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_bUrlRequest addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
        [_bUrlRequest setHTTPMethod:_httpMethod];
        
        if (!_isSetHttpBody) {
            [_bUrlRequest setHTTPBody:[[self postString] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (_bConnection) {
            [_bConnection cancel];
            
            _bConnection = nil;
        }
         _bConnection = [[NSURLConnection alloc] initWithRequest:_bUrlRequest delegate:self];
        [_bConnection start];

    });

}

-(void)startSyncConnection{

    [_bUrlRequest addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
    [_bUrlRequest setHTTPMethod:_httpMethod];
    if (!_isSetHttpBody) {
        [_bUrlRequest setHTTPBody:[[self postString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *data = [NSURLConnection sendSynchronousRequest:_bUrlRequest returningResponse:nil error:nil];
    if (data) {
        [_bMutableData setData:data];
        if (_bMutableData) {
            [self.responseData setData:_bMutableData];
            NSString    *rpString = [[NSString alloc] initWithData:_bMutableData encoding:NSUTF8StringEncoding];
            [self.responseString setString:rpString];
        }
    }
}

- (void)setCompletionBlock:(B_BmobBasicBlock)aCompletionBlock{
   
    _completeBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(B_BmobBasicBlock)aFailedBlock{
   
    _failetedBlock = [aFailedBlock copy];
}

- (void)getProgressBlock:(B_BmobProgressBlock)aProgressBlock{
  
    _progressBlock = [aProgressBlock copy];
    


}

-(NSMutableData*)responseData{
    
    if (!_resopnseData) {
        _resopnseData = [[NSMutableData alloc] init];
    }
    
   
    
    return _resopnseData;
}

-(NSMutableString*)responseString{
    
    if (!_resopnseString) {
        _resopnseString = [[NSMutableString alloc] init];
    }

    return _resopnseString;
    
}



-(void)cancle{
    if (_bConnection) {
        [_bConnection cancel];
    }
}

#pragma mark connection

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if (connection == _bConnection) {
        if (totalBytesExpectedToWrite != 0) {
            
           float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
            if (_progressBlock) {
                _progressBlock(progress);
            }
        }
    } 
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response{

}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data{
    if (_bMutableData) {
        [_bMutableData appendData:data];
    }
    
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error{
    if (self.error) {
        self.error = error;
    }
    
    if (_failetedBlock) {
        _failetedBlock();
    }
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_bMutableData) {
        NSString    *rpString = [[NSString alloc] initWithData:_bMutableData encoding:NSUTF8StringEncoding];
        [self.responseString setString:rpString];
        [self.responseData setData:_bMutableData];
        
        
    }
    
    if (_completeBlock) {
        _completeBlock();
    }
    
    
    
}

@end
