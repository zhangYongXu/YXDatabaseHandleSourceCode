//
//  NSString+YXStringEX.m
//  YXDatabaseHandle
//
//  Created by 拓之林 on 16/3/1.
//  Copyright © 2016年 拓之林. All rights reserved.
//

#import "NSString+YXStringEX.h"

@implementation NSString (YXStringEX)
-(BOOL)isEmpty{
    NSString * newSelf = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(nil == self
       || self.length ==0
       || [self isEqualToString:@""]
       || [self isEqualToString:@"<null>"]
       || [self isEqualToString:@"(null)"]
       || [self isEqualToString:@"null"]
       || newSelf.length ==0
       || [newSelf isEqualToString:@""]
       || [newSelf isEqualToString:@"<null>"]
       || [newSelf isEqualToString:@"(null)"]
       || [newSelf isEqualToString:@"null"]
       ){
        return YES;
    }else{
        return NO;
    }
}
@end
