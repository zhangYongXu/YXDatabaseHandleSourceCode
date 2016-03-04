//
//  TableColumnInfo.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXRootModel.h"
#import "YXTypedefine.h"

/**
 *  数据库表列信息
 */
@interface YXTableColumnInfo : YXRootModel
//列名和列类型
@property (copy,nonatomic) NSString * columnName;
@property (copy,nonatomic) NSString * columnType;
//属性名和属性类型及是否是唯一的
@property (copy,nonatomic) NSString * propertyName;
@property (copy,nonatomic) NSString * propertyType;
@property (assign,nonatomic) CpropertyTypeCategory propertyTypeCategory;

@property (assign,nonatomic)BOOL isUnique;
//列缺省值和列描述
@property (copy,nonatomic) NSString * defaultValue;
@property (copy,nonatomic) NSString * columnDescription;

+(NSArray *)modelArrayWith:(NSArray*)dictArray;
@end
