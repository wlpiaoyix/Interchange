//
//  OrientationsListener.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PYOrientationListener <NSObject>
@optional
// Device oriented vertically, home button on the bottom
-(void) deviceOrientationPortrait;
// Device oriented vertically, home button on the top
-(void) deviceOrientationPortraitUpsideDown;
// Device oriented horizontally, home button on the right
-(void) deviceOrientationLandscapeLeft;
// Device oriented horizontally, home button on the left
-(void) deviceOrientationLandscapeRight;
// Device oriented horizontally, home button not support
-(void) deviceOrientationNotSupport:(UIDeviceOrientation) deviceOrientation;
@end
@interface PYOrientationListener : NSObject
//当前旋转方向
@property(nonatomic,readonly) UIDeviceOrientation orientation;
//旋转时间
@property(nonatomic) float duration;
+(nonnull instancetype) instanceSingle;
/**
 旋转当前装置
 */
-(void) attemptRotationToDeviceOrientation:(UIDeviceOrientation) deviceOrientation completion:(void (^ _Nullable)(void)) completion;
/**
 是否支持旋转到当前方向
 */
-(BOOL) isSupportOrientation:(UIDeviceOrientation) orientation;
-(void) addListener:(nonnull id<PYOrientationListener>) listener;
-(void) removeListenser:(nonnull id<PYOrientationListener>) listener;
@end
