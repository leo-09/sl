//
//  CompanyViewController.m
//  SolaLive
//
//  Created by liyy on 2018/6/19.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "CompanyViewController.h"
#import "CameraViewController.h"
#import "AccountLocalData.h"
#import "MBProgressHUD.h"
#import "OrgModel.h"
#import "Util.h"
#import "DC_AlertManager.h"

@interface CompanyViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, retain) NSMutableString *resultStr;

@property (nonatomic, retain) NSArray *orgs;
@property (nonatomic, retain) NSMutableArray *btns;
@property (nonatomic, assign) int curIndex;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *pages;

@property (nonatomic, strong) UIScrollView *sv;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation CompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = @"直播列表";
    
    if (self.isPlay) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
        [backBtn setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    }
    
    // 初始化进度框，置于当前的View当中
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    // 设置对话框文字
    self.hud.label.text = @"获取单位列表";
    // 细节文字
    _hud.detailsLabel.text = @"请耐心等待";
    [self.view addSubview:_hud];
    [_hud showAnimated:YES];
    
    [self query];
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

- (void) query {
    self.resultStr = [[NSMutableString alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/Integration/SDS/DSIS/DSISService.asmx", [[AccountLocalData sharedInstance] address]];
    
    NSString *userName = [[AccountLocalData sharedInstance] userName];
    if (!userName || [userName isEqualToString:@""]) {
        userName = @"admin";
    }
    
    [self webServiceConnectionWithUrl:url userName:userName
                            nameSpace:@"http://tempuri.org/"
                               method:@"GetOperateOrgList"];
}

#pragma mark - network

- (void)webServiceConnectionWithUrl:(NSString *)urlStr userName:(NSString *)userName nameSpace:(NSString *)nameSpace method:(NSString *)method {
    
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "<loginName>%@</loginName>\n"
                         "<loginPwd>%@</loginPwd>\n"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", method, nameSpace, [[AccountLocalData sharedInstance] userName], [[AccountLocalData sharedInstance] userPsw], method];
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
                if (self.hud) {
                    [self.hud removeFromSuperview];
                    self.hud = nil;
                }
            });
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
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
        if (self.hud) {
            [self.hud removeFromSuperview];
            self.hud = nil;
        }
        
        NSDictionary *dict = [Util dictionaryWithJsonString:self.resultStr];
        self.orgs = [OrgModel mj_objectArrayWithKeyValuesArray:dict];
//        NSArray *aa = [OrgModel mj_objectArrayWithKeyValuesArray:dict];
//        self.orgs = @[ aa.firstObject, aa.firstObject, aa.firstObject ];
        
        [self addItemView];
        [self addPageView];
    });
}

// 解析出错，清理所有得到的解析结果
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud) {
            // 操作执行完后取消对话框
            [self.hud removeFromSuperview];
            self.hud = nil;
        }
        
        [DC_AlertManager showHudWithMessage:@"数据出错！" superView:self.view];
    });
}

#pragma mark - UI

- (void) addItemView {
    CGFloat svHeight = 50;
    
    self.sv = [[UIScrollView alloc] init];
    self.sv.backgroundColor = UIColorFromRGB(0xffffff);
    [self.view addSubview:self.sv];
    [self.sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(@(HeaderBar_Height));
        make.height.equalTo(@(svHeight));
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [self.sv addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sv);
        make.height.equalTo(@(svHeight));
    }];
    
    self.btns = [[NSMutableArray alloc] init];
    UIButton *lastBtn;
    for (int i = 0; i < self.orgs.count; i++) {
        OrgModel *org = self.orgs[i];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:[NSString stringWithFormat:@"  %@  ", org.Name] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        YYViewBorderRadius(btn, 3, 0, [UIColor clearColor]);
        
        btn.tag = i;
        [btn addTarget:self action:@selector(selectOrg:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            self.curIndex = 0;
            [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0x368AFA);
        } else {
            [btn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        }
        
        [contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contentView);
            
            if (lastBtn) {
                make.left.equalTo(lastBtn.mas_right).offset(15);
            } else {
                make.left.equalTo(@15);
            }
        }];
        
        lastBtn = btn;
        [self.btns addObject:btn];
    }
    
    if (lastBtn) {
        [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lastBtn.mas_right).offset(15);
        }];
    }
}

- (void) addPageView {
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(self.self.sv.mas_bottom);
    }];
    
    // 添加子ViewController
    for (OrgModel *org in self.orgs) {
        CameraViewController *vc = [[CameraViewController alloc] init];
        vc.operateOrgId = org.PkId;
        vc.isPlay = self.isPlay;
        [self.pages addObject:vc];
    }
    
    // 添加子View
    [self addChildViewController:self.pageViewController];
    [self.containerView addSubview:self.pageViewController.view];
    
    // 跳转到第一个controller
    if ([self.pages count] > self.curIndex) {
        [self.pageViewController setViewControllers:@[self.pages[self.curIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
}

- (void) selectOrg:(UIButton *)btn {
    int index = (int)btn.tag;
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionReverse;
    if (index >= self.curIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    [self.pageViewController setViewControllers:@[self.pages[index]] direction:direction animated:YES completion:NULL];
    
    UIButton *curBtn = self.btns[self.curIndex];
    [curBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    curBtn.backgroundColor = UIColorFromRGB(0xffffff);
    self.curIndex = index;
    curBtn = self.btns[self.curIndex];
    [curBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    curBtn.backgroundColor = UIColorFromRGB(0x368AFA);
}

#pragma mark - getter/setter

- (NSMutableArray *)pages {
    if (!_pages) {
        _pages = [[NSMutableArray alloc] init];
    }
    return _pages;
}

- (UIPageViewController *) pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
        [_pageViewController setDataSource:self];
        [_pageViewController setDelegate:self];
        [_pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    }
    
    return _pageViewController;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    return self.pages[--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound)||(index+1 >= [self.pages count])) {
        return nil;
    }
    
    return self.pages[++index];
}

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        return;
    }
    
    UIButton *curBtn = self.btns[self.curIndex];
    [curBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    
    self.curIndex = (int)[self.pages indexOfObject:[viewController.viewControllers lastObject]];
    curBtn = self.btns[self.curIndex];
    [curBtn setTitleColor:UIColorFromRGB(0x368AFA) forState:UIControlStateNormal];
}

@end
