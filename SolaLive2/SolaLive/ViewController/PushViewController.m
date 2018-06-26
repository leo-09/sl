//
//  PushViewController.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "PushViewController.h"
#import <CoreTelephony/CTCellularData.h>
#import <AVFoundation/AVFoundation.h>
#import "SettingViewController.h"
#import "CameraEncoder.h"
#import "DC_AlertManager.h"
#import "QuitView.h"
#import "AccountLocalData.h"
#import "AppDelegate.h"
#import "NSString+Common.h"

@interface PushViewController ()<ConnectDelegate> {
    CameraEncoder *encoder;
    
    BOOL isRunning;
//    BOOL isClose;
    
    CGFloat bgViewWidth;
}

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prev;
@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UILabel *onlineCountLabel;
@property (nonatomic, strong) UIButton *rateBtn;
@property (nonatomic, strong) UIButton *timeBtn;
@property (nonatomic, strong) UIButton *resolutionBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIView *resolutionView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timeCount;

@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置直播地址和默认分辨率
    [[NSUserDefaults standardUserDefaults] setObject:self.live.LiveUrl forKey:ConfigUrl];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    encoder = [[CameraEncoder alloc] init];
    encoder.delegate = self;
    [encoder initCameraWithOutputSize:CGSizeMake(480, 640)];
    encoder.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:encoder.previewLayer];
    
    self.prev = encoder.previewLayer;
    [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.prev.frame = self.view.bounds;
    
    encoder.previewLayer.hidden = NO;
    [encoder startCapture];
    [encoder changeCameraStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(someMethod:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(someMethod:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    //设置窗口亮度大小  范围是0.1 - 1.0
    [[UIScreen mainScreen] setBrightness:1.0];
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (self.bgView) {
        [self.bgView removeFromSuperview];
        self.bgView = nil;
    }
    
    NSString *resolution = [[NSUserDefaults standardUserDefaults] objectForKey:resolition];
    NSArray *resolutionArray = [resolution componentsSeparatedByString:@"*"];
    int width = [resolutionArray[0] intValue];
    int height = [resolutionArray[1] intValue];
    
    // 横竖屏
    NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
    if ([orientation isEqualToString:@"横屏"]) {
        bgViewWidth = SCREEN_HEIGHT;
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgViewWidth, SCREEN_WIDTH)];
        
        encoder.orientation = AVCaptureVideoOrientationLandscapeRight;
        encoder.outputSize = CGSizeMake(height, width);
    } else {
        bgViewWidth = SCREEN_WIDTH;
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgViewWidth, SCREEN_HEIGHT)];
        
        encoder.orientation = AVCaptureVideoOrientationPortrait;
        encoder.outputSize = CGSizeMake(width, height);
    }
    
    self.bgView.backgroundColor = [UIColor clearColor];
    self.bgView.center = self.view.center;
    [self.view addSubview:self.bgView];
    
    [self addItemView];
    [self addTopItemView];
    
    // 设置分辨率
    if ([resolution isEqualToString:@"1080*1920"]) {
        [_resolutionBtn setTitle:@"超清" forState:UIControlStateNormal];
    } else if ([resolution isEqualToString:@"720*1280"]) {
        [_resolutionBtn setTitle:@"高清" forState:UIControlStateNormal];
    } else if ([resolution isEqualToString:@"480*640"]) {
        [_resolutionBtn setTitle:@"标清" forState:UIControlStateNormal];
    } else if ([resolution isEqualToString:@"288*352"]) {
        [_resolutionBtn setTitle:@"流畅" forState:UIControlStateNormal];
    }
    [encoder swapResolution];
    
    // 设置前后摄像头
    NSString *camera = [[NSUserDefaults standardUserDefaults] objectForKey:FBCamera];
    if (camera && [camera isEqualToString:@"后摄像头"]) {
        if (_cameraBtn.selected) {
            _cameraBtn.selected = NO;
            _cameraBtn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
            [encoder swapFrontAndBackCameras];
        }
    } else {
        if (!_cameraBtn.selected) {
            _cameraBtn.selected = YES;
            _cameraBtn.backgroundColor = UIColorFromRGB(0x368AFA);
            [encoder swapFrontAndBackCameras];
        }
    }
    
    if (isRunning && encoder) {
        dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [encoder startCamera:nil];
        });
    }
    
    AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (d.isEdit) {
        d.isEdit = NO;
        
        [DC_AlertManager showHudWithMessage:@"修改的配置已经生效" superView:self.bgView];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 横竖屏
    NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
    if ([orientation isEqualToString:@"横屏"]) {
        self.bgView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        self.bgView.transform = CGAffineTransformIdentity;
    }
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (isRunning && encoder) {
        dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [encoder stopCamera];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
    if ([orientation isEqualToString:@"横屏"]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UI

- (void) addItemView {
    CGFloat wh = 40;
    
    _backBtn = [[UIButton alloc] init];
    _backBtn.backgroundColor = UIColorFromRGB(0x368AFA);
    [_backBtn setImage:[UIImage imageNamed:@"setting_close"] forState:UIControlStateNormal];
    YYViewBorderRadius(_backBtn, 20, 0, [UIColor clearColor]);
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.top.equalTo(@20);
        make.right.equalTo(@(-20));
    }];
    
    UIButton *flashBtn = [[UIButton alloc] init];
    flashBtn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
    [flashBtn setImage:[UIImage imageNamed:@"pusher_flashe"] forState:UIControlStateNormal];
    YYViewBorderRadius(flashBtn, 20, 0, [UIColor clearColor]);
    [flashBtn addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:flashBtn];
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.bottom.equalTo(@(-30));
        make.left.equalTo(@((bgViewWidth / 4 - wh) / 2));
    }];
    
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc] init];
        _cameraBtn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
        [_cameraBtn setImage:[UIImage imageNamed:@"pusher_camera"] forState:UIControlStateNormal];
        YYViewBorderRadius(_cameraBtn, 20, 0, [UIColor clearColor]);
        [_cameraBtn addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.bgView addSubview:_cameraBtn];
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.bottom.equalTo(@(-30));
        make.left.equalTo(@((bgViewWidth / 4 - wh) / 2 + bgViewWidth / 4));
    }];
    
    _settingBtn = [[UIButton alloc] init];
    _settingBtn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
    [_settingBtn setImage:[UIImage imageNamed:@"pusher_settinge"] forState:UIControlStateNormal];
    YYViewBorderRadius(_settingBtn, 20, 0, [UIColor clearColor]);
    [_settingBtn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_settingBtn];
    [_settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.bottom.equalTo(@(-30));
        make.left.equalTo(@((bgViewWidth / 4 - wh) / 2 + bgViewWidth / 4 * 2));
    }];
    
    _playBtn = [[UIButton alloc] init];
    [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    YYViewBorderRadius(_playBtn, 20, 0, [UIColor clearColor]);
    [_playBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(wh));
        make.height.equalTo(@(wh));
        make.bottom.equalTo(@(-30));
        make.left.equalTo(@((bgViewWidth / 4 - wh) / 2 + bgViewWidth / 4 * 3));
    }];
}

- (void) addTopItemView {
    // 名称、观看人数
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = UIColorFromRGBA(0x000000, 0.45);
    
    CGFloat w = [self.live.Name getWidthWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(SCREEN_WIDTH, 18)] + 5;
    if (w < 70) {
        w = 70;
    } else if (w > SCREEN_WIDTH * 310.0 / 750.0) {
        w = SCREEN_WIDTH * 310.0 / 750.0;
    }
    
    w += 25;
    
    // 设置圆角
    CGRect frame = CGRectMake(0, 0, w, 60);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(25, 25)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = frame;// 设置大小
    maskLayer.path = maskPath.CGPath;// 设置图形样子
    leftView.layer.mask = maskLayer;
    [self.bgView addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@20);
        make.width.equalTo(@(w));
        make.height.equalTo(@60);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.live.Name;
    nameLabel.textColor = UIColorFromRGB(0xffffff);
    nameLabel.font = [UIFont systemFontOfSize:15];
    [leftView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@8);
        make.left.equalTo(@8);
        make.right.equalTo(@(-10));
    }];
    
    _onlineCountLabel = [[UILabel alloc] init];
    _onlineCountLabel.text = @"0";
    _onlineCountLabel.textColor = UIColorFromRGB(0x478bf6);
    _onlineCountLabel.font = [UIFont systemFontOfSize:12];
    [leftView addSubview:_onlineCountLabel];
    [_onlineCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-8));
        make.left.equalTo(@8);
    }];
    
    UILabel *personLabel = [[UILabel alloc] init];
    personLabel.text = @" 人正在看";
    personLabel.textColor = UIColorFromRGB(0xffffff);
    personLabel.font = [UIFont systemFontOfSize:12];
    [leftView addSubview:personLabel];
    [personLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_onlineCountLabel);
        make.left.equalTo(_onlineCountLabel.mas_right);
    }];
    
    // rateBtn
    _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rateBtn.enabled = NO;
    _rateBtn.backgroundColor = UIColorFromRGBA(0xffffff, 0.9);
    [_rateBtn setImage:[UIImage imageNamed:@"pusher_kb"] forState:UIControlStateNormal];
    [_rateBtn setTitle:@"  0KB/s" forState:UIControlStateNormal];
    [_rateBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    _rateBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    YYViewBorderRadius(_rateBtn, 12.5, 0, [UIColor clearColor]);
    [self.bgView addSubview:_rateBtn];
    [_rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right).offset(20);
        make.top.equalTo(@20);
        make.width.equalTo(@90);
        make.height.equalTo(@25);
    }];
    
    // timeBtn
    _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _timeBtn.enabled = NO;
    _timeBtn.hidden = YES;
    _timeBtn.backgroundColor = UIColorFromRGBA(0xffffff, 0.9);
    [_timeBtn setImage:[UIImage imageNamed:@"pusher_time"] forState:UIControlStateNormal];
    [_timeBtn setTitle:@"  00:00:00" forState:UIControlStateNormal];
    [_timeBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    _timeBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    YYViewBorderRadius(_timeBtn, 12.5, 0, [UIColor clearColor]);
    [self.bgView addSubview:_timeBtn];
    [_timeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_rateBtn);
        make.top.equalTo(_rateBtn.mas_bottom).offset(10);
        make.width.equalTo(@90);
        make.height.equalTo(@25);
    }];
    
    // 分辨率
    _resolutionBtn = [[UIButton alloc] init];
    _resolutionBtn.backgroundColor = UIColorFromRGBA(0x000000, 0.45);
    [_resolutionBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    YYViewBorderRadius(_resolutionBtn, 13, 0, [UIColor clearColor]);
    [_resolutionBtn addTarget:self action:@selector(showResolution) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_resolutionBtn];
    [_resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(leftView.mas_bottom).offset(20);
        make.width.equalTo(@50);
        make.height.equalTo(@26);
    }];
    
    _resolutionView = [[UIView alloc] init];
    _resolutionView.hidden = YES;
    _resolutionView.backgroundColor = UIColorFromRGBA(0x000000, 0.45);
    YYViewBorderRadius(_resolutionView, 5, 0, [UIColor clearColor]);
    [self.bgView addSubview:_resolutionView];
    [_resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_resolutionBtn);
        make.right.equalTo(_resolutionBtn);
        make.top.equalTo(_resolutionBtn.mas_bottom).offset(10);
        make.height.equalTo(@(28 * 4));
    }];
}

#pragma mark - click event

- (void) showResolution {
//    _resolutionView.hidden = NO;
//
//    for (UIView *v in [_resolutionView subviews]) {
//        [v removeFromSuperview];
//    }
//
//    NSArray *reso = @[ @"流畅", @"标清", @"高清", @"超清" ];
//    for (int i = 0; i < reso.count; i++) {
//        UIButton *btn = [[UIButton alloc] init];
//        [btn setTitle:reso[i] forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
//        [btn addTarget:self action:@selector(selectResolution:) forControlEvents:UIControlEventTouchUpInside];
//        [_resolutionView addSubview:btn];
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@28);
//            make.left.equalTo(@0);
//            make.right.equalTo(@0);
//            make.top.equalTo(@(28 * i));
//        }];
//
//        if ([reso[i] isEqualToString:_resolutionBtn.titleLabel.text]) {
//            [btn setTitleColor:UIColorFromRGB(0xff9900) forState:UIControlStateNormal];
//        } else {
//            [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
//        }
//    }
}

- (void) selectResolution:(UIButton *)btn {
    _resolutionView.hidden = YES;
    [_resolutionBtn setTitle:btn.titleLabel.text forState:UIControlStateNormal];
    
    if ([btn.titleLabel.text isEqualToString:@"流畅"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"288*352" forKey:resolition];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([btn.titleLabel.text isEqualToString:@"标清"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"480*640" forKey:resolition];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([btn.titleLabel.text isEqualToString:@"高清"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"720*1280" forKey:resolition];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"1080*1920" forKey:resolition];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [encoder swapResolution];
}

// 返回
- (void) back {
    if (isRunning) {
        QuitView *view = [[QuitView alloc] init];
        
        NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
        if ([orientation isEqualToString:@"横屏"]) {
            [view showViewWithUIView:self.bgView isPortrait:NO];
        } else {
            [view showViewWithUIView:self.bgView isPortrait:YES];
        }
        
        [view setQuitListener:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 闪光灯
- (void) flash:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        btn.backgroundColor = UIColorFromRGB(0x368AFA);
        
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    } else {
        btn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

// 前后摄像头
- (void) changeCamera:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) { // 前摄像头
        btn.backgroundColor = UIColorFromRGB(0x368AFA);
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:FBCamera];
    } else {
        btn.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
        
        [[NSUserDefaults standardUserDefaults] setObject:@"后摄像头" forKey:FBCamera];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [encoder swapFrontAndBackCameras];
}

// 设置
- (void) setting {
    SettingViewController *controller = [[SettingViewController alloc] initWithStoryboard];
    [self.navigationController pushViewController:controller animated:YES];
}

// 推流
- (void)startAction:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state) {
        // 获取联网状态
        switch (state) {
            case kCTCellularDataRestricted:
//                [weakSelf showAuthorityView];
                break;
            case kCTCellularDataNotRestricted:
//                NSLog(@"Not Restricted");
                break;
            case kCTCellularDataRestrictedStateUnknown: {
                [weakSelf showAuthorityView];
                return;
            }
                break;
            default:
                break;
        };
    };
    
    _resolutionView.hidden = YES;
    sender.selected = !sender.selected;
    isRunning = sender.selected;
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (isRunning) {
//            if (isClose) {
//                [encoder activate];
//            }
            
            [encoder startCamera:nil];
        } else {
            [encoder stopCamera];
        }
    });
}

#pragma mark - private method

- (void)showAuthorityView {
//    __weak typeof(self)weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NoNetNotifieViewController *vc = [[NoNetNotifieViewController alloc] init];
//            [weakSelf presentViewController:vc animated:YES completion:nil];
//        });
//    });
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 处理通知

- (void)someMethod:(NSNotification *)sender {
    if ([sender.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning && encoder) {
                dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
                dispatch_async(queue, ^{
                    [encoder activate];
                    [encoder startCamera:nil];
                });
            }
        });
    }
    
    if ([sender.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning && encoder) {
                [encoder stopCamera];
            }
        });
    }
}

#pragma mark - ConnectDelegate

- (void)getConnectStatus:(NSString *)status isFist:(int)tag {
    if (tag == 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DC_AlertManager showHudWithMessage:[NSString stringWithFormat:@"%@",status] superView:self.bgView];
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([status isEqualToString:@"断开连接"] ||
                    [status isEqualToString:@"连接成功"] ||
                    [status isEqualToString:@"连接中"] ||
                    [status isEqualToString:@"推流中"]) {
                    [DC_AlertManager showHudWithMessage:status superView:self.bgView];
                }
                
                if ([status isEqualToString:@"断开连接"]
                    || [status isEqualToString:@"推流中"]
                    || [status isEqualToString:@"连接成功"]) {
                    _settingBtn.enabled = YES;
                    _backBtn.enabled = YES;
                } else {
                    _settingBtn.enabled = NO;
                    _backBtn.enabled = NO;
                }
                
                if ([status isEqualToString:@"推流中"]) {
                    _playBtn.selected = YES;
                    _timeBtn.hidden = NO;
                    _timeCount = 0;
//                    isClose = NO;
                    
                    // 开启定时器
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushingTime) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                } else {
                    _timeBtn.hidden = YES;
                    
                    // 关闭定时器
                    [self.timer invalidate];
                    self.timer = nil;
                }
                
                if ([status isEqualToString:@"断开连接"]) {
//                    isClose = YES;
                    _playBtn.selected = NO;
                    [encoder stopCamera];
                    
                    _resolutionBtn.enabled = YES;
                } else {
                    _resolutionBtn.enabled = NO;
                }
                
                if ([status isEqualToString:@"连接异常中断"]) {
//                    isClose = YES;
                    _playBtn.selected = NO;
                }
                
                if ([status isEqualToString:@"连接中"]) {
                    _playBtn.enabled = NO;
                } else {
                    _playBtn.enabled = YES;
                }
            });
        });
    }
}

- (void) sendPacketFrameLength:(unsigned int)length {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *t = [NSString stringWithFormat:@"  %dKB/s", length / 1024];
        [_rateBtn setTitle:t forState:UIControlStateNormal];
    });
}

- (void) pushingTime {
    _timeCount++;
    
    int hour = _timeCount / 3600;
    int minute = (_timeCount - hour * 3600) / 60;
    int second = _timeCount - hour * 3600 - minute * 60;
    
    NSString *hourStr;
    if (hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%d", hour];
    } else {
        hourStr = [NSString stringWithFormat:@"%d", hour];
    }
    
    NSString *minuteStr;
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%d", minute];
    } else {
        minuteStr = [NSString stringWithFormat:@"%d", minute];
    }
    
    NSString *secondStr;
    if (second < 10) {
        secondStr = [NSString stringWithFormat:@"0%d", second];
    } else {
        secondStr = [NSString stringWithFormat:@"%d", second];
    }
    
    [_timeBtn setTitle:[NSString stringWithFormat:@"  %@:%@:%@", hourStr, minuteStr, secondStr] forState:UIControlStateNormal];
    
    if ((_timeCount % 10) == 0) {
        NSString *url = [NSString stringWithFormat:@"%@/Integration/SDS/DSIS/DSISService.asmx", [[AccountLocalData sharedInstance] address]];
        [self webServiceConnectionWithUrl:url
                            liveChannelId:self.live.PkId
                                nameSpace:@"http://tempuri.org/"
                                   method:@"GetLiveStatus"];
    }
}

#pragma mark - network

- (void)webServiceConnectionWithUrl:(NSString *)urlStr liveChannelId:(NSString *)liveChannelId nameSpace:(NSString *)nameSpace method:(NSString *)method {
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "<liveChannelId>%@</liveChannelId>\n"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", method, nameSpace, liveChannelId, method];
//    NSLog(@"%@", soapMsg);
    
    // 创建URL
    NSURL *url = [NSURL URLWithString: urlStr];
    // 计算出soap所有的长度，配置头使用
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    // 创建request请求，把请求需要的参数配置
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    // 请求的参数配置，不用修改
    [request setTimeoutInterval:10];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    // soapAction的配置
    [request setValue:[NSString stringWithFormat:@"%@%@", nameSpace, method] forHTTPHeaderField:@"SOAPAction"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 创建连接
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
//            NSLog(@"失败%@", error.localizedDescription);
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
//            NSLog(@"结果：%@\n请求地址：%@", result, response.URL);
            
            // 系统自带的
            NSXMLParser *par = [[NSXMLParser alloc] initWithData:[result dataUsingEncoding:NSUTF8StringEncoding]];
            [par setDelegate:self];// 设置NSXMLParser对象的解析方法代理
            [par parse];// 调用代理解析NSXMLParser对象，看解析是否成功
        }
    }];
    
    [task resume];
}

#pragma mark - NSXMLParserDelegate

// 获取节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 用”,”分割后的第一位是   0是无流，1是有流    ;第二位是正在观看直播的人数
        NSArray *arr = [str componentsSeparatedByString:@","];
        _onlineCountLabel.text = arr[1];
    });
}

@end
