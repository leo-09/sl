//
//  PushViewController.h
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveModel.h"

@interface PushViewController : UIViewController<NSXMLParserDelegate>

@property (nonatomic, retain) LiveModel *live;

@end
