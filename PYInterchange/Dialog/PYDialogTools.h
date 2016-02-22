//
//  PYDialogTools.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPopupParams.h"

/**
 对话框
 */
@interface PYDialogTools : NSObject
//==>标题
+(void) setTitle:(nonnull NSString*) title targetView:(nonnull UIView*) targetView;
+(void) setTitleFont:(nonnull UIFont*) font targetView:(nonnull UIView*) targetView;
+(void) setBlockTitleStyle:(void (^_Nullable)(UIView * _Nullable titleView)) blockTitleStyle targetView:(nonnull UIView*) targetView;
//<==
/**
 文字类容，当前的view会被改变宽度
 @blockStyle 设置文字样式，需要CoreText的支持
 */
+(void) setMessage:(nonnull NSString*) message blockStyle:(void (^ _Nullable) (NSMutableAttributedString * _Nonnull attArg)) blockStyle targetView:(nonnull UIView*) targetView;
/**
 创建按钮的block
 */
+(void) setBlockButtonCreate:(UIButton * _Nonnull (^_Nullable)(NSUInteger index)) blockButtonCreate targetView:(nonnull UIView*) targetView;
/**
 设置按钮
 */
+(void) setBlockButtonStyle:(void (^_Nullable)(UIButton * _Nullable button, NSUInteger index)) blockButtonStyle targetView:(nonnull UIView*) targetView;
/**
 显示对话框
 */
+(void) showWithTargetView:(nonnull UIView*) targetView block:(nullable BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames NS_DEPRECATED_IOS(1_0, 6_0, "no use") __TVOS_PROHIBITED;
+(void) hiddenWithTargetView:(nonnull UIView*) targetView;
@end
