//
//  QuitView.h
//  PhoneLive
//
//  Created by liyy on 2018/2/13.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickListener)(void);

@interface QuitView : UIView<CAAnimationDelegate>

@property (nonatomic, retain) UIView *fatherView;
@property (nonatomic, retain) UIView *bgView;

@property (nonatomic, strong) ClickListener quitListener;

- (void) showViewWithUIView:(UIView *)view isPortrait:(BOOL)isPortrait;

@end
