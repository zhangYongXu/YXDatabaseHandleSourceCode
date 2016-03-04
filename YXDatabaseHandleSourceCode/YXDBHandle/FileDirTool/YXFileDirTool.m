//
//  FlieDirTool.m
//  YXebookReader
//
//  Created by BZBY on 15/11/27.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXFileDirTool.h"
#import "YXDatabaseHandle.h"

@implementation YXFileDirTool
+(NSString *)getHomeDoumentsPath{
    NSString * homeDir = NSHomeDirectory();
    NSString * documentsPath = [homeDir stringByAppendingPathComponent:@"Documents"];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"沙河目录:%@",documentsPath);
    return documentsPath;
}
+(NSString *)getDirctoryInHomeDocumentsWithPath:(NSString *)path{
    NSString * homeDir = NSHomeDirectory();
    NSString * documents = [homeDir stringByAppendingPathComponent:@"Documents"];
    NSString * dirctoryPath = [documents stringByAppendingPathComponent:path];
    return [self getDirctoryPath:dirctoryPath];
}
+(NSString *)getFilePathInHomeDocumentsWithFileName:(NSString *)fileName{
    NSString * homeDir = NSHomeDirectory();
    NSString * documents = [homeDir stringByAppendingPathComponent:@"Documents"];
    NSString * filePath = [documents stringByAppendingPathComponent:fileName];
    return filePath;
}

+(NSString*)getDirctoryPath:(NSString *)dirctoryPath{
    NSFileManager *FM = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist = [FM fileExistsAtPath:dirctoryPath isDirectory:&isDir];
    if(!isExist){
        NSError * error = nil;
        BOOL isSuccess = [FM createDirectoryAtPath:dirctoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(!isSuccess){
            if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
            NSLog(@"创建目录失败  getDirctoryInHomeDocumentsWithPath error: %@",error);
        }
    }
    return dirctoryPath;
}

+(NSString *)getFilePathWithFileName:(NSString *)fileName InDirctory:(NSString *)dirctory{
    NSString * dirctoryPath = [self getDirctoryPath:dirctory];
    NSString * filePath = [dirctoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}
@end
