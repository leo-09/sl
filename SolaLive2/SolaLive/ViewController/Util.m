//
//  Util.m
//  SolaLive
//
//  Created by mac on 2018/6/23.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "Util.h"

@implementation Util

#pragma mark - JSON字符串转化为字典

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    jsonString = [self deleteSpecialCodeWithStr:jsonString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableLeaves
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

+ (NSString *) deleteSpecialCodeWithStr:(NSString *)str {
    // 空格不能替换
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"new Date" withString:@""];
    
    return string;
}

@end
