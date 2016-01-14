//
//  PYUtile.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/10/28.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IOS7_OR_LATER (!(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0))
#define IOS8_OR_LATER (!(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0))

extern const NSString * documentDir;
extern const NSString * cachesDir;
extern const NSString * systemVersion;

//==>
float boundsWidth();
float boundsHeight();
float appWidth();
float appHeight();
//<==

@interface PYUtile : NSObject
/**
 从xib加载数据，序列号要和当前class名称相同
 */
+(UIView*) loadXibWithViewClass:(Class) viewClass;
//==>
//计算文字占用的大小
+(CGSize) getBoundSizeWithTxt:(NSString*) txt font:(UIFont*) font size:(CGSize) size;
/**
 计算指定字体对应的高度
 */
+(CGFloat) getFontHeightWithSize:(CGFloat) size fontName:(NSString*) fontName;
/**
 计算指定高度对应的字体大小
 */
+(CGFloat) getFontSizeWithHeight:(CGFloat) height fontName:(NSString*) fontName;
//<==
//==>角度和弧度之间的转换
+(CGFloat) parseDegreesToRadians:(CGFloat) degrees;
+(CGFloat) parseRadiansToDegrees:(CGFloat) radians;
//<==
/**
 添加不向服务器备份的Document下的路径
 */
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)url;

@end
