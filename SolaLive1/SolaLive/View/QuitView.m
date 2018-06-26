//
//  QuitView.m
//  PhoneLive
//
//  Created by liyy on 2018/2/13.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "QuitView.h"
#import "AppDelegate.h"

@implementation QuitView

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
    iv.image = [UIImage imageNamed:@"dialog_quit"];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(@30);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"您当前正在直播";
    label.textColor = UIColorFromRGB(0x555555);
    label.font = [UIFont systemFontOfSize:16.0];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(iv.mas_bottom).offset(30);
    }];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"是否确认退出直播？";
    label1.textColor = UIColorFromRGB(0x888888);
    label1.font = [UIFont systemFontOfSize:12.0];
    [view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(label.mas_bottom).offset(10);
    }];
    
    UIButton *quitBtn = [[UIButton alloc] init];
    [quitBtn setTitle:@"退出直播" forState:UIControlStateNormal];
    [quitBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    quitBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [quitBtn addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchDown];
    [view addSubview:quitBtn];
    [quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.width.equalTo(@140);
        make.height.equalTo(@42);
    }];
    
    UIButton *closeBtn2 = [[UIButton alloc] init];
    [closeBtn2 setTitle:@"继续直播" forState:UIControlStateNormal];
    [closeBtn2 setTitleColor:UIColorFromRGB(0x0c9bff) forState:UIControlStateNormal];
    closeBtn2.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [closeBtn2 addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchDown];
    [view addSubview:closeBtn2];
    [closeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.right.equalTo(@0);
        make.width.equalTo(@140);
        make.height.equalTo(@42);
    }];
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = UIColorFromRGB(0xeeeeee);
    [view addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(quitBtn.mas_top);
    }];
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = UIColorFromRGB(0xeeeeee);
    [view addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(quitBtn.mas_right);
        make.width.equalTo(@1);
        make.bottom.equalTo(quitBtn);
        make.top.equalTo(quitBtn);
    }];
}

- (void) quit {
    [self hideView];
    
    if (self.quitListener) {
        self.quitListener();
    }
}

- (void) showViewWithUIView:(UIView *)view isPortrait:(BOOL)isPortrait {
    self.fatherView = view;
    
    [self.fatherView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.fatherView);
    }];
    
    [self showAnimation:isPortrait];
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

- (void) showAnimation:(BOOL)isPortrait {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 动画选项的设定
    animation.duration = 0.3;
    animation.delegate = self;
    
    // 起始帧和终了帧的设定
    CGPoint center;
    if (isPortrait) {
        center = self.fatherView.center;
    } else {
        center = CGPointMake(self.fatherView.center.y, self.fatherView.center.x);
    }
    
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
