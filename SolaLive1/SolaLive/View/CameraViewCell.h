//
//  CameraViewCell.h
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveModel.h"

@interface CameraViewCell : UITableViewCell

@property (nonatomic, retain) LiveModel *model;

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *idLabel;
@property (nonatomic, retain) UILabel *onlineLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *iv;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
