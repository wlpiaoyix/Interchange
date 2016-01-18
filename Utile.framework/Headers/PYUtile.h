//
//  PYUtile.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/10/28.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef IOS7_OR_LATER
#define IOS7_OR_LATER (!(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0))
#endif

#ifndef IOS8_OR_LATER
#define IOS8_OR_LATER (!(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0))
#endif

#ifndef IOS9_OR_LATER
#define IOS9_OR_LATER ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_4))
#endif

#ifndef RGB
#define RGB(R,G,B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
#endif

#ifndef RGBA
#define RGBA(R,G,B,A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:(A)]
#endif

#ifndef PYUTILE_STATIC_INLINE
#define PYUTILE_STATIC_INLINE	static inline
#endif

#ifndef __OPTIMIZE__   // debug version
#    define NSLog(...) NSLog(__VA_ARGS__)
#    define LOG_ENTER_PAGE_EVENT(_label) {}
#    define BEGIN_LOG_PAGE {}
#    define END_LOG_PAGE {}
#else      // release version
#    define NSLog(...) {}
#    define LOG_ENTER_PAGE_EVENT(_label) [MobClick event:@"enter_page" label:(_label)]
#    define BEGIN_LOG_PAGE [MobClick beginLogPageView:NSStringFromClass([self class])]
#    define END_LOG_PAGE [MobClick endLogPageView:NSStringFromClass([self class])]

#endif

extern const NSString * documentDir;
extern const NSString * cachesDir;
extern const NSString * bundleDir;
extern const NSString * systemVersion;
extern double EARTH_RADIUS;//地球半径
//==>
float boundsWidth();
float boundsHeight();
float appWidth();
float appHeight();
//<==
//==>角度和弧度之间的转换
double parseDegreesToRadians(double degrees);
double parseRadiansToDegrees(double radians);
//<==
/**
 经纬度转换距离 (KM)
 */
double parseCoordinateToDistance(double lat1, double lng1, double lat2, double lng2);

@interface PYUtile : NSObject
+(UIViewController*) getCurrentController;
/**
 获取plist文件的类容
 */
+(NSDictionary*) getInfoPlistWithName:(NSString*) name;
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
/**
 汉字转拼音
 */
+ (NSString *) chineseToSpell:(NSString*)sourceString;
//==>等待框
+(void) showProgress:(NSString*) message;
+(void) hiddenProgress;
//<==
/**
 添加不向服务器备份的Document下的路径
 */
+(BOOL) addSkipBackupAttributeToItemAtURL:(NSString *)url;
/**
 简易发声
 */
+(BOOL) soundWithPath:(NSString*) path isShake:(BOOL) isShake;


@end
