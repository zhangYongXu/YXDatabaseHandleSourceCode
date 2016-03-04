//
//  YXDatabaseHandle+Select.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle.h"

@interface YXDatabaseHandle (Select)
/**
 *  读取某个类的所有模型数据
 *
 *  @param aclass 模型类
 *
 *  @return 模型数组
 */
-(NSArray*)readArray:(Class)aclass;

/**
 *  根据条件读取某个类的模型数据
 *
 *  @param aclass     模型类
 *  @param whereArray 条件数组 如：@[@"name like '%@%@李四%@%@'",@"score = 89"]
 *
 *  @return 模型数组
 */
-(NSArray*)readyArray:(Class)aclass whereArray:(NSArray*)whereArray;

/**
 *  分页读取某个类的模型数据
 *
 *  @param aclass 模型类
 *  @param page   页码
 *  @param size   也大小
 *
 *  @return 模型数组
 */
-(NSArray*)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size;

/**
 *  按条件分页读取某个模型的数据
 *
 *  @param aclass     模型类
 *  @param page       页码
 *  @param size       页大小
 *  @param whereArray 条件数组 如：@[@"name like '%@%@李四%@%@'",@"score = 89"]
 *
 *  @return 模型数组
 */
-(NSArray*)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size whereArray:(NSArray*)whereArray;

/**
 *  读取某个模型的数据 并排序
 *
 *  @param aclass    模型类
 *  @param orderBy   排序字段
 *  @param orderType 排序方式
 *
 *  @return 模型数组
 */
-(NSArray*)readArray:(Class)aclass OrderBy:(NSString*)orderBy OrderType:(OrderType)orderType;

/**
 *  按条件读取某个模型的数据 并排序
 *
 *  @param  aclass    模型类
 *  @param  orderBy   排序字段
 *  @param  orderType 排序方式
 *  @param  whereArray 条件数组 如：@[@"name like '%@%@李四%@%@'",@"score = 89"]
 *  @return 模型数组
 */
-(NSArray*)readArray:(Class)aclass OrderBy:(NSString*)orderBy OrderType:(OrderType)orderType whereArray:(NSArray*)whereArray;

/**
 *  根据sql读数据
 *
 *  @param  sql sql语句
 *
 *  @return 字典数据
 */
-(NSArray*)readArrayBySql:(NSString*)sql;
@end
