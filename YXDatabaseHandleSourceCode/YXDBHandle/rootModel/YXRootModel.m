//
//  RootModel.m
//  bzbyParents
//
//  Created by bzby on 15/3/12.
//  Copyright (c) 2015年 bzby. All rights reserved.
//

#import "YXRootModel.h"
#import <objc/runtime.h>
#import "YXDatabaseHandle.h"

@implementation YXRootModel

-(instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    if(self = [self init]){
        [self setPartAttributes:dictionary];
    }
    return self;
}
-(void)setPartAttributes:(NSDictionary*)dictionary{
    if ([dictionary isKindOfClass:[NSDictionary class]] || [dictionary isKindOfClass:[NSMutableDictionary class]]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
}
+(NSMutableArray *)modelArrayFromDictArray:(NSArray *)dictArray{
    if(![dictArray isKindOfClass:[NSArray class]]){
        return nil;
    }
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for(NSDictionary * dict in dictArray){
        YXRootModel * rootModel = [[[self class] alloc] init];
        [rootModel setPartAttributes:dict];
        [array addObject:rootModel];
    }
    return array;
}

/*
 return @{
 @"数据字典key1"   : @"模型属性key1",
 @"数据字典key2" : @"模型属性key2"
 }
 */
//子类具体实现
-(NSDictionary *)propertyKeyMappingDictionary{
    return nil;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSDictionary * mappingDict = [self propertyKeyMappingDictionary];
    NSString * propertyKey = [mappingDict objectForKey:key];
    if(propertyKey){
        [self setValue:value forKey:propertyKey];
        return;
    }
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"%@,forUndefinedKey....... %@ ",NSStringFromClass([self class]),key);
}
-(id)valueForUndefinedKey:(NSString *)key{
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"%@,valueForUndefinedKey....... %@ ",NSStringFromClass([self class]),key);
    return nil;
}
#pragma mark 归档编码/解码
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [self init]){
        NSDictionary * propertList = [self propertyList:NO];
        for(NSString * key in propertList.allKeys){
            id codeValue = [aDecoder decodeObjectForKey:key];
            [self setValue:codeValue forKey:key];
        }
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    NSDictionary * propertList = [self propertyList:YES];
    for(NSString * key in propertList.allKeys){
        NSString * value = [propertList objectForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}
- (NSData*)getArchivedData{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}
- (instancetype)modelObjcetFromArchiveData:(NSData*)data{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
#pragma mark 对象拷贝
-(id)copyWithZone:(NSZone *)zone{
    id model = [[[self class] allocWithZone:zone] init];
    if(model){
        NSDictionary * propertList = [self propertyList:YES];
        [model setPartAttributes:propertList];
    }
    return model;
}
#pragma mark 获取模型的属性列表
//获得当前对象的所有属性列表，包括父类的属性 depth；父类深度
/**
 *  获得当前对象的所有属性列表，包括父类的属性 depth；父类深度
 *
 *  @param isIncludeValue 是否包含属性对应的值
 *  @param depth          父类层级深度
 *
 *  @return 属性列表
 */
-(NSDictionary *)propertyList:(BOOL)isIncludeValue depth:(NSInteger)depth
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    [self propertyList:isIncludeValue object:[self class] depth:depth dict:props];
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"%@",props);
    return props;
    
}
//获得当前对象的所有属性列表，如果isWrite为YES，返回的字典中同时包含了属性值，否则属性值为空
- (void)propertyList:(BOOL)isIncludeValue object:(Class)class depth:(NSInteger)depth  dict:(NSMutableDictionary*)dict
{
    //NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    //获得某个类的所有属性的拷贝
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i<outCount; i++) {
        //获得某一个属性
        objc_property_t property = properties[i];
        
        //获得属性名的字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding] ;
        
        //获得指定的属性的值
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (isIncludeValue) {
            if (propertyValue)
            {
                //保存属性名和属值值到字典中
                [dict setObject:propertyValue forKey:propertyName];
            }
        }
        else{
            //保存空对象到字典中,为了获得所有属性名的列表
            [dict setObject:[NSNull null] forKey:propertyName];
        }
    }
    //释放拷贝的属性列表
    free(properties);
    if([YXDatabaseHandle YXDatabaseHandleIsShowLogs])
    NSLog(@"%@",dict);
    if (depth>0&& [class superclass]!=[NSObject class]) {
        [self propertyList:isIncludeValue object:[class superclass] depth:depth-1 dict:dict];
    }
}
//获得当前对象的所有属性列表，如果isWrite为YES，返回的字典中同时包含了属性值，否则属性值为空
/**
 *  获取属性列表
 *
 *  @param isIncludeValue 是否包含属性对应的值
 *
 *  @return 属性列表字典
 */
- (NSDictionary *)propertyList:(BOOL)isIncludeValue
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    //获得某个类的所有属性的拷贝
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++) {
        //获得某一个属性
        objc_property_t property = properties[i];
        
        //获得属性名的字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding] ;
        
        //获得指定的属性的值
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (isIncludeValue) {
            if (propertyValue)
            {
                if([propertyValue isKindOfClass:[YXRootModel class]]){
                    NSDictionary * valueDict = [propertyValue propertyList:YES];
                    //保存属性名和属值值到字典中
                    [props setObject:valueDict forKey:propertyName];
                }else if([propertyValue isKindOfClass:[NSArray class]]){
                    NSArray * pvArray = propertyValue;
                    if([pvArray count]>0 && [pvArray.lastObject isKindOfClass:[YXRootModel class]]){
                        NSMutableArray * vArray = [[NSMutableArray alloc] init];
                        for(id value in (NSArray*)propertyValue){
                            NSDictionary * valueDict = [value propertyList:YES];
                            [vArray addObject:valueDict];
                        }
                        [props setObject:vArray forKey:propertyName];
                    }else{
                        [props setObject:propertyValue forKey:propertyName];
                    }
                }else{
                    //保存属性名和属值值到字典中
                    [props setObject:propertyValue forKey:propertyName];
                }
            }
        }
        else{
            //保存空对象到字典中,为了获得所有属性名的列表
            [props setObject:[NSNull null] forKey:propertyName];
        }
    }
    //释放拷贝的属性列表
    free(properties);
    //返回所需要的当前实例的属性字典（如果对象被赋值了，同时返回对象的值）
    return props;
}

-(NSString *)customDescription{
    return nil;
}
-(NSString *)description{
    NSDictionary * propertList = [self propertyList:YES];
    NSData * data = [NSJSONSerialization dataWithJSONObject:propertList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *propertysDesc = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString * desc = nil;
    NSString * customDesc = [self customDescription];
    if(nil == customDesc || 0 == customDesc.length ){
        desc = [NSString stringWithFormat:@"%@:{\r%@\r}",[super description],propertysDesc];
    }else{
        desc = [NSString stringWithFormat:@"%@:{\r%@\r,%@}",[super description],propertysDesc,customDesc];
    }
    return desc;
}

@end
