//
//  PYDailogTools.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
//标题栏的背景颜色
extern UIColor * _Nullable STATIC_TITLEVIEW_BACKGROUNDCLOLOR;
//标题栏的边框颜色
extern UIColor * _Nullable STATIC_TITLEVIEW_BORDERCLOLOR;
//对话框的宽度，仅当在调用了 setMessage 方法后有效，其他情况以targetView的大小为准
extern CGFloat DailogFrameWith;
typedef void(^BlockDialogOpt)(UIView * _Nonnull view, NSUInteger index);

/**
 对话框
 */
@interface PYDailogTools : NSObject
//==>标题
+(void) setTitle:(nonnull NSString*) title targetView:(nonnull UIView*) targetView;
+(void) setTitleFont:(nonnull UIFont*) font targetView:(nonnull UIView*) targetView;
+(void) setBlockTitleStyle:(void (^_Nullable)(UIView * _Nullable titleView)) blockTitleStyle targetView:(nonnull UIView*) targetView;
//<==
/**
 文字类容，当前的view会被改变宽度
 @blockStyle 设置文字样式，需要CoreText的支持
 */
+(void) setMessage:(nonnull NSString*) message blockStyle:(void (^ _Nullable) (NSAttributedString * _Nonnull attArg)) blockStyle targetView:(nonnull UIView*) targetView;
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
+(void) showWithTargetView:(nonnull UIView*) targetView block:(nullable BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames;
@end
