//
//  UIView+Dialog.h
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPopupParams.h"

@interface UIView(Dialog)

@property (nonatomic, strong, nullable) NSString * dailogTitle;
@property (nonatomic, strong, nullable) UIFont * dailogTitleFont;

@property (nonatomic, copy, nullable) BlockDialogOpt blockDialogOpt;
@property (nonatomic, copy, nullable) UIButton * _Nonnull (^blockButtonCreate)(NSUInteger index);
@property (nonatomic, copy, nullable) void (^blockButtonStyle)(UIButton * _Nonnull button, NSUInteger index);
@property (nonatomic, copy, nullable) void (^blockTitleStyle)(UIView * _Nonnull titleView);

-(void) setDialogMessage:(nonnull NSString *) message blockStyle:(void (^ _Nullable) (NSMutableAttributedString * _Nonnull attArg)) blockStyle;
-(void) showWithBlock:(nullable BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames;

@end