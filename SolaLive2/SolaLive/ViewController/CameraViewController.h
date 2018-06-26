//
//  CameraViewController.h
//  PhoneLive
//
//  Created by liyy on 2018/2/6.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController<NSXMLParserDelegate>

@property (nonatomic, assign) BOOL isPlay;  // 是否‘马上观看’
@property (nonatomic, copy) NSString *operateOrgId;

@end
