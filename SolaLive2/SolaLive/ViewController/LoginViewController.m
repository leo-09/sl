//
//  ViewController.m
//  PhoneLive
//
//  Created by liyy on 2018/2/1.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "LoginViewController.h"
#import "CompanyViewController.h"
#import "AccountLocalData.h"
#import "DC_AlertManager.h"
#import "BaseNetData.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()<NSXMLParserDelegate>

@property (nonatomic, retain) MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *pswView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UIButton *showPsw;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (![[AccountLocalData sharedInstance] address]) {
        [[AccountLocalData sharedInstance] setAddress:@"http://www.ibo100.com"];
    }
    
    if (SCREEN_HEIGHT < 620) {
        _contentViewHeight.constant = 620;
    } else {
        _contentViewHeight.constant = SCREEN_HEIGHT;
    }
    
    [_showPsw setImage:[UIImage imageNamed:@"login_show_psw"] forState:UIControlStateSelected];
    [_showPsw setImage:[UIImage imageNamed:@"login_hide_psw"] forState:UIControlStateNormal];
    
    YYViewBorderRadius(_addressView, 20, 1, UIColorFromRGB(0xcddaeb));
    YYViewBorderRadius(_nameView, 20, 1, UIColorFromRGB(0xcddaeb));
    YYViewBorderRadius(_pswView, 20, 1, UIColorFromRGB(0xcddaeb));
    YYViewBorderRadius(_loginBtn, 20, 0, UIColorFromRGB(0xffffff));
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    _addressTF.text = [[AccountLocalData sharedInstance] address];
    _nameTF.text = [[AccountLocalData sharedInstance] userName];
    _pswTF.text = [[AccountLocalData sharedInstance] userPsw];
    
//    _nameTF.text = @"18872848512";
//    _pswTF.text = @"123456";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click event

- (IBAction)showPsw:(id)sender {
    _showPsw.selected = !_showPsw.selected;
    
    if (_showPsw.selected) {
        _pswTF.secureTextEntry = NO;
    } else {
        _pswTF.secureTextEntry = YES;
    }
}

- (IBAction)login:(id)sender {
    if ([_addressTF.text isEqualToString:@""]) {
        [DC_AlertManager showHudWithMessage:@"请输入平台地址" superView:self.view];
        return;
    }
    
    if ([_nameTF.text isEqualToString:@""]) {
        [DC_AlertManager showHudWithMessage:@"请输入账号" superView:self.view];
        return;
    }
    
    if ([_pswTF.text isEqualToString:@""]) {
        [DC_AlertManager showHudWithMessage:@"请输入密码" superView:self.view];
        return;
    }
    
    // 初始化进度框，置于当前的View当中
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    //如果设置此属性则当前的view置于后台
//    _hud.dimBackground = YES;
    //设置对话框文字
    _hud.label.text = @"加载中";
    //细节文字
    _hud.detailsLabel.text = @"请耐心等待";
    [self.view addSubview:_hud];
    [_hud showAnimated:YES];
    
    NSString *addr = _addressTF.text;
    if (![[addr substringToIndex:7] isEqualToString:@"http://"]) {
        addr = [NSString stringWithFormat:@"http://%@", addr];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/Integration/SDS/Base/BaseService.asmx", addr];
    [self webServiceConnectionWithUrl:url userName:_nameTF.text pwd:_pswTF.text nameSpace:@"http://tempuri.org/" method:@"CheckLoginUserForOperateOrg"];
    
    [[AccountLocalData sharedInstance] setAddress:addr];
    [[AccountLocalData sharedInstance] setUserName:_nameTF.text];
    [[AccountLocalData sharedInstance] setUserPsw:_pswTF.text];
}

- (IBAction)play:(id)sender {
    if ([_addressTF.text isEqualToString:@""]) {
        [DC_AlertManager showHudWithMessage:@"请输入平台地址" superView:self.view];
        return;
    }
    
    NSString *addr = _addressTF.text;
    if (![[addr substringToIndex:7] isEqualToString:@"http://"]) {
        addr = [NSString stringWithFormat:@"http://%@", addr];
    }
    
    //    NSString *url = [NSString stringWithFormat:@"%@/Integration/SDS/Base/BaseService.asmx", addr];
    //    [self webServiceConnectionWithUrl:url userName:_nameTF.text pwd:_pswTF.text nameSpace:@"http://tempuri.org/" method:@"CheckLoginUserForOperateOrg"];
    
    [[AccountLocalData sharedInstance] setAddress:addr];
    [[AccountLocalData sharedInstance] setUserName:_nameTF.text];
    [[AccountLocalData sharedInstance] setUserPsw:_pswTF.text];
    
    CompanyViewController *controller = [[CompanyViewController alloc] init];
    controller.isPlay = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - network

- (void)webServiceConnectionWithUrl:(NSString *)urlStr userName:(NSString *)userName pwd:(NSString *)pwd nameSpace:(NSString *)nameSpace method:(NSString *)method {
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "<userName>%@</userName>\n"
                         "<pwd>%@</pwd>\n"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", method, nameSpace, userName, pwd, method];
        NSLog(@"%@", soapMsg);
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 操作执行完后取消对话框
            [self.hud removeFromSuperview];
            self.hud = nil;
        });
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DC_AlertManager showHudWithMessage:@"平台地址或网络出错" superView:self.view];
            });
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"结果：%@\n请求地址：%@", result, response.URL);
            
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
        if ([str isEqualToString:@"true"]) {
            CompanyViewController *controller = [[CompanyViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [DC_AlertManager showHudWithMessage:@"账号或密码出错！" superView:self.view];
        }
    });
}

@end
