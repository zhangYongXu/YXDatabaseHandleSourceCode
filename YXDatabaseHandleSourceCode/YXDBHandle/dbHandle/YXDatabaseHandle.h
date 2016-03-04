//
//  YXDatabaseHandle.h
//  Echo
//
//  Created by BZBY on 15/3/25.
//  Copyright (c) 2015年 Static Ga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXTypedefine.h"
@class FMDatabase;

@class YXTableInfo;


@interface YXDatabaseHandle : NSObject
@property(strong, nonatomic,readonly) FMDatabase* database;
//数据库中表信息
@property(strong, nonatomic,readonly) NSMutableDictionary * tablesDict;
/**
 *  获得数据库操作类单例对象
 *
 *  @return 数据库操作单例
 */
+(YXDatabaseHandle*)shareInstance;
/**
 *  是否打印信息
 *
 *  @return 是否打印信息
 */
+(BOOL)YXDatabaseHandleIsShowLogs;
/**
 *  设置是否打印信息
 *
 *  @param isShowLogs 是否打印信息
 */
+(void)setYXDatabaseHandleIsShowLogs:(BOOL)isShowLogs;
/**
 *  注册需要缓存到数据库的模型
 *
 *  @param aclass                模型类
 *  @param mappingType           表字段映射方式
 */
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType;
/**
 *  注册需要缓存到数据库的模型
 *
 *  @param aclass                模型类
 *  @param mappingType           表字段映射方式
 *  @param UniqueColumnNameArray 表中唯一性列名数组
 */
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType UniqueColumnNameArray:(NSArray*)uniqueColumnNameArray;
/**
 *  打开数据库
 *
 *  @param path 数据库路径，如果是空值就会使用默认路径(DataBase/DB/common_db.sqlite)
 *  @param error 错误信息
 *
 *  @return 是否打开成功
 */
-(BOOL)openDatabaseWithPath:(NSString*)path Error:(NSError **)error;
/**
 *  关闭数据库
 */
-(void)closeDatabase;

#pragma mark 增删改查 

/**
 *  批处理事物
 *
 *  @param block 批处理block
 */
-(void)batchHandle:(void(^)(void))block;


/**
 *  查询某个模型数据的条数
 *
 *  @param aclass 模型类
 *
 *  @return 条数
 */
-(NSInteger)countClass:(Class)aclass;
/**
 *  根据条件查询模型数据条数
 *
 *  @param aclass     模型类
 *  @param whereArray 条件数组 如：@[@"name like '%@%@李四%@%@'",@"score = 89"]
 *
 *  @return 条数
 */
-(NSInteger)countClass:(Class)aclass whereArray:(NSArray*)whereArray;


/**
 *  模型实体是否在数据库中已存在,根据唯一性字段名字和值判断
 *
 *  @param aclass          模型类
 *  @param primarykeyName  唯一性字段名
 *  @param primaryKeyValue 唯一性字段值
 *
 *  @return 是否存在
 */
-(BOOL)isExistModelClass:(Class)aclass primarykeyName:(NSString*)primarykeyName primarkeyValue:(NSString*)primaryKeyValue;
/**
 *  模型实体是否在数据库中已存在,根据唯一性字段名字和值判断
 *
 *  @param model          模型对象
 *  @param primarykeyName 唯一性字段名
 *
 *  @return 是否存在
 */
-(BOOL)isExistModel:(id)model primarykeyName:(NSString*)primarykeyName;
/**
 *  模型实体是否在数据库中已存在，根据每个字段匹配判断
 *
 *  @param model 模型对象
 *
 *  @return 是否存在
 */
-(BOOL)isExistModel:(id)model;
@end
