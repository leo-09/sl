//
//  CameraViewController.m
//  PhoneLive
//
//  Created by liyy on 2018/2/6.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "CameraViewController.h"
#import "PushViewController.h"
#import "LiveViewController.h"
#import "CameraViewCell.h"
#import "MBProgressHUD.h"
#import "AccountLocalData.h"
#import "LiveModel.h"
#import "NoLiveView.h"
#import "Util.h"

@interface CameraViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, retain) NoLiveView *noLiveView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headerLabel;

@property (nonatomic, retain) NSMutableString *resultStr;
@property (nonatomic, retain) NSArray *lives;

@property (nonatomic, assign) BOOL isPush;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = @"直播列表";
    
    if (self.isPlay) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
        [backBtn setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    // 刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self query];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isPush = NO;
    
    // 初始化进度框，置于当前的View当中
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    // 设置对话框文字
    _hud.label.text = @"获取直播列表";
    // 细节文字
    _hud.detailsLabel.text = @"请耐心等待";
    [self.view addSubview:_hud];
    [_hud showAnimated:YES];
    
    [self query];
}

- (void) query {
    self.resultStr = [[NSMutableString alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/Integration/SDS/DSIS/DSISService.asmx", [[AccountLocalData sharedInstance] address]];
    
    NSString *userName = [[AccountLocalData sharedInstance] userName];
    if (!userName || [userName isEqualToString:@""]) {
        userName = @"admin";
    }
    
    [self webServiceConnectionWithUrl:url userName:userName
                            nameSpace:@"http://tempuri.org/"
                               method:@"GetLiveChannelListForPhone"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click event

- (void) back {
    if (self.isPlay) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lives.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CameraViewCell *cell = [CameraViewCell cellWithTableView:tableView];
    cell.model = self.lives[indexPath.row];
    
    if (self.isPlay) {
        cell.iv.image = [UIImage imageNamed:@""];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 400.0 * SCREEN_WIDTH / 750.0 + 65 + 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.backgroundColor = UIColorFromRGB(0xeeeeee);
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    _headerLabel.textColor = UIColorFromRGB(0x8b8b8b);
    _headerLabel.font = [UIFont systemFontOfSize:12];
    
    if (self.lives.count) {
        _headerLabel.text = [NSString stringWithFormat:@"当前共有%lu个频道直播", (unsigned long)self.lives.count];
    }
    
    return _headerLabel;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isPush) {
        return;
    }
    
    LiveModel *model = self.lives[indexPath.row];
    
    if (self.isPlay) {
        // 0:无直播; 1:有直播    是否正在直播
        if ([model.Status isEqualToString:@"1"]) {
            // 有直播，则播放
            LiveViewController *controller = [[LiveViewController alloc] init];
            controller.live = model;
            self.isPush = YES;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            if (!_noLiveView) {
                _noLiveView = [[NoLiveView alloc] init];
            }
            [_noLiveView showView];
        }
    } else {
        // 0:无直播; 1:有直播    是否正在直播
        if ([model.Status isEqualToString:@"0"]) {
            PushViewController *controller = [[PushViewController alloc] init];
            controller.live = model;
            self.isPush = YES;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            // 有直播，则播放
            LiveViewController *controller = [[LiveViewController alloc] init];
            controller.live = model;
            self.isPush = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - network

- (void)webServiceConnectionWithUrl:(NSString *)urlStr userName:(NSString *)userName nameSpace:(NSString *)nameSpace method:(NSString *)method {
    
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "<userName>%@</userName>\n"
                         "<url>%@</url>\n"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", method, nameSpace, userName, urlStr, method];
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
        if (error) {
            NSLog(@"失败%@", error.localizedDescription);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_hud) {
                    [_hud removeFromSuperview];
                    _hud = nil;
                }
            });
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

// 这个方法是被循环调用的，作用是返回每一个节点的内容（键值对中的值）
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str {
    [self.resultStr appendString:str];
}

// 这是终点，在这里处理数据
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_hud) {
            [_hud removeFromSuperview];
            _hud = nil;
        }
        
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *dict = [Util dictionaryWithJsonString:self.resultStr];
        self.lives = [LiveModel mj_objectArrayWithKeyValuesArray:dict];
        [self.tableView reloadData];
    });
}

// 解析出错，清理所有得到的解析结果
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_hud) {
            // 操作执行完后取消对话框
            [_hud removeFromSuperview];
            _hud = nil;
        }
        
        [self.tableView.mj_header endRefreshing];
    });
}

@end
