//
//  RootModel.h
//  bzbyParents
//
//  Created by bzby on 15/3/12.
//  Copyright (c) 2015年 bzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXRootModel : NSObject
/**
 *  用数据字典初始化模型
 *
 *  @param dictionary 数据字典
 *
 *  @return 模型对象
 */
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
/**
 *  把字典数据赋值给模型对象
 *
 *  @param dictionary 数据字典
 */
-(void)setPartAttributes:(NSDictionary*)dictionary;
/**
 *  模型属性与字典key映射，如果数据中的key值找不到对应得属性，就会从该映射字典中查找对应属性名
 *
 *  @return 模型属性与字典key映射字典 ，子类实现如：@{@"数据字段key1":@"属性名key1"}
 */
- (NSDictionary*)propertyKeyMappingDictionary;
/**
 *  获取归档数据
 *
 *  @return 归档数据
 */
- (NSData*)getArchivedData;
/**
 *  归档数据转模型对象
 *
 *  @param data 数据
 *
 *  @return 模型对象
 */
- (instancetype)modelObjcetFromArchiveData:(NSData*)data;
/**
 *  自定义对象描述，子类实现
 *
 *  @return 描述
 */
- (NSString *)customDescription;
/**
 *  模型对象转字典
 *
 *  @param isIncludeValue 是否包括属性值
 *  @param depth          向父类延生的层级
 *
 *  @return 字典
 */
- (NSDictionary *)propertyList:(BOOL)isIncludeValue depth:(NSInteger)depth;
/**
 *  模型对象转字典
 *
 *  @param isIncludeValue 是否包含属性值
 *
 *  @return 字典
 */
- (NSDictionary *)propertyList:(BOOL)isIncludeValue;
/**
 *  数据字典数组转模型对象数组
 *
 *  @param dictArray 数据字典数组
 *
 *  @return 模型数组
 */
+ (NSMutableArray*)modelArrayFromDictArray:(NSArray*)dictArray;
@end
