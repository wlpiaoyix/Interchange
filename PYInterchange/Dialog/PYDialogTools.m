//
//  PYDialogTools.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYDialogTools.h"
#import "PYPopupTools.h"
#import "UIView+Dialog.h"


@implementation PYDialogTools
+(void) setTitle:(nonnull NSString*) title targetView:(nonnull UIView*) targetView{
    [targetView setDialogTitle:title];
}
+(void) setTitleFont:(nonnull UIFont*) font targetView:(nonnull UIView*) targetView{
    [targetView setDialogTitleFont:font];
}
+(void) setMessage:(nonnull NSString*) message blockStyle:(void (^) (NSMutableAttributedString* attArg)) blockStyle targetView:(nonnull UIView*) targetView{
    [targetView setDialogMessage:message blockStyle:blockStyle];
}
+(void) setBlockButtonCreate:(UIButton * _Nonnull (^_Nullable)(NSUInteger index)) blockButtonCreate targetView:(nonnull UIView*) targetView{
    [targetView setBlockButtonCreate:blockButtonCreate];
}
+(void) setBlockButtonStyle:(void (^_Nullable)(UIButton * _Nullable button, NSUInteger index)) blockButtonStyle targetView:(nonnull UIView*) targetView{
    [targetView setBlockButtonStyle:blockButtonStyle];
}
+(void) setBlockTitleStyle:(void (^_Nullable)(UIView * _Nullable titleView)) blockTitleStyle targetView:(nonnull UIView*) targetView{
    [targetView setBlockTitleStyle:blockTitleStyle];
}
+(void) showWithTargetView:(nonnull UIView*) targetView block:(nullable BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames{
    [targetView dialogShowWithBlock:block buttonNames:buttonNames];
}
+(void) hiddenWithTargetView:(nonnull UIView*) targetView{
    [PYPopupTools hiddenWithTargetView:targetView];
}
@end
