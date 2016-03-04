//
//  YXDatabaseHandle+Insert.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle+Insert.h"
#import "YXTableInfo.h"
#import "FMDatabase.h"
#import "YXTableColumnInfo.h"

@implementation YXDatabaseHandle (Insert)
#pragma mark 插入模型
-(void)insertModel:(id)model{
    if(![self.database open]){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"请先打开数据");
        return;
    }
    NSString * sql=[self createSqlInsertModel:model];
    if(!sql){
        return;
    }
    BOOL success=[self.database executeUpdate:sql];
    if(!success){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"插入数据失败:%@：%@",NSStringFromClass([model class]),[self.database lastErrorMessage]);
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"插入成功:%@",NSStringFromClass([model class]));
    }
}
#pragma mark 插入模型数组
-(void)insertModelArray:(NSArray*)modelArray{
    [self.database beginTransaction];
    for(id model in modelArray){
        [self insertModel:model];
    }
    [self.database commit];
}



#pragma mark 创建插入语句
-(NSString*)createSqlInsertModel:(id)model{
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    if(!tableInfo){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"模型 %@ 还没有注册表信息",className);
        return nil;
    }
    NSString * sql;
    NSString * colStr=@"";
    NSString * valStr=@"";
    NSArray * columnInfoArray = tableInfo.columnInfoDict.allValues;
    for(YXTableColumnInfo * columnInfo in columnInfoArray){
        NSString * columnName = columnInfo.columnName;
        NSString * value = [model valueForKey:columnInfo.propertyName];
        if(!value){
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"表 %@ 列 %@ 对应模型属性名不正确",tableInfo.tableName,columnInfo.propertyName);
        }
        colStr=[colStr stringByAppendingString:[NSString stringWithFormat:@",%@",columnName]];
        if([value isKindOfClass:[NSString class]]){
            value=[value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
            value=[value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        }
        valStr=[valStr stringByAppendingString:[NSString stringWithFormat:@",'%@'",value]];
    }
    
    if(colStr.length>0){
        colStr=[colStr substringFromIndex:1];
    }
    if(valStr.length>0){
        valStr=[valStr substringFromIndex:1];
    }
    
    sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)",tableInfo.tableName,colStr,valStr];
    //NSLog(@"insertinto sql=%@",sql);
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"Model:%@,insertSql:%@",NSStringFromClass([model class]),sql);
    return sql;
}

@end
