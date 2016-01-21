//
//  PYSheetTools.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/11/6.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYSheetTools.h"
#import "PYPopupTools.h"
#import <Utile/PYUtile.h>
#import <Utile/UIView+Expand.h>

@implementation PYSheetTools
//==>
+(void) showWithTargetView:(nonnull UIView*) targetView{
    UIView *showView = [PYPopupTools getShowViewFromTargetView:targetView];
    CGPoint point = CGPointMake(boundsWidth() / 2, boundsHeight() - showView.frameHeight / 2);
    [PYPopupTools setCenterPoint:point targetView:targetView];
    [PYPopupTools setBlockShowAnimation:^(UIView * _Nonnull view, BlockPopupEndAnmation  _Nullable block) {
        UIView *__showView = [PYPopupTools getShowViewFromTargetView:view];
        __showView.frameY = boundsHeight();
        __block typeof(block) __bBlock = block;
        __block __weak typeof(view) __bView = showView;
        [UIView animateWithDuration:.5 animations:^{
            __bView.frameY = boundsHeight() - __bView.frameHeight;
            __bView.alpha = 1;
        } completion:^(BOOL finished) {
            __bBlock(__bView);
        }];
    } targetView:targetView];
    [PYPopupTools setBlockHiddenAnimation:^(UIView * _Nonnull view, BlockPopupEndAnmation  _Nullable block) {
        UIView *showView = [PYPopupTools getShowViewFromTargetView:view];
        __block typeof(block) __bBlock = block;
        __block __weak typeof(view) __bView = showView;
        [UIView animateWithDuration:.5 animations:^{
           __bView.frameY = boundsHeight();
            __bView.alpha = 0;
        } completion:^(BOOL finished) {
            __bBlock(__bView);
        }];
    } targetView:targetView];
    
    [PYPopupTools showWithTargetView:targetView];
}
+(void) hiddenWithTargetView:(nonnull UIView*) targetView{
    [PYPopupTools hiddenWithTargetView:targetView];
}
//<==
@end
