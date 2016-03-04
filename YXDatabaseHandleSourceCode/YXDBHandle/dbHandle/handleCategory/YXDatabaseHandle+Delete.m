//
//  YXDatabaseHandle+Delete.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle+Delete.h"
#import "YXTableInfo.h"
#import "YXTableColumnInfo.h"
#import "FMDatabase.h"
@implementation YXDatabaseHandle (Delete)
#pragma mark 删除模型
-(void)deleteModel:(id)model{
    NSString *sql=[NSString stringWithFormat:@"delete from %@ where ",NSStringFromClass([model class])];
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSArray * array = tableInfo.columnInfoDict.allValues;
    for(int i=0;i<array.count;i++){
        YXTableColumnInfo * columnInfo = array[i];
        NSString * columnName = columnInfo.columnName;
        NSString * key = columnInfo.propertyName;
        NSString * value=[model valueForKey:key];
        if(i==array.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@' ",columnName,value]];
        }else{
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" %@ = '%@'and ",columnName,value]];
        }
    }
    BOOL success = [self.database executeUpdate:sql];
    if(!success){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除失败:%@",NSStringFromClass([model class]));
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除成功:%@",NSStringFromClass([model class]));
    }
}
#pragma mark 根据唯一性字段删除数据
-(void)deleteModel:(id)model primarykeyName:(NSString *)primarykeyName{
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"delete from %@  ",tableInfo.tableName];
    //设置条件
    NSString * where = [NSString stringWithFormat:@" where %@ ='%@'",primarykeyName,[model valueForKey:primarykeyName]];
    sql=[sql stringByAppendingString:where];
    BOOL sucess=[self.database executeUpdate:sql];
    if(!sucess){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除失败:%@",NSStringFromClass([model class]));
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除成功:%@",NSStringFromClass([model class]));
    }
}
#pragma mark 根据条件删除
-(void)deleteClass:(Class)aclass whereArray:(NSArray*)whereArray{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where ",tableInfo.tableName];
    for(int i=0;i<whereArray.count;i++){
        NSString * value= whereArray[i];
        if(i==whereArray.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    if(!whereArray){
        //sql = [NSString stringWithFormat:@"delete from %@ ",tableInfo.tableName];
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"设置条件为空，无法删除:%@",NSStringFromClass(aclass));
        return;
    }
    BOOL success = [self.database executeUpdate:sql];
    if(!success){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除失败:%@",NSStringFromClass(aclass));
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"删除成功:%@",NSStringFromClass(aclass));
    }
}
@end
