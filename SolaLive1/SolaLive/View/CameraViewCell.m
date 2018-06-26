//
//  CameraViewCell.m
//  SolaLive
//
//  Created by liyy on 2018/2/26.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "CameraViewCell.h"

@implementation CameraViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"CameraViewCell";
    // 1.缓存中
    CameraViewCell *cell = [[CameraViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/**
 *  构造方法(在初始化对象的时候会调用)
 *  一般在这个方法中添加需要显示的子控件
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColorFromRGB(0xffffff);
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"手机直播";
        _nameLabel.textColor = UIColorFromRGB(0x3b4a5d);
        _nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.left.equalTo(@15);
        }];
        
        _idLabel = [[UILabel alloc] init];
        _idLabel.text = @"直播间ID：3";
        _idLabel.textColor = UIColorFromRGB(0x8b8b8b);
        _idLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_idLabel];
        [_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nameLabel.mas_bottom).offset(12);
            make.left.equalTo(_nameLabel);
        }];
        
        UILabel *personLabel = [[UILabel alloc] init];
        personLabel.text = @"人正在看";
        personLabel.textColor = UIColorFromRGB(0x8b8b8b);
        personLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:personLabel];
        [personLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_idLabel);
            make.right.equalTo(@(-15));
        }];
        
        _onlineLabel = [[UILabel alloc] init];
        _onlineLabel.text = @"0";
        _onlineLabel.textColor = UIColorFromRGB(0x478bf6);
        _onlineLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_onlineLabel];
        [_onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_idLabel);
            make.right.equalTo(personLabel.mas_left);
        }];
        
        _iv = [[UIImageView alloc] init];
        _iv.backgroundColor = [UIColor grayColor];
        _iv.image = [UIImage imageNamed:@"live_list_logo"];
        _iv.contentMode = UIViewContentModeCenter;
        [self addSubview:_iv];
        [_iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(_idLabel.mas_bottom).offset(10);
            make.height.equalTo(@(400.0 * SCREEN_WIDTH / 750.0));
        }];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.text = @"● 直播中";
        _statusLabel.textColor = UIColorFromRGB(0xffffff);
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.backgroundColor = UIColorFromRGB(0xff0000);
        YYViewBorderRadius(_statusLabel, 10, 0, [UIColor clearColor]);
        [self addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iv.mas_top).offset(10);
            make.right.equalTo(@(-15));
            make.width.equalTo(@60);
            make.height.equalTo(@20);
        }];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = UIColorFromRGB(0xeeeeee);
        [self addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(_iv.mas_bottom);
            make.height.equalTo(@8);
        }];
    }
    
    return self;
}

- (void) setModel:(LiveModel *)model {
    _nameLabel.text = model.Name;
    _idLabel.text = [NSString stringWithFormat:@"直播间ID：%@", model.PkId];
    _onlineLabel.text = model.ClientCount;
    
    // 0:无直播; 1:有直播    是否正在直播
    if ([model.Status isEqualToString:@"1"]) {
        _statusLabel.text = @"● 直播中";
        _statusLabel.backgroundColor = UIColorFromRGB(0xff0000);
    } else {
        _statusLabel.text = @"● 离线";
        _statusLabel.backgroundColor = UIColorFromRGB(0x999999);
    }
}

@end
