//
//  LiveViewController.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "LiveViewController.h"

@interface LiveViewController ()

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addItemView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI

- (void) addItemView {
    CGFloat wh = 40;
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.backgroundColor = UIColorFromRGB(0x368AFA);
    [backBtn setImage:[UIImage imageNamed:@"setting_close"] forState:UIControlStateNormal];
    YYViewBorderRadius(backBtn, 20, 0, [UIColor clearColor]);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.top.equalTo(@20);
        make.right.equalTo(@(-20));
    }];
}

#pragma mark - click event

// 返回
- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
