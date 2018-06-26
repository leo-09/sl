//
//  SettingViewController.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "SettingViewController.h"
#import "ResolitionViewController.h"
#import "VideoRecordViewController.h"
#import "RateViewController.h"
#import "AppDelegate.h"

@interface SettingViewController () {
    BOOL isCrossScreen;
    BOOL isBackCamera;
    BOOL isSave;
}

@property (weak, nonatomic) IBOutlet UISwitch *crossScreenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *backCameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveSwitch;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@end

@implementation SettingViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingViewController"];
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"直播设置";
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    // 默认横屏
    NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
    if ([orientation isEqualToString:@"横屏"]) {
        _crossScreenSwitch.on = YES;
        isCrossScreen = YES;
    } else {
        _crossScreenSwitch.on = NO;
        isCrossScreen = NO;
    }
    
    // 默认后摄像头
    NSString *camera = [[NSUserDefaults standardUserDefaults] objectForKey:FBCamera];
    if ([camera isEqualToString:@"后摄像头"]) {
        _backCameraSwitch.on = YES;
        isBackCamera = YES;
    } else {
        _backCameraSwitch.on = NO;
        isBackCamera = NO;
    }
    
    // 本地存储
    NSString *save = [[NSUserDefaults standardUserDefaults] objectForKey:SaveVideo];
    if ([save isEqualToString:@"本地存储"]) {
        _saveSwitch.on = YES;
        isSave = YES;
    } else {
        _saveSwitch.on = NO;
        isSave = NO;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *resolution = [[NSUserDefaults standardUserDefaults] objectForKey:resolition];
    if ([resolution isEqualToString:@"1080*1920"]) {
        _resolutionLabel.text = @"超清";
    } else if ([resolution isEqualToString:@"720*1280"]) {
        _resolutionLabel.text = @"高清";
    } else if ([resolution isEqualToString:@"480*640"]) {
        _resolutionLabel.text = @"标清";
    } else {
        _resolutionLabel.text = @"流畅";
    }
    
    NSString *rate = [[NSUserDefaults standardUserDefaults] objectForKey:Rate];
    if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 500 * 1000]]) {
        _rateLabel.text = @"低(500kbps)";
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 800 * 1000]]) {
        _rateLabel.text = @"中(800kbps)";
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 1500 * 1000]]) {
        _rateLabel.text = @"高(1500kbps)";
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 52500 * 1000]]) {
        _rateLabel.text = @"极佳(52500kbps)";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 4:{ // 分辨率
            ResolitionViewController *controller = [[ResolitionViewController alloc] initWithStoryboard];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 5:{ // 码率
            RateViewController *controller = [[RateViewController alloc] initWithStoryboard];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 8:{ // 最大可存档时长
            VideoRecordViewController *controller = [[VideoRecordViewController alloc] initWithStoryboard];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - click event

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

// 是否横屏播放
- (IBAction)crossScreen:(id)sender {
    UISwitch *s = (UISwitch *) sender;
    if (s.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"横屏" forKey:Orientation];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Orientation];
    }
    
    if (s.on != isCrossScreen) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.isEdit = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 是否使用后置摄像头
- (IBAction)backCamera:(id)sender {
    UISwitch *s = (UISwitch *) sender;
    if (s.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"后摄像头" forKey:FBCamera];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:FBCamera];
    }
    
    if (s.on != isBackCamera) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.isEdit = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 本地存储
- (IBAction)saveSwitch:(id)sender {
    UISwitch *s = (UISwitch *) sender;
    if (s.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"本地存储" forKey:SaveVideo];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SaveVideo];
    }
    
    if (s.on != isSave) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.isEdit = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
