//
//  EmployeeModel.m
//  YXDatabaseHandleDemo
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import "EmployeeModel.h"

@implementation EmployeeModel
-(NSDictionary *)propertyKeyMappingDictionary{
    return @{@"code":@"employeeCode",@"code":@"employeeId"};
}
@end
