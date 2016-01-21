//
//  UIViewController+Orientation.h
//  PYFrameWork
//
//  Created by wlpiaoyi on 16/1/16.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIViewcontrollerHookOrientationDelegate<NSObject>
@optional
//重写父类方法判断是否可以旋转
-(void) beforeExcuteShouldAutorotate:(nonnull BOOL *) isExcute target:(nonnull UIViewController *) target;
-(BOOL) aftlerExcuteShouldAutorotateWithTarget:(nonnull UIViewController *) target;

//重写父类方法判断支持的旋转方向
-(void) beforeExcuteSupportedInterfaceOrientations:(nonnull BOOL *) isExcute target:(nonnull UIViewController *) target;
-(NSUInteger) afterExcuteSupportedInterfaceOrientationsWithTarget:(nonnull UIViewController *) target;

//重写父类方法返回当前方向
-(void) beforeExcutePreferredInterfaceOrientationForPresentation:(nonnull BOOL *) isExcute target:(nonnull UIViewController *) target;
-(UIInterfaceOrientation) afterExcutePreferredInterfaceOrientationForPresentationWithTarget:(nonnull UIViewController *) target;

//⇒ 重写父类方法旋转开始和结束
-(void) beforeExcuteWillRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval)duration isExcute:(nonnull BOOL *) isExcute target:(nonnull UIViewController *) target;
-(void) afterExcuteWillRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval)duration target:(nonnull UIViewController *) target;
-(void) beforeExcuteDidRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation isExcute:(nonnull BOOL *) isExcute target:(nonnull UIViewController *) target;
-(void) afterExcuteDidRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation target:(nonnull UIViewController *) target;
@end

@interface UIViewController(HookOrientation)
+(nullable id<UIViewcontrollerHookOrientationDelegate>) delegateOrientation;
+(void) setDelegateOrientation:(nullable id<UIViewcontrollerHookOrientationDelegate>) delegateOrientation;
+(BOOL) hookMethodOrientation;
@end
