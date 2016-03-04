//
//  EmployeeModel.h
//  YXDatabaseHandleDemo
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXRootModel.h"

@interface EmployeeModel : YXRootModel
@property (nonatomic,copy)NSString* userId;
@property (nonatomic,assign) NSInteger employeeId;
@property (nonatomic,copy)NSString* employeeCode;
@property (nonatomic,copy)NSString* name;
@property (nonatomic,assign) NSInteger sex;
@property (nonatomic,strong)NSDate*birthDay;
@property (nonatomic,copy)NSString*address;
@end
