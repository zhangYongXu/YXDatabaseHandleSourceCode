//
//  Typedefine.h
//  YXDatabaseHandleLib
//
//  Created by 拓之林 on 16/3/3.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#ifndef Typedefine_h
#define Typedefine_h


#endif /* Typedefine_h */

/*
 映射文件名：模型名_table_mappingFile.plist(住：该文件放在项目中即可，会自动读取)
 */
typedef NS_ENUM(NSInteger, TableFeildMappingType) {
    TableFeildMappingTypeClassProperty = 0, //按照模型名和属性名与数据表名和字段名一一对应方式管理数据
    TableFeildMappingTypeMappingFile = 1    //更具模型与数据库映射文件管理数据
};
/*
 数据库查询排序类型
 */
typedef NS_ENUM(NSInteger,OrderType) {
    OrderTypeDesc = 0, //降序排序
    OrderTypeAsc = 1   //升序排序
};
/*
 模型属性类型区分
 */
typedef NS_ENUM(NSInteger, CpropertyTypeCategory) {
    CpropertyTypeCategoryBaseType = 0, //基本数据类型
    CpropertyTypeCategoryStructType = 1,//结构体类型
    CpropertyTypeCategoryObjectType = 2 //对象类型
};