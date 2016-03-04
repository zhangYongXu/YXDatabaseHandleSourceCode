//
//  YXDatabaseHandle.m
//  Echo
//
//  Created by BZBY on 15/3/25.
//  Copyright (c) 2015年 Static Ga. All rights reserved.
//

#import "YXDatabaseHandle.h"
#import "FMDatabase.h"
#import "YXTableInfo.h"

#import "YXFileDirTool.h"
#import "NSString+YXStringEX.h"
#import "YXTableColumnInfo.h"

#define DB_NAME @"common_db.sqlite"

//是否打印logs
static BOOL YXDatabaseHandleIsShowLogs;

static YXDatabaseHandle * shareIntance = nil;
@interface YXDatabaseHandle()
@property (copy,nonatomic) NSString * databasePath;

@end
@implementation YXDatabaseHandle
-(instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}
+(BOOL)YXDatabaseHandleIsShowLogs{
    return YXDatabaseHandleIsShowLogs;
}
+(void)setYXDatabaseHandleIsShowLogs:(BOOL)isShowLogs{
    YXDatabaseHandleIsShowLogs = isShowLogs;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    @synchronized (self) {
        if (shareIntance == nil) {
            shareIntance = [super allocWithZone:zone];
        }
    }
    return shareIntance;
}
+(instancetype)alloc{
    @synchronized (self) {
        if (shareIntance == nil) {
            shareIntance = [super alloc];
        }
    }
    return shareIntance;
}

+(YXDatabaseHandle *)shareInstance{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareIntance = [[YXDatabaseHandle alloc] init];
    });
    return shareIntance;
}
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    if(tableInfo){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"类%@ 已经注册过",className);
        return;
    }
    if(TableFeildMappingTypeMappingFile == mappingType){
        NSString * mappingFileName = [NSString stringWithFormat:@"%@_table_mappingFile.plist",className];
        tableInfo = [YXTableInfo modelWithMappingFileName:mappingFileName];
        if(nil == tableInfo){
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"类%@,映射文件不存在",className);
            return;
        }
    }else{
        tableInfo = [YXTableInfo modelWithClass:aclass];
    }
    
    [self.tablesDict setObject:tableInfo forKey:className];
    
    if([self isTableExistFMDB:self.database TableName:tableInfo.tableName]){
        [self alterTableWithDbTableInfo:tableInfo];
    }else{
        [self createTableWithDbTableInfo:tableInfo];
    }
}
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType UniqueColumnNameArray:(NSArray*)uniqueColumnNameArray;{
    
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    if(tableInfo){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"类%@ 已经注册过",className);
        return;
    }
    if(TableFeildMappingTypeMappingFile == mappingType){
        NSString * mappingFileName = [NSString stringWithFormat:@"%@_table_mappingFile.plist",className];
        tableInfo = [YXTableInfo modelWithMappingFileName:mappingFileName];
        if(nil == tableInfo){
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"类%@,映射文件不存在",className);
            return;
        }
    }else{
        tableInfo = [YXTableInfo modelWithClass:aclass];
    }
    
    for(YXTableColumnInfo * columnInfo in tableInfo.columnInfoDict.allValues){
        for(NSString * columnName in uniqueColumnNameArray){
            if([columnInfo.columnName isEqualToString:columnName]){
                columnInfo.isUnique = YES;
            }
        }
    }
    
    [self.tablesDict setObject:tableInfo forKey:className];
    
    if([self isTableExistFMDB:self.database TableName:tableInfo.tableName]){
        [self alterTableWithDbTableInfo:tableInfo];
    }else{
        [self createTableWithDbTableInfo:tableInfo];
    }
}
-(BOOL)isEmptyString:(NSString*)string{
    NSString * newString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(nil == string
       || string.length ==0
       || [string isEqualToString:@""]
       || [string isEqualToString:@"<null>"]
       || [string isEqualToString:@"(null)"]
       || [string isEqualToString:@"null"]
       || newString.length ==0
       || [newString isEqualToString:@""]
       || [newString isEqualToString:@"<null>"]
       || [newString isEqualToString:@"(null)"]
       || [newString isEqualToString:@"null"]
       ){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)openDatabaseWithPath:(NSString*)path Error:(NSError **)error{
    NSString * msg = @"";
    if(![self isEmptyString:self.databasePath]){
        msg = [NSString stringWithFormat:@"路径为%@的数据库已经打开,请先关闭",self.databasePath];
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"%@",msg);
        *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{@"errorMsg":msg}];
        return NO;
    }
    if(nil == self.tablesDict){
        _tablesDict = [[NSMutableDictionary alloc] init];
    }
    if([self isEmptyString:path]){
        self.databasePath = [self dataBaseFilePath];
    }else{
        self.databasePath = path;
    }
    
    NSString * databasePath = self.databasePath;
    _database=[[FMDatabase alloc] initWithPath:databasePath];
    //打开数据库
    
    if([self.database open]){
        msg = @"打开数据库成功";
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"%@",msg);
        return YES;
    }else{
        msg = @"打开数据库失败";
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"%@",msg);
        *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class]) code:-1 userInfo:@{@"errorMsg":msg}];
        return NO;
    }
}
-(void)closeDatabase{
    [self.database close];
    _databasePath = nil;
    _database = nil;
    _tablesDict = nil;
}
#pragma mark 获取数据库文件存放路径
-(NSString*) dataBaseFilePath
{
    //NSString * dbPath = [ECUtils getHomeDatabaseByHomePath:APPDelegate.userHomePath andDbname:DB_NAME];
    NSString * dbDir = [YXFileDirTool getDirctoryInHomeDocumentsWithPath:@"DataBase/DB"];
    NSString * dbPath = [YXFileDirTool getFilePathWithFileName:DB_NAME InDirctory:dbDir];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"dataBasePath==%@",dbPath);
    return dbPath;
    
}
#pragma mark 判断某个表是否存在
-(BOOL)isTableExistFMDB:(FMDatabase*)db TableName:(NSString *) tableName{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next]){
        NSInteger count = [rs intForColumn:@"count"];
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"isTableExist %ld", count);
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}


#pragma mark 创建表
- (void)createTableWithDbTableInfo:(YXTableInfo*)tableInfo
{
    NSString *sqlCreateTable = [tableInfo sqlCreateTable];
    BOOL successs=[self.database executeUpdate:sqlCreateTable];
    if(!successs){
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"创建失败：%@",[self.database lastErrorMessage]);
    }
}
#pragma mark 修改表
- (void)alterTableWithDbTableInfo:(YXTableInfo*)tableInfo{
    NSMutableArray * array = [self getUnExistColumnsWithDbTableInfo:tableInfo];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"不存在的列 array = %@",array);
    [self addColumnWithDbTableInfo:tableInfo ColumnArray:array];
}

#pragma mark 获取表已存在的列
-(NSMutableArray*)getExistColumnsWithDbTableInfo:(YXTableInfo*)table{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", table.tableName];
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(self.database.sqliteHandle, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK ) 	{
        if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
        NSLog(@"Error: failed to prepare statement.");
        return nil;
    }
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char * c_column = (char *)sqlite3_column_text(statement, 1);
        BOOL isPrimaryKey = sqlite3_column_int(statement, 5);
        if(!isPrimaryKey){
            NSString *columnName = [NSString stringWithUTF8String:c_column];
            [array addObject:columnName];
        }
    }
    return array;
}
#pragma mark 获取表中还不存在的列
- (NSMutableArray*)getUnExistColumnsWithDbTableInfo:(YXTableInfo*)tableInfo{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSArray * existColumnArray = [self getExistColumnsWithDbTableInfo:tableInfo];
    NSArray * columnArray = tableInfo.columnInfoDict.allValues;
    if(existColumnArray.count == columnArray.count){
        return nil;
    }
    for(YXTableColumnInfo * columnInfo in columnArray){
        if(![existColumnArray containsObject:columnInfo.columnName]){
            [array addObject:columnInfo];
        }
    }
    return array;
}
#pragma mark 添加列
- (void)addColumnWithDbTableInfo:(YXTableInfo*)tableInfo ColumnArray:(NSArray*)columnArray{
    for(YXTableColumnInfo * columnInfo in columnArray){
        NSString * defaultValue = @"";
        if(columnInfo.defaultValue){
            defaultValue = [NSString stringWithFormat:@"DEFAULT '%@'",columnInfo.defaultValue];
        }
        NSString * sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@  %@",tableInfo.tableName,columnInfo.columnName,columnInfo.columnType,defaultValue];
        BOOL isSucces = [self.database executeUpdate:sql];
        if(!isSucces){
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"为表:%@添加列:%@失败",tableInfo.tableName,columnInfo.columnName);
        }else{
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"为表:%@添加列:%@成功",tableInfo.tableName,columnInfo.columnName);
        }
    }
}


#pragma mark 批量处理
-(void)batchHandle:(void (^)(void))block{
    [_database beginTransaction];
    block();
    [_database commit];
}


#pragma mark 查询数据数量
-(NSInteger)countClass:(Class)aclass{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select count(*) from %@",tableInfo.tableName];
    FMResultSet * rs=[_database executeQuery:sql];
    NSInteger count = 0;
    while (rs.next) {
        count = [rs intForColumnIndex:0];
        break;
    }
    return count;
}
#pragma mark 根据条件查询数据数量
-(NSInteger)countClass:(Class)aclass whereArray:(NSArray*)whereArray{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString * sql=[NSString stringWithFormat:@"select count(*) from %@ where ",tableInfo.tableName];
    for(int i=0;i<whereArray.count;i++){
        NSString * value = whereArray[i];
        if(i==whereArray.count-1){
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) ",value]];
        }else{
            sql=[sql stringByAppendingString:[NSString stringWithFormat:@" (%@) and ",value]];
        }
    }
    FMResultSet * rs=[_database executeQuery:sql];
    NSInteger count = 0;
    while (rs.next) {
        count = [rs intForColumnIndex:0];
        break;
    }
    return count;
}

#pragma mark 存在性判断
#pragma mark 判断某种实体 是否存在该记录
-(BOOL)isExistModelClass:(Class)aclass primarykeyName:(NSString *)primarykeyName primarkeyValue:(NSString *)primaryKeyValue{
    NSString * className = NSStringFromClass(aclass);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString *sql=[NSString stringWithFormat:@"select * from %@ where %@=?",tableInfo.tableName,primarykeyName];
    FMResultSet * rs=[_database executeQuery:sql,primaryKeyValue];
    while (rs.next) {
        return YES;
    }
    return NO;
}
-(BOOL)isExistModel:(id)model primarykeyName:(NSString *)primarykeyName{
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString *sql=[NSString stringWithFormat:@"select * from %@ where %@=?",tableInfo.tableName,primarykeyName];
    NSString * value=[model valueForKey:primarykeyName];
    FMResultSet * rs=[_database executeQuery:sql,value];
    while (rs.next) {
        return YES;
    }
    return NO;
}

-(BOOL)isExistModel:(id)model{
    NSString * className = NSStringFromClass([model class]);
    YXTableInfo * tableInfo = [self.tablesDict objectForKey:className];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ",tableInfo.tableName];

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
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"isex  sql=%@",sql);
    FMResultSet * rs=[_database executeQuery:sql];
    while (rs.next) {
        return YES;
    }
    return NO;
}
@end
