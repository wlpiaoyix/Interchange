//
//  UIView+Popup.h
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPopupParams.h"

@interface UIView(Popup)

@property (nonatomic) BOOL isShow;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) CGSize offsetSize;

@property (nonatomic,copy, nullable) BlockPopupAnimation blockShowAnimation;
@property (nonatomic,copy, nullable) BlockPopupAnimation blockHiddenAnimation;

@property (nonatomic, strong, nonnull) UIView * mantleView;
@property (nonatomic, strong, nonnull) UIView * showView;

-(void) popupShow;
-(void) popupHidden;

-(void) reSetCenter;

@end
