//
//  YXDatabaseHandle+Delete.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle.h"

@interface YXDatabaseHandle (Delete)
/**
 *  删除模型
 *
 *  @param model 模型对象
 */
-(void)deleteModel:(id)model;

/**
 *  根据唯一性字段删除某一个模型实体记录
 *
 *  @param model          模型对象
 *  @param primarykeyName 唯一性字段名
 */
-(void)deleteModel:(id)model primarykeyName:(NSString*)primarykeyName;

/**
 *  根据条件删除某个模型数据
 *
 *  @param aclass    模型类
 *  @param whereArray 条件数组 如：@[@"name like '%@%@李四%@%@'",@"score = 89"]
 */
-(void)deleteClass:(Class)aclass whereArray:(NSArray*)whereArray;

@end
