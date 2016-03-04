//
//  UserModel.h
//  YXDatabaseHandleDemo
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#define APPDelegate ((AppDelegate*)[[UIApplication sharedApplication]delegate])

#import <UIKit/UIKit.h>
#import "YXRootModel.h"
@class CompanyModel;
@class EmployeeModel;

@interface UserModel : YXRootModel

@property (nonatomic,copy) NSString* userId;
@property (nonatomic,copy) NSString*userName;
@property (nonatomic,copy) NSString*password;
@property (nonatomic,strong) NSDate*birthDay;
@property (nonatomic,assign) NSInteger roleId;
@property (nonatomic,assign) NSInteger integral;
@property (nonatomic,assign) CGFloat accountMoney;
@property (nonatomic,assign) NSInteger sex;
@property (nonatomic,assign) BOOL isVip;

@property (nonatomic,strong) CompanyModel* company;
@property (nonatomic,strong) NSArray* employees;

@end
