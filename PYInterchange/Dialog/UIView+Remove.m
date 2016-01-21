//
//  UIView+Remove.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+Remove.h"
#import "PYPopupParams.h"
#import <Utile/EXTScope.h>
#import <objc/runtime.h>

static const void *UIViewTouchesRemoveTarget = &UIViewTouchesRemoveTarget;
static const void *UIViewTouchesEnable = &UIViewTouchesEnable;

static const void *Dicscrollenabled_Pointer = &Dicscrollenabled_Pointer;

static const void *TouchesBegin_Pointer = &TouchesBegin_Pointer;
static const void *TouchesMove_Pointer = &TouchesMove_Pointer;
static const void *TouchesEnd_Pointer = &TouchesEnd_Pointer;

static const void *OffsetFrame_Pointer = &OffsetFrame_Pointer;
static const NSString *OffsetFrame_X = @"x";
static const NSString *OffsetFrame_Y = @"y";
static const NSString *OffsetFrame_W = @"w";
static const NSString *OffsetFrame_H = @"h";

@implementation UIView(Removeable)

-(BOOL) moveable{
    NSNumber *_touchesEnable = objc_getAssociatedObject(self, UIViewTouchesEnable);
    return !_touchesEnable ? false : _touchesEnable.boolValue;
}
-(void) setMoveable:(BOOL)moveable{
    
    [self setIsMoveable:moveable];
    [self setDicscrollenabled:[NSMutableDictionary new]];
    
    static dispatch_once_t predicate;
    @weakify(self)
    dispatch_once(&predicate, ^{
        @strongify(self)
        SEL selTouchBegin = @selector(touchesBegan:withEvent:);
        SEL selTouchMove = @selector(touchesMoved:withEvent:);
        SEL selTouchEnd = @selector(touchesEnded:withEvent:);
        SEL selTouchCancel = @selector(touchesCancelled:withEvent:);
        [self hook:selTouchBegin];
        [self hook:selTouchMove];
        [self hook:selTouchEnd];
        [self hook:selTouchCancel];
        
        SEL deallocSEL = sel_getUid("dealloc");
        SEL removeable_deallocSEL = @selector(removeable_dealloc);
        if (deallocSEL && [self respondsToSelector:deallocSEL]) {
            Method orgm = class_getInstanceMethod([UIView class], deallocSEL);
            Method hookm = class_getInstanceMethod([UIView class], removeable_deallocSEL);
            method_exchangeImplementations(hookm, orgm);
        }
    });
}

-(BlockTouchView) blockTouchBegin{
    return objc_getAssociatedObject(self, TouchesBegin_Pointer);
}
-(void) setBlockTouchBegin:(BlockTouchView) block{
    objc_setAssociatedObject(self, TouchesBegin_Pointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockTouchView) blockTouchMove{
    return objc_getAssociatedObject(self, TouchesMove_Pointer);
}
-(void) setBlockTouchMove:(BlockTouchView) block{
    objc_setAssociatedObject(self, TouchesMove_Pointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockTouchView) blockTouchEnd{
    return objc_getAssociatedObject(self, TouchesEnd_Pointer);
}
-(void) setBlockTouchEnd:(BlockTouchView) block{
    objc_setAssociatedObject(self, TouchesEnd_Pointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


-(void) hook:(SEL) orgSel{
    NSString *argArg = [NSString stringWithFormat:@"_hook%s",sel_getName(orgSel)];
    SEL hookSel = sel_getUid([argArg UTF8String]);
    if (![self respondsToSelector:hookSel]) {
        return;
    }
    Method orgm = class_getInstanceMethod([UIView class], orgSel);
    Method hookm = class_getInstanceMethod([UIView class], hookSel);
    method_exchangeImplementations(hookm, orgm);
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}
-(void) _hooktouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UIView *touchView = self;
    [touchView _hooktouchesBegan:touches withEvent:event];
    if (!touchView.moveable) {
        return;
    }
    for (NSString *key in [[touchView dicscrollenabled] allKeys]) {
        [[touchView dicscrollenabled] setValue:nil forKey:key];
    }
    CGRect frame = touchView.frame;
    @try {
        UITouch *touch = touches.anyObject;
        frame.origin = [touch locationInView: touchView.superview];
        BlockTouchView block = [touchView blockTouchBegin];
        if (block) {
            block(frame.origin, touchView);
        }
        [touchView setScrollView:touchView enabled:NO deep:0];
    }
    @finally {
        [touchView setOffsetFrame:frame];
    }
}
-(void) _hooktouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    UIView *touchView = self;
    [touchView _hooktouchesMoved:touches withEvent:event];
    if (!touchView.moveable) {
        return;
    }
    CGPoint point = [touch locationInView: touchView.superview];
    CGFloat widthSuper = touchView.superview.frame.size.width;
    CGFloat heighSuper = touchView.superview.frame.size.height;
    
    CGRect offsetFrame = [touchView offsetFrame];
    
    CGRect r = touchView.frame;
    r.origin.x += point.x - offsetFrame.origin.x;
    r.origin.y += point.y - offsetFrame.origin.y;
    if (r.origin.x<0) {
        r.origin.x = 0;
    }
    if (r.origin.y<0) {
        r.origin.y = 0;
    }
    if (r.origin.x>widthSuper-r.size.width) {
        r.origin.x = widthSuper-r.size.width;
    }
    if (r.origin.y>heighSuper-r.size.height) {
        r.origin.y = heighSuper-r.size.height;
    }
    touchView.frame = r;
    offsetFrame.origin = point;
    [touchView setOffsetFrame:offsetFrame];
    BlockTouchView block = [touchView blockTouchMove];
    if (block) {
        block(touchView.frame.origin, touchView);
    }
}
-(void) _hooktouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIView *touchView = self;
    [touchView _hooktouchesEnded:touches withEvent:event];
    if (!touchView.moveable) {
        return;
    }
    @try {
        CGRect offsetFrame = [touchView offsetFrame];
        offsetFrame.origin.x = offsetFrame.origin.y = 0;
        BlockTouchView block = [touchView blockTouchEnd];
        if (block) {
            block(touchView.frame.origin, touchView);
        }
    }
    @finally {
        [touchView setScrollView:touchView enabled:YES deep:0];
        NSMutableDictionary *dicscrollenabled = [touchView dicscrollenabled];
        for (NSString *key in [dicscrollenabled allKeys]) {
            [dicscrollenabled setValue:nil forKey:key];
        }
    }
}
-(void) _hooktouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UIView *touchView = self;
    [touchView _hooktouchesCancelled:touches withEvent:event];
    if (!touchView.moveable) {
        return;
    }
    [touchView setScrollView:touchView enabled:YES deep:0];
    NSMutableDictionary *dicscrollenabled = [touchView dicscrollenabled];
    for (NSString *key in [dicscrollenabled allKeys]) {
        [dicscrollenabled setValue:nil forKey:key];
    }
}



-(void) setScrollView:(UIView*) view enabled:(BOOL) enabled deep:(int) deep{
    if ([view isKindOfClass:[UIScrollView class]]) {
        NSString *key = [NSString stringWithFormat:@"%i",deep];
        if (enabled) {
            if ([[self dicscrollenabled] valueForKey:key]) {
                [((UIScrollView*)view) setScrollEnabled:YES];
            }else{
                [((UIScrollView*)view) setScrollEnabled:NO];
            }
        }else{
            if (((UIScrollView*)view).scrollEnabled) {
                [[self dicscrollenabled] setValue:@YES forKey:key];
            }else{
                [[self dicscrollenabled] setValue:nil forKey:key];
            }
            [((UIScrollView*)view) setScrollEnabled:NO];
        }
    }
    if ([view superview]) {
        [self setScrollView:[view superview] enabled:enabled deep:deep+1];
    }
}
-(void) setIsMoveable:(BOOL) isMoveable{
    objc_setAssociatedObject(self, UIViewTouchesEnable, [NSNumber numberWithFloat:isMoveable], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSMutableDictionary*) dicscrollenabled{
    return objc_getAssociatedObject(self, Dicscrollenabled_Pointer);
}
-(void) setDicscrollenabled:(NSMutableDictionary*) dicscrollenabled{
    objc_setAssociatedObject(self, Dicscrollenabled_Pointer, dicscrollenabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CGRect) offsetFrame{
    NSDictionary *dict = objc_getAssociatedObject(self, OffsetFrame_Pointer);
    if (!dict) {
        return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    CGRect r = CGRectMake(((NSNumber*)dict[OffsetFrame_X]).floatValue, ((NSNumber*)dict[OffsetFrame_Y]).floatValue, ((NSNumber*)dict[OffsetFrame_W]).floatValue, ((NSNumber*)dict[OffsetFrame_H]).floatValue);
    return r;
}
-(void) setOffsetFrame:(CGRect) frame{
    NSDictionary *dict = @{OffsetFrame_X:[NSNumber numberWithFloat:frame.origin.x],OffsetFrame_Y:[NSNumber numberWithFloat:frame.origin.y],OffsetFrame_W:[NSNumber numberWithFloat:frame.size.width],OffsetFrame_H:[NSNumber numberWithFloat:frame.size.height]};
    objc_setAssociatedObject(self, OffsetFrame_Pointer, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) removeable_dealloc{
    objc_removeAssociatedObjects(self);
    [self removeable_dealloc];
}

@end
