//
//  PYToastTools.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/11/3.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYToastTools.h"
#import "PYPopupTools.h"
#import <Utile/Utile.Framework.h>

@interface PYToastToolsView : UIView
@property (nonatomic,strong) NSString *message;
@end
@implementation PYToastToolsView{
@private UILabel *lableMessaage;
}
-(instancetype) init{
    if (self = [super init]) {
        lableMessaage = [UILabel new];
        lableMessaage.backgroundColor = [UIColor clearColor];
        lableMessaage.textColor = [UIColor whiteColor];
        lableMessaage.font = [UIFont systemFontOfSize:12];
        lableMessaage.textAlignment = NSTextAlignmentCenter;
        lableMessaage.numberOfLines = 0;
        self.backgroundColor = [UIColor grayColor];
        [self addSubview:lableMessaage];
        [self setCornerRadiusAndBorder:3 borderWidth:0.5 borderColor:[UIColor lightGrayColor]];
    }
    return self;
}

-(void) setMessage:(NSString *)message{
    _message = message;
    CGRect r = CGRectMake(8, 5, 9999, [PYUtile getFontHeightWithSize:lableMessaage.font.pointSize fontName:lableMessaage.font.fontName] + 10);
    lableMessaage.frame = r;
    lableMessaage.attributedText = [[NSAttributedString alloc] initWithString:_message];
    [lableMessaage automorphismWidth];
    [lableMessaage automorphismHeight];
    r = lableMessaage.frame;
    if (r.size.width > boundsWidth() * 2 / 3) {
        r.size.width = boundsWidth() * 2 / 3;
        r.size.height = 9999;
        lableMessaage.frame = r;
        [lableMessaage automorphismHeight];
    }
    r = self.frame;
    r.size = lableMessaage.frameSize;
    r.size.width += lableMessaage.frameX * 2;
    r.size.height += lableMessaage.frameY * 2;
    self.frame = r;
}

-(void) dealloc{
}
@end


@implementation PYToastTools
+(void) toastWithMessage:(nonnull NSString*) message{
    [self toastWithMessage:message offsetY:20];
}
+(void) toastWithMessage:(nonnull NSString*) message offsetY:(CGFloat) offsetY{
    [self toastWithMessage:message offsetY:offsetY timeInterval:2];
}
+(void) toastWithMessage:(NSString*) message offsetY:(CGFloat) offsetY timeInterval:(CGFloat) timeInterval{
    PYToastToolsView *ttv = [PYToastToolsView new];
    [ttv setMessage:message];
    [self toastWithTargetView:ttv offsetY:offsetY timeInterval:timeInterval];
}
+(void) toastWithTargetView:(nonnull UIView*) targetView offsetY:(CGFloat) offsetY timeInterval:(CGFloat) timeInterval{
    [PYPopupTools setMantleView:[UIApplication sharedApplication].keyWindow targetView:targetView];
    [PYPopupTools setBlockShowAnimation:^(UIView * _Nonnull view, BlockPopupEndAnmation  _Nullable block) {
        __block typeof(block) __bBlock = block;
        view.alpha = 0;
        __block __weak typeof(view) __bView = view;
        [UIView animateWithDuration:.5 animations:^{
            __bView.alpha = 1;
        } completion:^(BOOL finished) {
            __bBlock(__bView);
        }];
    } targetView:targetView];
    [PYPopupTools setBlockHiddenAnimation:^(UIView * _Nonnull view, BlockPopupEndAnmation  _Nullable block) {
        __block typeof(block) __bBlock = block;
        view.alpha = 1;
        __block __weak typeof(view) __bView = view;
        [UIView animateWithDuration:.5 animations:^{
            __bView.alpha = 0;
        } completion:^(BOOL finished) {
            __bBlock(__bView);
        }];
    } targetView:targetView];
    
    CGPoint point = CGPointMake(boundsWidth() / 2, boundsHeight()  - offsetY - targetView.frameHeight / 2);
    [PYPopupTools setCenterPoint:point targetView:targetView];
    [PYPopupTools showWithTargetView:targetView];
    __block __weak typeof(targetView) _ttv_ = targetView;
    __block CGFloat  _timeInterval_ = timeInterval;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block __weak typeof(_ttv_) __ttv_ = _ttv_;
        [NSThread sleepForTimeInterval:_timeInterval_];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_ttv_) {
                [PYPopupTools hiddenWithTargetView:__ttv_];
            }
        });
    });
}

@end
