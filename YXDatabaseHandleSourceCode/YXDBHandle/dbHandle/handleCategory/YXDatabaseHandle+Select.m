//
//  YXDatabaseHandle+Select.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle+Select.h"
#import "YXTableInfo.h"
#import "YXTableColumnInfo.h"
#import <UIKit/UIKit.h>
#import "FMDatabase.h"
@implementation YXDatabaseHandle (Select)
#pragma mark 读取数据 字典转模型
-(void)setValuesWithResultDict:(NSDictionary*)dict Model:(id)model TableInfo:(YXTableInfo*)tableInfo{
    for(NSString * columnName in dict.allKeys){
        NSString * value = [dict objectForKey:columnName];
        YXTableColumnInfo * columnInfo = tableInfo.columnInfoDict[columnName];
        if(!columnInfo){
            if(![columnName isEqualToString:tableInfo.primaryKey]){
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                NSLog(@"表 %@ 列 %@ 模型属性映射不完整",tableInfo.tableName,columnName);
            }else{
                [model setValue:value forKey:tableInfo.primaryPropertyName];
            }
            continue;
        }
        if(columnInfo.propertyTypeCategory == CpropertyTypeCategoryStructType){
            NSValue * nsvalue = nil;
            if([columnInfo.propertyType isEqualToString:@"CGSize"]){
                CGSize size = CGSizeFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&size objCType:@encode(CGSize)];
            }else if([columnInfo.propertyType isEqualToString:@"CGRect"]){
                CGRect rect = CGRectFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&rect objCType:@encode(CGRect)];
            }else if([columnInfo.propertyType isEqualToString:@"CGPoint"]){
                CGPoint point = CGPointFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&point objCType:@encode(CGPoint)];
            }else if([columnInfo.propertyType isEqualToString:@"CGVector"]){
                CGVector vector = CGVectorFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&vector objCType:@encode(CGVector)];
            }else if([columnInfo.propertyType isEqualToString:@"UIEdgeInsets"]){
                UIEdgeInsets edgeInsets = UIEdgeInsetsFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&edgeInsets objCType:@encode(UIEdgeInsets)];
            }else if([columnInfo.propertyType isEqualToString:@"UIOffset"]){
                UIOffset offset = UIOffsetFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&offset objCType:@encode(UIOffset)];
            }else if([columnInfo.propertyType isEqualToString:@"NSRange"]){
                NSRange range = NSRangeFromString(value);
                nsvalue = [[NSValue alloc] initWithBytes:&range objCType:@encode(NSRange)];
            }else{
                continue;
            }
            [model setValue:nsvalue forKey:columnInfo.propertyName];
        }else if(columnInfo.propertyTypeCategory == CpropertyTypeCategoryObjectType){
            if([columnInfo.propertyType isEqualToString:@"NSNumber"]){
                [model setValue:value forKey:columnInfo.propertyName];
            }else if([columnInfo.propertyType isEqualToString:@"NSString"]){
                [model setValue:value forKey:columnInfo.propertyName];
            }else if([columnInfo.propertyType isEqualToString:@"NSMutableString"]){
                [model setValue:value forKey:columnInfo.propertyName];
            }else if([columnInfo.propertyType isEqualToString:@"NSDate"]){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss z";
                NSDate * date = [formatter dateFromString:value];
                [model setValue:date forKey:columnInfo.propertyName];
            }else{
                continue;
            }
        }else{
            [model setValue:value forKey:columnInfo.propertyName];
        }
        //NSLog(@"forKey:columnInfo.propertyName = %@",columnInfo.propertyName);
    }
}

#pragma mark 读取某个模型的所有记录
-(NSArray *)readArray:(Class)aclass{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select * from %@",tableInfo.tableName];
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}

#pragma mark 分页读取某个模型的数据
-(NSArray *)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select * from %@ limit %d,%d",tableInfo.tableName,(page-1)*size,size];
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        //        [model setPartAttributes:dict];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}
#pragma mark 按条件分页读取某个模型的数据
-(NSArray *)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size whereArray:(NSArray*)whereArray{
    NSString * where = @"";
    for(int i=0;i<whereArray.count;i++){
        NSString * value=whereArray[i];
        if(i==whereArray.count-1){
            where=[where stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            where=[where stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select * from %@ where %@ limit %d,%d",tableInfo.tableName,where,(page-1)*size,size];
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        //[model setPartAttributes:dict];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}
-(NSArray *)readArray:(Class)aclass OrderBy:(NSString *)orderBy OrderType:(OrderType)orderType{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * type = @"desc";
    if(orderType == OrderTypeAsc){
        type = @"asc";
    }
    NSString * sql=[NSString stringWithFormat:@"select * from %@ order by %@ %@",tableInfo.tableName,orderBy,type];
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}
-(NSArray *)readArray:(Class)aclass OrderBy:(NSString *)orderBy OrderType:(OrderType)orderType whereArray:(NSArray*)whereArray;{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * type = @"desc";
    if(orderType == OrderTypeAsc){
        type = @"asc";
    }
    
    NSString * where = @"";
    for(int i=0;i<whereArray.count;i++){
        NSString * value = whereArray[i];
        if(i == whereArray.count-1){
            where=[where stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            where=[where stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    
    NSString * sql=[NSString stringWithFormat:@"select * from %@  where (%@) order by %@ %@",tableInfo.tableName,where,orderBy,type];
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}
-(NSArray *)readArrayBySql:(NSString *)sql{
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        NSDictionary * dict=[rs resultDictionary];
        [resultArray addObject:dict];
    }
    return resultArray;
}
#pragma mark 根据条件读取某个模型的数据
-(NSArray*)readyArray:(Class)aclass whereArray:(NSArray*)whereArray{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select * from %@ where ",tableInfo.tableName];
    for(int i=0;i<whereArray.count;i++){
        NSString * value=whereArray[i];
        if(i==whereArray.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    FMResultSet * rs=[self.database executeQuery:sql];
    NSMutableArray * resultArray=[NSMutableArray new];
    while (rs.next) {
        id model=[aclass new];
        NSDictionary * dict=[rs resultDictionary];
        //[model setPartAttributes:dict];
        [self setValuesWithResultDict:dict Model:model TableInfo:tableInfo];
        [resultArray addObject:model];
    }
    return resultArray;
}
@end
