//
//  RateViewController.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "RateViewController.h"
#import "AppDelegate.h"

@interface RateViewController () {
    int rateIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *iv0;
@property (weak, nonatomic) IBOutlet UIImageView *iv1;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;
@property (weak, nonatomic) IBOutlet UIImageView *iv3;

@end

@implementation RateViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RateViewController"];
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置默认码率";
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    _iv0.hidden = YES;
    _iv1.hidden = YES;
    _iv2.hidden = YES;
    _iv3.hidden = YES;
    
    NSString *rate = [[NSUserDefaults standardUserDefaults] objectForKey:Rate];
    if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 500 * 1000]]) {
        _iv0.hidden = NO;
        rateIndex = 0;
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 800 * 1000]]) {
        _iv1.hidden = NO;
        rateIndex = 1;
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 1500 * 1000]]) {
        _iv2.hidden = NO;
        rateIndex = 2;
    } else if ([rate isEqualToString:[NSString stringWithFormat:@"%d", 52500 * 1000]]) {
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
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 500 * 1000] forKey:Rate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 1:{
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 800 * 1000] forKey:Rate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 2:{
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 1500 * 1000] forKey:Rate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 3:{
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 52500 * 1000] forKey:Rate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        default:
            break;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
