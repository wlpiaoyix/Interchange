//
//  PYHook.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/12/14.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYHook : NSObject
+(BOOL) mergeHookInstanceWithTarget:(Class) target action:(SEL) action blockBefore:(BOOL (^) (NSInvocation * invoction)) blockBefore blockAfter:(void (^) (NSInvocation * invoction)) blockAfter;
+(BOOL) removeHookInstanceWithTarget:(Class) target action:(SEL) action;

+(BOOL) mergeHookClassWithTarget:(Class)target action:(SEL)action blockBefore:(BOOL (^)(NSInvocation *))blockBefore blockAfter:(void (^)(NSInvocation *))blockAfter;
+(BOOL) removeHookClassWithTarget:(Class)target action:(SEL)action;

+(nonnull NSArray<NSString *> *) createClassImp;
@end
