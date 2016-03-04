//
//  YXDatabaseHandle+Insert.h
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXDatabaseHandle.h"

@interface YXDatabaseHandle (Insert)
/**
 *  插入模型
 *
 *  @param model 模型对象
 */
-(void)insertModel:(id)model;
/**
 *  插入模型数组
 *
 *  @param modelArray 模型数组
 */
-(void)insertModelArray:(NSArray*)modelArray;
@end
