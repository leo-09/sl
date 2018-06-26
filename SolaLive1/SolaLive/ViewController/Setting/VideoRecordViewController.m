//
//  VideoRecordViewController.m
//  SolaLive
//
//  Created by liyy on 2018/3/29.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "VideoRecordViewController.h"

@interface VideoRecordViewController ()

@end

@implementation VideoRecordViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoRecordViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"本地视频记录";
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click event

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
