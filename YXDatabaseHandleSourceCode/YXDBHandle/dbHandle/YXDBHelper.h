//
//  SMDDateBaseTableCopy.h
//  Echo
//
//  Created by robu on 15/1/8.
//  Copyright (c) 2015年 Static Ga. All rights reserved.
//

#import <Foundation/Foundation.h>


@class YXTableInfo;
@class YXTableColumnInfo;


@interface YXDBHelper : NSObject

/**
 *  从一个数据库中拷贝表及其数据到另一个数据库（目标表与源表所拷贝的字段要相同）
 *
 *  @param tablesArray        表信息模型数组
 *  @param desDataBasePath    目标数据库路径
 *  @param sourceDataBasePath 源数据库路径
 */
-(void)copyDbTables:(NSArray*)tablesArray DesDataBasePath:(NSString*)desDataBasePath SourceDataBasePath:(NSString*) sourceDataBasePath;

@end



