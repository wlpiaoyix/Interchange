//
//  UIView+Dialog.h
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPopupParams.h"
/**
 对话框
 */
@interface UIView(Dialog)

@property (nonatomic, retain, nullable) NSString * dialogTitle;
@property (nonatomic, retain, nullable) NSAttributedString * dialogAttributeTitle;

@property (nonatomic, retain, nullable) NSString * dialogMessage;
@property (nonatomic, retain, nullable) NSAttributedString * dialogAttributeMessage;

@property (nonatomic, copy, nullable) UIButton * _Nonnull (^blockButtonCreate)(NSUInteger index);

@property (nonatomic, copy, nullable) void (^blockButtonStyle)(UIButton * _Nonnull button, NSUInteger index);
@property (nonatomic, copy, nullable) void (^blockTitleStyle)(UIView * _Nonnull titleView);

-(void) dialogShowWithBlock:(nullable BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames;
-(void) dialogHidden;

@end
