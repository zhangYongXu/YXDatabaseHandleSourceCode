//
//  AppDelegate.h
//  YXDatabaseHandlle
//
//  Created by 拓之林 on 16/3/2.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "CompanyModel.h"
#import "EmployeeModel.h"
#import "YXDatabaseHandle.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong,readonly) YXDatabaseHandle * dbHandle;
@end

