//
//  SMDDateBaseTableCopy.m
//  Echo
//
//  Created by robu on 15/1/8.
//  Copyright (c) 2015年 Static Ga. All rights reserved.
//

#import "YXDBHelper.h"
#import <sqlite3.h>
#import <stdio.h>
#import <objc/runtime.h>
#import "YXTableInfo.h"
#import "YXTableColumnInfo.h"
#import "YXDatabaseHandle.h"
#define source_database_name @"location_Numbercity.sqlite"


@implementation YXDBHelper
/*
#pragma mark app升级覆盖安装 拷贝联系人数据库数据 到 新数据库
-(void)copyContactsDBdataForUpdate{
    NSString * sourceDbPath = [APP_DELEGATE.primaryHomePath stringByAppendingPathComponent:@"contacts.sqlite"];
    NSString * desDbPath = [APP_DELEGATE.primaryHomePath stringByAppendingPathComponent:@"common_db.sqlite"];
    NSLog(@"sourceDbPath = %@",sourceDbPath);
    NSLog(@"desDbPath = %@",desDbPath);
    
    NSMutableArray * tableInfoArray = [[NSMutableArray alloc] init];
    DbTableInfo * table_id_list = [DbTableInfo modelWithMappingFileName:table_mapping_file_name_id_list];
    DbTableInfo * table_data = [DbTableInfo modelWithMappingFileName:table_mapping_file_name_data];
    DbTableInfo * table_c_groups = [DbTableInfo modelWithMappingFileName:table_mapping_file_name_c_groups];

    if(![self dataCountInTable:table_id_list DataBasePath:desDbPath]>0){
        [tableInfoArray addObject:table_id_list];
    }else{
        NSLog(@"联系人主表数据表=%@,已经拷贝过",table_id_list.tableName);
    }
    if(![self dataCountInTable:table_data DataBasePath:desDbPath]>0){
        [tableInfoArray addObject:table_data];
    }else {
        NSLog(@"联系人号码数据表=%@,已经拷贝过",table_data.tableName);
    }
    if(![self dataCountInTable:table_c_groups DataBasePath:desDbPath]>0){
        [tableInfoArray addObject:table_c_groups];
    }else {
        NSLog(@"联系人分组数据表=%@,已经拷贝过",table_c_groups.tableName);
    }
    
    [self copyDbTables:tableInfoArray DesDataBasePath:desDbPath SourceDataBasePath:sourceDbPath];
}
 */
#pragma mark 获取某个表的记录条数
-(NSInteger)dataCountInTable:(YXTableInfo*)tableInfo DataBasePath:(NSString*)dataBasePath{
    sqlite3* db = [self openDataBaseWithPath:dataBasePath];
    NSString* sql = [[NSString alloc] initWithFormat:@"select count(*) from %@",tableInfo.tableName];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"dataCountInTable sql = %@",sql);
    sqlite3_stmt* statement = nil;
    int count = 0;
    if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        if (statement) {
            sqlite3_finalize(statement);
        }
    }
    [self closeDataBase:db];
    return count;
}

/**
 *  从一个数据库中拷贝表及其数据到另一个数据库（目标表与源表所拷贝的字段要相同）
 *
 *  @param tablesArray        表信息模型数组
 *  @param desDataBasePath    目标数据库路径
 *  @param sourceDataBasePath 源数据库路径
 */
-(void)copyDbTables:(NSArray*)tablesArray DesDataBasePath:(NSString*)desDataBasePath SourceDataBasePath:(NSString*) sourceDataBasePath{
    const char * des_db_path = [desDataBasePath cStringUsingEncoding:NSASCIIStringEncoding];
    sqlite3 *db_des = NULL;
    if(sqlite3_open(des_db_path,&db_des)== SQLITE_OK){
        for(YXTableInfo * tableInfo in tablesArray){
            if(![self isTableExist:db_des TableName:tableInfo.tableName]){
                BOOL isSuccess = [self executeSql:db_des Sql:[tableInfo sqlCreateTable]];
                if(!isSuccess){
                    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                    NSLog(@"从一个数据库中拷贝表及其数据到另一个数据库，目标数据库创建失败");
                    return;
                }
            }
        }
        char * errorMsg = NULL;
        NSString * nsSql = [NSString stringWithFormat:@"attach '%@' as attach_db",sourceDataBasePath];
        const char * cSql = [nsSql cStringUsingEncoding:NSASCIIStringEncoding];
        if(sqlite3_exec(db_des,cSql,0,0,&errorMsg) == SQLITE_OK){
            for(YXTableInfo * tableInfo in tablesArray){
                NSString * columnsSql = @"";
                for(YXTableColumnInfo * columnInfo in tableInfo.columnInfoDict.allValues){
//                    if(columnInfo.isNewAddColumn){
//                        continue;
//                    }
                    columnsSql = [columnsSql stringByAppendingFormat:@" %@, ",columnInfo.columnName];
                }
                columnsSql =  [columnsSql substringToIndex:columnsSql.length-2];
                NSString * copySql = [NSString stringWithFormat:@"insert into %@ (%@) select %@ from attach_db.%@",tableInfo.tableName,columnsSql,columnsSql,tableInfo.tableName];
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                NSLog(@"表数据拷贝sql：%@",copySql);
                char * errorMsg1 = NULL;
                if(sqlite3_exec(db_des,"begin transaction",0,0,&errorMsg1) == SQLITE_OK){
                    char * errorMsg3 = NULL;
                    const char * cCopySql = [copySql cStringUsingEncoding:NSASCIIStringEncoding];
                    if(sqlite3_exec(db_des,cCopySql,0,0,&errorMsg3) == SQLITE_OK){
                        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                        NSLog(@"拷贝表数据成功");
                    }else{
                        if(NULL != errorMsg3){
                            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                            printf("拷贝表数据失败。。errorMsg3=%s",errorMsg3);
                        }
                    }
                    char * errorMsg2 = NULL;
                    if(sqlite3_exec(db_des,"commit transaction",0,0,&errorMsg2) == SQLITE_OK){
                        
                    }else{
                        if(NULL != errorMsg2){
                            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                            printf("提交事务失败。。errorMsg2=%s",errorMsg1);
                        }
                    }
                }else{
                    if(NULL != errorMsg1){
                        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                        printf("开启事务失败。。errorMsg1=%s",errorMsg1);
                    }
                }
            }
        }else{
            if(NULL != errorMsg){
                if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
                printf("attach ... faild errorMsg = %s",errorMsg);
            }
        }
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"打开目标数据库失败");
    }
}


#pragma mark 判断表是否存在
- (BOOL) isTableExist:(sqlite3*)db TableName:(NSString*)tableName
{
    NSString* sql = [[NSString alloc] initWithFormat:@"select count(*) from sqlite_master where type = \'table\' and name = \'%@\'", tableName];
    // NSLog(@" table exist sql : %@", sql);
    BOOL isExist = NO;
    sqlite3_stmt* statement = nil;
    if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
        if (sqlite3_step(statement) == SQLITE_ROW) {
            isExist =  sqlite3_column_int(statement, 0) != 0;
        }
        if (statement) {
            sqlite3_finalize(statement);
        }
    }
    return isExist;
}
#pragma mark 执行sql语句
- (BOOL) executeSql:(sqlite3*)db Sql:(NSString*)sql
{
    char *err;
    int nRet = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err);
    if(err){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@" execute sql error : %s", err);
        //        free(err);
        sqlite3_free(err);
    }
    
    return nRet == SQLITE_OK;
}
#pragma mark 打开数据库
- (sqlite3*) openDataBaseWithPath:(NSString*)dataBasepath
{
    sqlite3* db = nil;
    if(dataBasepath){
        if(sqlite3_open([dataBasepath UTF8String], &db) == SQLITE_OK)
        {
            return db;
        }else{
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"打开数据库失败");
        }
    }else{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"  数据库路径错误 ");
    }
    return  db;
}
#pragma mark 关闭数据库
- (BOOL)closeDataBase:(sqlite3*)db{
    if(sqlite3_close(db) == SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}
@end

