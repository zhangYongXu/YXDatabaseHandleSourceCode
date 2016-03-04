//
//  UserModel.m
//  YXDatabaseHandleDemo
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import "UserModel.h"
#import "EmployeeModel.h"
#import "CompanyModel.h"
@implementation UserModel
-(void)setCompany:(CompanyModel *)company{
    if(nil != company && [company isKindOfClass:[NSDictionary class]]){
        _company = [[CompanyModel alloc] initWithDictionary:(NSDictionary*)company];
    }else{
        _company = company;
    }
}
-(void)setEmployees:(NSArray *)employees{
    if(nil != employees && employees.count>0 && [employees.lastObject isKindOfClass:[NSDictionary class]]){
        _employees = [EmployeeModel modelArrayFromDictArray:employees];
    }else{
        _employees = employees;
    }
}


@end
