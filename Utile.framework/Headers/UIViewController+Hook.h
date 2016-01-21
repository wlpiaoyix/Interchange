//
//  UIViewController+Hook.h
//  FrameWork
//
//  Created by wlpiaoyi on 15/9/1.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(hook)
+(BOOL) hookWithMethodNames:(nonnull NSArray<NSString *> *) methodNames;
@end

