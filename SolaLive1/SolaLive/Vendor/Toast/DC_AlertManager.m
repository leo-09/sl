//
//  DC_AlertManager.m
//  BTGShop
//
//  Created by Dave on 2017/11/2.
//  Copyright © 2017年 CCDC. All rights reserved.
//

#import "DC_AlertManager.h"
#import "UIView+Toast.h"

static DC_AlertManager *_manager = nil;

@implementation DC_AlertManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[DC_AlertManager alloc] init];
    });
   
    return _manager;
}

+ (void)showHudWithMessage:(NSString *)str superView:(UIView *)view {
    [view makeToast:str duration:1 position:CSToastPositionBottom];
}

@end
