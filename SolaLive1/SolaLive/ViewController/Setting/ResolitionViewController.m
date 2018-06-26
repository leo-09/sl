//
//  ResolitionViewController.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "ResolitionViewController.h"
#import "AppDelegate.h"

@interface ResolitionViewController () {
    int rateIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *iv0;
@property (weak, nonatomic) IBOutlet UIImageView *iv1;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;
@property (weak, nonatomic) IBOutlet UIImageView *iv3;

@end

@implementation ResolitionViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ResolitionViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置默认分辨率";
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    _iv0.hidden = YES;
    _iv1.hidden = YES;
    _iv2.hidden = YES;
    _iv3.hidden = YES;
    
    NSString *resolution = [[NSUserDefaults standardUserDefaults] objectForKey:resolition];
    if ([resolution isEqualToString:@"1080*1920"]) {
        _iv0.hidden = NO;
        rateIndex = 0;
    } else if ([resolution isEqualToString:@"720*1280"]) {
        _iv1.hidden = NO;
        rateIndex = 1;
    } else if ([resolution isEqualToString:@"480*640"]) {
        _iv2.hidden = NO;
        rateIndex = 2;
    } else if ([resolution isEqualToString:@"288*352"]) {
        _iv3.hidden = NO;
        rateIndex = 3;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click event

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != rateIndex) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.isEdit = YES;
    }
    
    switch (indexPath.row) {
        case 0:{
            [[NSUserDefaults standardUserDefaults] setObject:@"1080*1920" forKey:resolition];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 1:{
            [[NSUserDefaults standardUserDefaults] setObject:@"720*1280" forKey:resolition];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 2:{
            [[NSUserDefaults standardUserDefaults] setObject:@"480*640" forKey:resolition];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 3:{
            [[NSUserDefaults standardUserDefaults] setObject:@"288*352" forKey:resolition];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        default:
            break;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
