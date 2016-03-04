//
//  YXDatabaseHandle+Update.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle.h"

@interface YXDatabaseHandle (Update)
/**
 *  根据唯一列更新某个模型
 *
 *  @param model          模型对象
 *  @param primarykeyName 唯一列名
 */
-(void)updateModel:(id)model primarykeyName:(NSString*)primarykeyName;
/**
 *  更新模型
 *
 *  @param model      模型对象
 *  @param whereArray 条件数组 如:@[@"companyName = '阿狗科技' or @"companyName = '阿猫软件'",@"employeeCount = 100"]
 */
-(void)updateModel:(id)model whereArray:(NSArray*)whereArray;

@end
