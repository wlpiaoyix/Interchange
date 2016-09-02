//
//  PYToastTools.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/11/3.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 信息展示
 */
@interface PYToastTools : NSObject
+(void) toastWithMessage:(nonnull NSString*) message;
+(void) toastWithMessage:(nonnull NSString*) message offsetY:(CGFloat) offsetY;
+(void) toastWithMessage:(nonnull NSString*) message offsetY:(CGFloat) offsetY timeInterval:(CGFloat) timeInterval;
+(void) toastWithTargetView:(nonnull UIView*) targetView offsetY:(CGFloat) offsetY timeInterval:(CGFloat) timeInterval;
@end
