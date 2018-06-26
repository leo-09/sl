//
//  AccountLocalData.h
//  PhoneLive
//
//  Created by liyy on 2018/2/12.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountLocalData : NSObject

+ (instancetype) sharedInstance;

- (NSString *)address;
- (void) setAddress:(NSString *)address;

- (NSString *)userName;
- (void) setUserName:(NSString *)name;

- (NSString *)userPsw;
- (void) setUserPsw:(NSString *)psw;

@end
