//
//  PYDialogTools.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYPopupTools.h"
#import "UIView+Popup.h"
#import "UIView+Remove.h"



@implementation PYPopupTools
+(void) setMoveable:(BOOL) moveable targetView:(nonnull UIView*) targetView{
    targetView.moveable = moveable;
}

//==>
+(void) showWithTargetView:(nonnull UIView*) targetView{
    [targetView popupShow];
}
+(void) hiddenWithTargetView:(nonnull UIView*) targetView{
    [targetView popupHidden];
}
//<==
/**
 半通明的遮挡的View
 */
+(nonnull UIView*) mantleViewWithTargetView:(nonnull UIView*) targetView{
    return [targetView mantleView];
}
+(void) setMantleView:(UIView*) mantleView targetView:(nonnull UIView*) targetView{
    [targetView setMantleView:mantleView];
}
//==>
/**
 弹出框显示的位置
 */
+(CGPoint) getCenterPointFromTargetView:(nonnull UIView*) targetView{
    return targetView.centerPoint;
}
+(void) setCenterPoint:(CGPoint)center targetView:(nonnull UIView*) targetView{
    [targetView setCenterPoint:center];
}
//<==
//==>
/**
 弹出的View默认是当前的View
 */
+(nonnull UIView*) getShowViewFromTargetView:(nonnull UIView*) targetView{
    return [targetView showView];
}
+(void) setShowView:(nonnull UIView*) showView targetView:(nonnull UIView*) targetView{
    [targetView setShowView:showView];
}
//<==
//是否显示了
+(BOOL) isShowWithTargetView:(nonnull UIView*) targetView{
    return [targetView isShow];
}
+(void) setBlockShowAnimation:(BlockPopupAnimation) block targetView:(nonnull UIView*) targetView{
    [targetView setBlockShowAnimation:block];
}
+(void) setBlockHiddenAnimation:(BlockPopupAnimation) block targetView:(nonnull UIView*) targetView{
    [targetView setBlockHiddenAnimation:block];
}

@end