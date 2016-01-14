//
//  NSObject+toDictinary.h
//  PYEntityManager
//
//  Created by wlpiaoyi on 15/10/14.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObjectToDictinary : NSObject 
/**
 通过JSON初始化对象
 */
+(instancetype) objectWithDictionary:(NSDictionary*) dictionary clazz:(Class) clazz;
/**
 通过对象生成JSON
 */
+(NSDictionary*) objectToDictionaryWithObejct:(NSObject*) obejct;
@end
