//
//  DbTableInfo.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXTableInfo.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "YXTableColumnInfo.h"
#import "YXDatabaseHandle.h"

@implementation YXTableInfo
+(YXTableInfo *)modelWithMappingFileName:(NSString *)mappingFileName{
    YXTableInfo * model = [[YXTableInfo alloc] init];
    NSString * path = [[NSBundle mainBundle] pathForResource:mappingFileName ofType:nil];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if(nil == dict){
        return nil;
    }
    [model setPartAttributes:dict];
    
    NSArray * columnInfoArray = [YXTableColumnInfo modelArrayWith:[dict objectForKey:@"columnInfoArray"]];
    NSMutableDictionary * columnInfoDict = [[NSMutableDictionary alloc] init];
    for(YXTableColumnInfo * columnInfo in columnInfoArray){
        [columnInfoDict setValue:columnInfo forKey:columnInfo.columnName];
    }
    model.columnInfoDict = columnInfoDict;
    return model;
}

/* 反射类型
 
 TB,N,V_isSuccess
 Tc,N,V_charValue
 Tq,N,V_pCount
 TQ,N,V_pIndex
 Ti,N,V_age
 TI,N,V_days
 Tf,N,V_floatValue
 Td,N,V_money
 Td,N,V_rate
 T{CGPoint=dd},N,V_center
 T{CGRect={CGPoint=dd}{CGSize=dd}},N,V_frame
 T{CGSize=dd},N,V_size
 T{CGVector=dd},N,V_vector
 T{UIEdgeInsets=dddd},N,V_edgeInset
 T@"NSString",C,N,V_name
 T@"NSMutableString",&,N,V_mutableString
 T@"NSArray",&,N,V_array
 T@"NSMutableArray",&,N,V_mutableArray
 T@"NSDictionary",&,N,V_dict
 T@"NSMutableDictionary",&,N,V_mutableDict
 T@"NSSet",&,N,V_set
 T@"NSMutableSet",&,N,V_mutableSet
 T@"TestItemModel",&,N,V_itemModel
 */
+(YXTableInfo *)modelWithClass:(Class)class{
    NSString * className = NSStringFromClass(class);
    YXTableInfo * tableInfo  = [[YXTableInfo alloc] init];
    tableInfo.tableName = className;
    tableInfo.primaryKey = @"serial";
    tableInfo.primaryPropertyName = @"serial";
    tableInfo.primaryPropertyType = @"NSString";
    
    //NSMutableArray *columnInfoArray = [NSMutableArray array];
    NSMutableDictionary *columnInfoDict = [[NSMutableDictionary alloc] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        if([propertyName isEqualToString:@"serial"]){
            continue;
        }
        const char * attributes = property_getAttributes(properties[i]);//获取属性类型
        NSString * typeName=[NSString stringWithUTF8String:attributes];
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"coloumInfo typeName:%@",typeName);
        
        YXTableColumnInfo * columnInfo = [[YXTableColumnInfo alloc] init];
        columnInfo.columnName = propertyName;
        columnInfo.propertyName = propertyName;
        NSString * suffix = [typeName substringToIndex:2];
        if([suffix isEqualToString:@"T{"]){//结构体类型
            columnInfo.propertyTypeCategory = CpropertyTypeCategoryStructType;
            NSString * structName = [[[typeName substringFromIndex:2] componentsSeparatedByString:@"="] firstObject];
            columnInfo.columnType = @"text";
            columnInfo.propertyType = structName;
            if([structName isEqualToString:@"CGSize"]){
                columnInfo.defaultValue = NSStringFromCGSize(CGSizeZero);
            }else if([structName isEqualToString:@"CGRect"]){
                columnInfo.defaultValue = NSStringFromCGRect(CGRectZero);
            }else if([structName isEqualToString:@"CGPoint"]){
                columnInfo.defaultValue = NSStringFromCGPoint(CGPointZero);
            }else if([structName isEqualToString:@"CGVector"]){
                CGVector vector = CGVectorMake(1, 1);
                NSString * d = NSStringFromCGVector(vector);//ios 7 崩溃了
                columnInfo.defaultValue = d;
            }else if([structName isEqualToString:@"UIEdgeInsets"]){
                columnInfo.defaultValue = NSStringFromUIEdgeInsets(UIEdgeInsetsZero);
            }else if([structName isEqualToString:@"UIOffset"]){
                columnInfo.defaultValue = NSStringFromUIOffset(UIOffsetZero);
            }else if([structName isEqualToString:@"NSRange"]){
                columnInfo.defaultValue = NSStringFromRange(NSMakeRange(0, 0));
            }else{
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                NSLog(@"%@，该结构体不支持",structName);
                continue;
            }
        }else if([suffix isEqualToString:@"T@"]){//对象类型
            columnInfo.propertyTypeCategory = CpropertyTypeCategoryObjectType;
            NSString * className = [[[typeName substringFromIndex:3] componentsSeparatedByString:@"\","] firstObject];
            if([className isEqualToString:@"NSNumber"]){
                columnInfo.columnType = @"text";
                columnInfo.propertyType = @"NSNumber";
                columnInfo.defaultValue = @"";
            }else if([className isEqualToString:@"NSString"]){
                columnInfo.columnType = @"text";
                columnInfo.propertyType = @"NSString";
                columnInfo.defaultValue = @"";
            }else if([className isEqualToString:@"NSMutableString"]){
                columnInfo.columnType = @"text";
                columnInfo.propertyType = @"NSString";
                columnInfo.defaultValue = @"";
            }else if([className isEqualToString:@"NSDate"]){
                columnInfo.columnType = @"date";
                columnInfo.propertyType = @"NSDate";
                columnInfo.defaultValue = @"";
            }else {
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                NSLog(@"%@，该对象类型不支持",className);
                continue;
            }
        }else{//基本数据类型
            columnInfo.propertyTypeCategory = CpropertyTypeCategoryBaseType;
            char type = [[typeName lowercaseString] characterAtIndex:1];
            if(type == 'b'){//bool型
                columnInfo.columnType = @"integer";
                columnInfo.propertyType = @"BOOL";
                columnInfo.defaultValue = @"0";
            }else if(type == 'c'){//char型
                columnInfo.columnType = @"integer";
                columnInfo.propertyType = @"char";
                columnInfo.defaultValue = @"0";
            }else if(type == 'i' || type == 'q'){//整型
                columnInfo.columnType = @"integer";
                columnInfo.propertyType = @"NSNumber";
                columnInfo.defaultValue = @"0";
            }else if(type == 'f' || type == 'd'){//浮点型
                columnInfo.columnType = @"float";
                columnInfo.propertyType = @"NSNumber";
                columnInfo.defaultValue = @"0.00";
            }else{
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                NSLog(@"%c，该基本数据类型不支持",type);
                continue;
            }
        }
        [columnInfoDict setValue:columnInfo forKey:columnInfo.columnName];
    }
    free(properties);
    tableInfo.columnInfoDict = columnInfoDict;
    return tableInfo;
}

#pragma mark 创建建表语句
-(NSString *)sqlCreateTable{
    NSString * sql = @"";
    if(nil != self.primaryKey && self.primaryKey.length>0){
        sql = [NSString stringWithFormat:@"%@ integer primary key autoincrement, ",self.primaryKey];
    }
    sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ ",self.tableName,sql];
    for(YXTableColumnInfo * columnInfo in self.columnInfoDict.allValues){
        NSString *tdefaultValue = @"";
        if(nil != columnInfo.defaultValue){
            if(![columnInfo.defaultValue isEqualToString:@"NULL"]){
                tdefaultValue = [NSString stringWithFormat:@" default '%@'",columnInfo.defaultValue];
            }
        }
        NSString * unique = @"";
        if(columnInfo.isUnique){
            unique = @"unique";
        }
        NSString * tSql = [NSString stringWithFormat:@" %@ %@ %@ %@, ",columnInfo.columnName,columnInfo.columnType,unique,tdefaultValue];
        sql = [sql stringByAppendingString:tSql];
    }
    sql = [sql substringToIndex:sql.length - 2];
    sql = [sql stringByAppendingString:@" )"];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"sqlCreateTable sql =%@",sql);
    return sql;
}

@end
