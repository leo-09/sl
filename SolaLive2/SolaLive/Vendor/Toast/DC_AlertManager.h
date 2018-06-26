//
//  DC_AlertManager.h
//  BTGShop
//
//  Created by Dave on 2017/11/2.
//  Copyright © 2017年 CCDC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DC_AlertManager : NSObject

+ (instancetype)shareManager;

/**
 短暂提示
 */
+ (void)showHudWithMessage:(NSString *)str superView:(UIView *)view;

@end
