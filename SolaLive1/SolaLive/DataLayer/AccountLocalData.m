//
//  AccountLocalData.m
//  PhoneLive
//
//  Created by liyy on 2018/2/12.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "AccountLocalData.h"

@implementation AccountLocalData

#pragma mark - 单例模式

static AccountLocalData *instance;

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

#pragma mark - public method

- (NSString *)address {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"IP_address"];
}

- (void) setAddress:(NSString *)address {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:address forKey:@"IP_address"];
    [defaults synchronize];
}

- (NSString *)userName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userName"];
}

- (void) setUserName:(NSString *)name {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"userName"];
    [defaults synchronize];
}

- (NSString *)userPsw {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userPsw"];
}

- (void) setUserPsw:(NSString *)psw {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:psw forKey:@"userPsw"];
    [defaults synchronize];
}

@end
