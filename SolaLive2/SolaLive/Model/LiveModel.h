//
//  LiveModel.h
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject

@property (nonatomic, copy) NSString *PkId;         // 直播ID
@property (nonatomic, copy) NSString *Name;         // 直播标题
@property (nonatomic, copy) NSString *ClientCount;  // 正在观看的人数
@property (nonatomic, copy) NSString *LiveUrl;      // 直播的地址
@property (nonatomic, copy) NSString *Status;       // 0:无直播; 1:有直播    是否正在直播

@end
