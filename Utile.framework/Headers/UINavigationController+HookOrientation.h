//
//  UINavigationController+HookOrientation.h
//  PYFrameWork
//
//  Created by wlpiaoyi on 16/1/16.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+HookOrientation.h"

@interface UINavigationController(HookOrientation)
+(nullable id<UIViewcontrollerHookOrientationDelegate>) delegateOrientation;
+(void) setDelegateOrientation:(nullable id<UIViewcontrollerHookOrientationDelegate>) delegateOrientation;
+(BOOL) hookMethodOrientation;
@end
