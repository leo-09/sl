//
//  NoLiveView.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "NoLiveView.h"
#import "AppDelegate.h"

@interface NoLiveView()

@property (nonatomic, retain) UIView *bgView;

@end

@implementation NoLiveView

- (instancetype) init {
    if (self = [super init]) {
        self.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
        
        [self addItemView];
    }
    
    return self;
}

- (void) addItemView {
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@280);
        make.height.equalTo(@320);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"dialog_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchDown];
    [_bgView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@48);
    }];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    YYViewBorderRadius(view, 4, 0, [UIColor clearColor]);
    [_bgView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.top.equalTo(closeBtn.mas_bottom);
    }];
    
    UIImageView *iv = [[UIImageView alloc] init];
    iv.image = [UIImage imageNamed:@"dialog_nolive"];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(@30);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    NSString *name = @"当前频道无直播节目";
    // 创建一个富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:name];
    // 修改富文本中的不同文字的样式
    [attri addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x777777) range:NSMakeRange(0, name.length)];
    [attri addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x478bf6) range:NSMakeRange(0, 4)];
    [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, name.length)];
    label.attributedText = attri;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(iv.mas_bottom).offset(25);
    }];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = UIColorFromRGB(0x368afa);
    [btn setTitle:@"我知道了" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    YYViewBorderRadius(btn, 20, 0, [UIColor clearColor]);
    [btn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchDown];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-30));
        make.centerX.equalTo(view);
        make.width.equalTo(@200);
        make.height.equalTo(@40);
    }];
}

#pragma mark - public method

- (void) showView {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    
    [self showAnimation];
}

- (void) hideView {
    [self hideAnimation];
}

#pragma mark - 动画

- (void) hideAnimation {
    if (self.bgView.isHidden) {
        return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 动画选项的设定
    animation.duration = 0.2; // 持续时间
    animation.delegate = self;
    
    // 起始帧和终了帧的设定
    animation.fromValue = [NSValue valueWithCGPoint:self.bgView.center];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bgView.center.x, self.bgView.center.y + SCREEN_HEIGHT)];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    // 添加动画
    [self.bgView.layer removeAllAnimations];
    [self.bgView.layer addAnimation:animation forKey:@"hide-layer"];
}

- (void) showAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 动画选项的设定
    animation.duration = 0.3;
    animation.delegate = self;
    
    // 起始帧和终了帧的设定
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CGPoint center = app.window.center;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(center.x, center.y + SCREEN_HEIGHT / 2)];
    animation.toValue = [NSValue valueWithCGPoint:center];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    // 添加动画
    [self.bgView.layer removeAllAnimations];
    [self.bgView.layer addAnimation:animation forKey:@"show-layer"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim.duration == 0.2) {
        [self removeFromSuperview];
    }
}

@end
