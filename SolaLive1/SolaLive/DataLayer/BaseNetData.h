//
//  BaseNetData.h
//  PhoneLive
//
//  Created by liyy on 2018/2/12.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseNetData : NSObject

+ (instancetype) sharedInstance;

//- (void) sendPost:(NSString *)url parameters:(NSDictionary *)params finishBlock:(void (^)(id data,NSInteger result))finishBlock;

@end
