//
//  DbTableInfo.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXRootModel.h"

@class YXTableColumnInfo;

/**
 *  数据库表信息
 */
@interface YXTableInfo : YXRootModel

@property (copy,nonatomic) NSString * tableName;//表名
@property (strong,nonatomic) NSMutableDictionary * columnInfoDict;//列信息
@property (copy,nonatomic) NSString * primaryKey;//表主键
//主键对应模型属性的名称和类型
@property (copy,nonatomic) NSString * primaryPropertyName;
@property (copy,nonatomic) NSString * primaryPropertyType;


+(YXTableInfo*)modelWithMappingFileName:(NSString *) mappingFileName;
+(YXTableInfo *)modelWithClass:(Class)class;

-(NSString*)sqlCreateTable;
@end
