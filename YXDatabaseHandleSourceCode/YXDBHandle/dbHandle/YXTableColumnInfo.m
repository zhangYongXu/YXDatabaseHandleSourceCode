//
//  TableColumnInfo.m
//  YXebookReader
//
//  Created by BZBY on 15/12/11.
//  Copyright (c) 2015年 BZBY. All rights reserved.
//

#import "YXTableColumnInfo.h"
#import "YXDatabaseHandle.h"
@implementation YXTableColumnInfo

-(instancetype)init{
    if(self = [super init]){
        self.isUnique = NO;
    }
    return self;
}
+(NSArray *)modelArrayWith:(NSArray *)dictArray{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for(NSDictionary * dict in dictArray){
        YXTableColumnInfo * model = [[YXTableColumnInfo alloc] init];
        [model setPartAttributes:dict];
        [array addObject:model];
    }
    return array;
}
@end