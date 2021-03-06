//
//  PYDialogTools.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPopupParams.h"

@interface PYPopupTools : NSObject
+(void) setMoveable:(BOOL) moveable targetView:(nonnull UIView*) targetView;
//==>
+(void) showWithTargetView:(nonnull UIView*) targetView NS_DEPRECATED_IOS(1_0, 6_0, "no use") __TVOS_PROHIBITED;
+(void) hiddenWithTargetView:(nonnull UIView*) targetView;
//<==
/**
 半通明的遮挡的View-
 */
+(nonnull UIView*) mantleViewWithTargetView:(nonnull UIView*) targetView;
+(void) setMantleView:(nonnull UIView*) mantleView targetView:(nonnull UIView*) targetView;
//==>
/**
 弹出框显示的位置
 */
+(CGPoint) getCenterPointFromTargetView:(nonnull UIView*) targetView;
+(void) setCenterPoint:(CGPoint)center targetView:(nonnull UIView*) targetView;
//<==
//==>
/**
 弹出的View默认是当前的View
 */
+(nonnull UIView*) getShowViewFromTargetView:(nonnull UIView*) targetView;
+(void) setShowView:(nonnull UIView*) showView targetView:(nonnull UIView*) targetView;
//<==
//是否显示了
+(BOOL) isShowWithTargetView:(nonnull UIView*) targetView;
+(void) setBlockShowAnimation:(nullable BlockPopupAnimation) block targetView:(nonnull UIView*) targetView;
+(void) setBlockHiddenAnimation:(nullable BlockPopupAnimation) block targetView:(nonnull UIView*) targetView;
@end
