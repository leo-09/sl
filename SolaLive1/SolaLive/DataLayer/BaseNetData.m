//
//  BaseNetData.m
//  PhoneLive
//
//  Created by liyy on 2018/2/12.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "BaseNetData.h"

@implementation BaseNetData

#pragma mark - 单例模式

static BaseNetData *instance;

+ (id) allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype) sharedInstance {
    static dispatch_once_t oncetToken;
    dispatch_once(&oncetToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id) copyWithZone:(NSZone *)zone {
    return instance;
}

//#pragma mark - public method
//
//- (void) sendPost:(NSString *)url parameters:(NSDictionary *)params finishBlock:(void (^)(id data,NSInteger result))finishBlock {
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
//    // 超时时间
//    session.requestSerializer.timeoutInterval = 8;
//    session.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [session POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
//        // 请求数据，没有进度
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        finishBlock(responseObject, 1);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        finishBlock(nil, 0);
//    }];
//}

@end
