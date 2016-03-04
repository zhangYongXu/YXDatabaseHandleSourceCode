//
//  CompanyModel.h
//  YXDatabaseHandleDemo
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXRootModel.h"
@interface CompanyModel : YXRootModel
@property (nonatomic,copy)NSString* userId;
@property (nonatomic,assign)NSInteger companyId;
@property (nonatomic,copy)NSString* companyName;
@property (nonatomic,assign)NSInteger companyType;
@property (nonatomic,copy)NSString* address;
@property (nonatomic,strong)NSDate* registerDate;
@end
