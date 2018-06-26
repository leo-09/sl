//
//  OrgModel.h
//  SolaLive
//
//  Created by mac on 2018/6/23.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrgModel : NSObject

@property (nonatomic, copy) NSString *PkId;
@property (nonatomic, copy) NSString *Code;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *OrgType;
@property (nonatomic, copy) NSString *OrgTypeSeg;
@property (nonatomic, copy) NSString *Province;
@property (nonatomic, copy) NSString *ProvinceName;
@property (nonatomic, copy) NSString *City;
@property (nonatomic, copy) NSString *CityName;
@property (nonatomic, copy) NSString *District;
@property (nonatomic, copy) NSString *DistrictName;
@property (nonatomic, copy) NSString *Address;
@property (nonatomic, copy) NSString *ManageUserId;
@property (nonatomic, copy) NSString *ContactUser;
@property (nonatomic, copy) NSString *ContactTel;
@property (nonatomic, copy) NSString *ContactEmail;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *CreateType;
@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *SpsServiceStaus;
@property (nonatomic, copy) NSString *IsOpenNodeService;

@end
