//
//  PYProgressView.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "PYProgressView.h"
#import <Utile/UILable+Expand.h>
#import <Utile/PYUtile.h>
#import <Utile/UIView+Expand.h>
#import <Utile/PYGraphicsDraw.h>
#import <Utile/PYGraphicsThumb.h>
#import <Utile/EXTScope.h>
#import <Utile/UIColor+Expand.h>

CGFloat MAXPYProgressViewWidth = 260;
CGFloat MAXPYProgressViewHeight = 300;
CGFloat MINPYProgressViewWith = 80;
CGFloat MINPYProgressViewHeight = 40;
CGFloat MAXPYProgressMessageSpace = 10;

@interface PYProgressView()

@property (nonatomic, strong) UILabel *lableMessage;
@property (nonatomic, strong) PYGraphicsThumb *gt;

@end

@implementation PYProgressView
-(instancetype) init{
    if (self = [super init]) {
        [self initWithParams];
    }
    return self;
}
-(void) initWithParams{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self setCornerRadiusAndBorder:5 borderWidth:1 borderColor:[UIColor whiteColor]];
    self.lableMessage = [UILabel new];
    self.lableMessage.backgroundColor = [UIColor clearColor];
    self.lableMessage.numberOfLines = 0;
    self.lableMessage.textAlignment = NSTextAlignmentCenter;
    self.lableMessage.font = [UIFont boldSystemFontOfSize:16];
    self.lableMessage.textColor = [UIColor whiteColor];
    [self addSubview:self.lableMessage];
    @weakify(self);
    self.gt = [PYGraphicsThumb graphicsThumbWithView:self.lableMessage block:^(CGContextRef ctx, id userInfo) {
        @strongify(self);
        CGFloat value = 0;
        if (userInfo && [userInfo isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)userInfo).floatValue;
        }
        value = MAX(0, value);
        value = MIN(1, value);
        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(self.lableMessage.frameWidth , self.lableMessage.frameHeight);
        UIColor *color1 = [UIColor grayColor];
        UIColor *color2 = [UIColor clearColor];
        [PYGraphicsDraw drawLinearGradientWithContext:ctx colorValues:(CGFloat[]){
            color1.red, color1.green, color1.blue, color1.alpha,
            color2.red, color2.green, color2.blue, color2.alpha,
            color1.red, color1.green, color1.blue, color1.alpha
        } alphas:(CGFloat[]){
            0.0f,
            value,
            1.0f
        } length:3  startPoint:p1 endPoint:p2];
    }];
    self.flagStop = true;
    self.flagStop = false;
}
-(void) setFlagStop:(BOOL)flagStop{
    if (_flagStop == false && flagStop == false) {
        return;
    }
    _flagStop = flagStop;
    if (!flagStop) {
        //  后台执行：
        @unsafeify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(self);
            CGFloat value = 0;
            while (!self.flagStop) {
                value = MAX(0, value);
                value = MIN(1, value);
                @unsafeify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.gt executDisplay:@(value)];
                });
                [NSThread sleepForTimeInterval:0.1f];
                value += 0.1;
                if (value >= 1) {
                    value = 0;
                }
            }
        });
    }
}
-(void) setProgressText:(NSAttributedString *)progressText{
    _progressText = progressText;
    self.lableMessage.attributedText = progressText;
    CGFloat width = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(9999, self.lableMessage.font.pointSize)].width;
    CGFloat height = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(width, 9999)].height;
    if (width >  MAXPYProgressViewWidth) {
        width = MAXPYProgressViewWidth;
        height = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(width, 9999)].height;
    }else if(width < MINPYProgressViewWith){
        width = MINPYProgressViewWith;
    }
    
    if (height > MAXPYProgressViewHeight) {
        height = MAXPYProgressViewHeight;
    }else if(height < MINPYProgressViewHeight){
        height = MINPYProgressViewHeight;
    }
    CGSize size = CGSizeMake(width, height);
    self.lableMessage.frameSize = size;
    self.lableMessage.frameOrigin = CGPointMake(MAXPYProgressMessageSpace, MAXPYProgressMessageSpace);
    self.frameSize = CGSizeMake(size.width + MAXPYProgressMessageSpace * 2, height + MAXPYProgressMessageSpace * 2);
    
}

-(void) dealloc{
    self.flagStop = true;
}

@end
