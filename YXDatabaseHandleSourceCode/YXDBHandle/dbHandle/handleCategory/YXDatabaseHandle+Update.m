//
//  YXDatabaseHandle+Update.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle+Update.h"
#import "YXTableInfo.h"
#import "YXTableColumnInfo.h"
#import "FMDatabase.h"
@implementation YXDatabaseHandle (Update)

-(void)updateModel:(id)model primarykeyName:(NSString *)primarykeyName{
    NSString * sql= [self createSqlUpdateModel:model];
    //设置条件
    NSString * where = [NSString stringWithFormat:@" where %@ ='%@'",primarykeyName,[model valueForKey:primarykeyName]];
    sql=[sql stringByAppendingString:where];
    BOOL sucess=[self.database executeUpdate:sql];
    if(!sucess){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"更新失败:%@",NSStringFromClass([model class]));
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"更新成功:%@",NSStringFromClass([model class]));
    }
    
}

#pragma mark 根据条件更新
-(void)updateModel:(id)model whereArray:(NSArray*)whereArray{
    NSString * sql= [self createSqlUpdateModel:model];
    //设置条件
    sql =[sql stringByAppendingString:@" where "];
    for(int i=0;i<whereArray.count;i++){
        NSString * value=whereArray[i];
        if(i==whereArray.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    BOOL sucess=[self.database executeUpdate:sql];
    if(!sucess){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"更新失败:%@",NSStringFromClass([model class]));
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"更新成功:%@",NSStringFromClass([model class]));
    }
    //NSLog(@"lskdfaskdfj=  sql=%@",sql);
    
}
#pragma mark 创建更新语句
-(NSString*)createSqlUpdateModel:(id)model{
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"update %@  ",tableInfo.tableName];
    //修改语句
    NSArray * array = tableInfo.columnInfoDict.allValues;
    for(int i=0;i<array.count;i++){
        YXTableColumnInfo * columnInfo = array[i];
        NSString * columnName = columnInfo.columnName;
        NSString * key = columnInfo.propertyName;
        NSString * value = [model valueForKey:key];
        if([value isKindOfClass:[NSString class]]){
            value=[value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
            value=[value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        }
        if(i==array.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@' ",columnName,value]];
        }else{
            if(i==0){
                sql=[sql stringByAppendingString:[NSString stringWithFormat:@"set %@ = '%@', ",columnName,value]];
            }else{
                sql=[sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@', ",columnName,value]];
            }
        }
    }
    return sql;
}
@end
