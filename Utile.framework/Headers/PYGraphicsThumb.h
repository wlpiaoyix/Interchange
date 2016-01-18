//
//  PYGraphicsThumb.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/11/30.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^blockGraphicsLayerDraw)(CGContextRef ctx, id userInfo);

@interface PYGraphicsThumb : NSObject
+(instancetype) graphicsThumbWithView:(nonnull UIView*) view block:(blockGraphicsLayerDraw) block;
-(void) executDisplay:(id) userInfo;
@end
