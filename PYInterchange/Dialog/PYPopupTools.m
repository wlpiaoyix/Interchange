//
//  PYDialogTools.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/27.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "PYPopupTools.h"
#import <Utile/EXTScope.h>
#import <Utile/PYViewAutolayoutCenter.h>
#import <Utile/PYUtile.h>
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


-(void) moveable:(BOOL) isMoveable{
    [self setIsMoveable:isMoveable];
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
    if (!touchView.isMoveable) {
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
    if (!touchView.isMoveable) {
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
    if (!touchView.isMoveable) {
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
    if (!touchView.isMoveable) {
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

-(BOOL) isMoveable{
    NSNumber *_touchesEnable = objc_getAssociatedObject(self, UIViewTouchesEnable);
    return !_touchesEnable ? false : _touchesEnable.boolValue;
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


static const void *UIViewDisplayViewPointer = &UIViewDisplayViewPointer;
static const void *UIViewMantlePointer = &UIViewMantlePointer;
static const void *IsShowPointer = &IsShowPointer;
static const void *OffsetSizePointer = &OffsetSizePointer;
static const void *OffsetOrginPointer = &OffsetOrginPointer;
static const void *BlockShowAnimationPointer = &BlockShowAnimationPointer;
static const void *BlockEndShowAnimationPointer = &BlockEndShowAnimationPointer;
static const void *BlockHiddenAnimationPointer = &BlockHiddenAnimationPointer;
static const void *BlockEndHiddenAnimationPointer = &BlockEndHiddenAnimationPointer;
static const NSString *OffsetSize_W = @"W";
static const NSString *OffsetSize_H = @"H";
static const NSString *OffsetOrgin_X = @"X";
static const NSString *OffsetOrgin_Y = @"Y";

@protocol TagMantelViewHookLayout <NSObject>@end
@protocol TagMantelViewHookAutoLayout <NSObject>@end
@interface PYMantleView : UIView<TagMantelViewHookAutoLayout> @end

@implementation PYMantleView
-(void) layoutSubviews{
    [super layoutSubviews];
}
@end

@implementation UIView(Popup)
-(void) _hooklayoutSubviews{
    [self _hooklayoutSubviews];
    if (![self mantleView] || ![self showView]) {
        return;
    }
    
    if(class_conformsToProtocol([[self mantleView] class], @protocol(TagMantelViewHookAutoLayout))){
        [self mantleView].frame = [UIScreen mainScreen].bounds;
    }
    [self reSetCenter];
}
-(void) popupShow{

    UIView *showView = [self showView];
    @synchronized(self){
        if ([showView isShow]) {
            return;
        }
    }
    [self setIsShow:true];
    if (![self mantleView]) {
        PYMantleView *_mantle = [PYMantleView new];
        _mantle.frame = [UIScreen mainScreen].bounds;
        _mantle.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.3];
//        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popupHidden)];
//        [_mantle addGestureRecognizer:tapGestureRecognizer];
        [self setMantleView:_mantle];
    }
    
    @weakify(self)
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        @strongify(self)
        SEL selLayoutSubviews = @selector(layoutSubviews);
        NSString *argSel = [NSString stringWithFormat:@"_hook%s",sel_getName(selLayoutSubviews)];
        SEL hookSel = sel_getUid([argSel UTF8String]);
        if (![self respondsToSelector:hookSel]) {
            return;
        }
        Method orgm = class_getInstanceMethod([UIView class], selLayoutSubviews);
        Method hookm = class_getInstanceMethod([UIView class], hookSel);
        method_exchangeImplementations(hookm, orgm);
    });
    [showView setBlockTouchEnd:^(CGPoint point, UIView *touchView) {
        @strongify(self);
        @weakify(self);
        [UIView animateWithDuration:.5 animations:^{
            @strongify(self);
            [self reSetCenter];
        }];
        
    }];
    [showView removeFromSuperview];
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [[self mantleView] addSubview:showView];
    });
    if ([[self mantleView] isKindOfClass:[PYMantleView class]]) {
        [[self mantleView] removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:[self mantleView]];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view setUserInteractionEnabled:NO];
        if (IOS7_OR_LATER) {
           
        }
    }
    [self setOffsetSize:[self showView].frame.size];
    [self reSetCenter];
    BlockPopupAnimation blockAnimation = [self blockShowAnimation];
    if (!blockAnimation) {
        CATransform3D transformx = CATransform3DIdentity;
        transformx = CATransform3DScale(transformx, 0, 0, 1);
        [self showView].layer.transform = transformx;
        [self mantleView].alpha = 0;
        blockAnimation = [[self class] __creteDefaultBlcokPopupShowAnmation];
    }
    BlockPopupEndAnmation blockEnd = [[self class] __creteDefaultBlcokPopupShowEndAnmationWithTarget:self];
    blockAnimation(self, blockEnd);
}

-(void) popupHidden{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view setUserInteractionEnabled:YES];
    @synchronized(self){
        UIView *showView = [self showView];
        if (!showView) {
            return;
        }
    }
    [self setIsShow:false];
    [self reSetCenter];
    if ([[self mantleView] isKindOfClass:[PYMantleView class]]) {
        self.mantleView.alpha = 1;
    }
    BlockPopupAnimation block = [self blockHiddenAnimation];
    if (!block) {
        block = [[self class] __creteDefaultBlcokPopupHiddenAnmation];
    }
    BlockPopupEndAnmation blockEnd = [[self class] __creteDefaultBlcokPopupHiddenEndAnmationWithTarget:self];
    block(self,blockEnd);
}

-(CGPoint) getCenterPoint{
    NSDictionary *dict = objc_getAssociatedObject(self, OffsetOrginPointer);
    if (!dict || ![self mantleView]) {
        return CGPointMake(-9999, -9999);
    }
    CGPoint p = CGPointMake(((NSNumber*)dict[OffsetOrgin_X]).floatValue, ((NSNumber*)dict[OffsetOrgin_Y]).floatValue);
    p.x = [self mantleView].frame.size.width * p.x;
    p.y = [self mantleView].frame.size.height * p.y;
    return p;
}
-(void) setCenterPoint:(CGPoint)center{
    if (center.x <= -9998 || center.y <= -9998) {
        objc_setAssociatedObject(self, OffsetOrginPointer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    CGSize size;
    if ([self mantleView]) {
        size = [self mantleView].frame.size;
    }else{
        size = [UIScreen mainScreen].bounds.size;
    }
    NSDictionary *dict = @{OffsetOrgin_X:[NSNumber numberWithFloat:center.x / size.width],OffsetOrgin_Y:[NSNumber numberWithFloat:center.y / size.height]};
    objc_setAssociatedObject(self, OffsetOrginPointer, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL) isShow{
    NSNumber *_isShow =  objc_getAssociatedObject(self, IsShowPointer);
    return _isShow ? _isShow.boolValue : false;
}
-(void) setIsShow:(BOOL) isShow{
    NSNumber *number = [NSNumber numberWithFloat:isShow];
    objc_setAssociatedObject(self, IsShowPointer, number, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void) reSetCenter{
    CGRect r = [self showView].frame;
    r.size = [self offsetSize];
    CGPoint p = [self getCenterPoint];
    if (p.x <= -9998) {
        p = CGPointMake([self mantleView].frame.size.width / 2, [self mantleView].frame.size.height / 2);
        [self setCenterPoint:p];
    }
    p.x = p.x - r.size.width / 2;
    p.y = p.y - r.size.height / 2;
    r.origin = p;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DScale(transform, 1, 1,1);
    [self showView].layer.transform = transform;
    [self showView].frame = r;
}
-(UIView*) mantleView{
    return objc_getAssociatedObject(self, UIViewMantlePointer);
}
-(void) setMantleView:(UIView*) mantleView{
    objc_setAssociatedObject(self, UIViewMantlePointer, mantleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView*) showView{
    UIView *view = objc_getAssociatedObject(self, UIViewDisplayViewPointer);
    if (!view) {
        view = self;
    }
    return view;
}
-(void) setShowView:(UIView*) view{
    if (view != self) {
        objc_setAssociatedObject(self, UIViewDisplayViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
-(CGSize) offsetSize{
    NSDictionary *dict = objc_getAssociatedObject(self, OffsetSizePointer);
    CGSize s = CGSizeMake(((NSNumber*)dict[OffsetSize_W]).floatValue, ((NSNumber*)dict[OffsetSize_H]).floatValue);
    return s;
}
-(void) setOffsetSize:(CGSize) size{
    NSDictionary *dict = @{OffsetSize_W:[NSNumber numberWithFloat:size.width],OffsetSize_H:[NSNumber numberWithFloat:size.height]};
    objc_setAssociatedObject(self, OffsetSizePointer, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) setBlockShowAnimation:(BlockPopupAnimation) block{
    objc_setAssociatedObject(self, BlockShowAnimationPointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockPopupAnimation) blockShowAnimation{
    BlockPopupAnimation block = objc_getAssociatedObject(self, BlockShowAnimationPointer);
    return block;
}
-(void) setBlockHiddenAnimation:(BlockPopupAnimation) block{
    objc_setAssociatedObject(self, BlockHiddenAnimationPointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockPopupAnimation) blockHiddenAnimation{
    BlockPopupAnimation block = objc_getAssociatedObject(self, BlockHiddenAnimationPointer);
    return block;
}

+(BlockPopupEndAnmation) __creteDefaultBlcokPopupShowEndAnmationWithTarget:(UIView*) view{
    static BlockPopupEndAnmation blockEnd;
    @weakify(view)
    blockEnd = ^(void){
        @strongify(view)
        CATransform3D transformx = CATransform3DIdentity;
        transformx = CATransform3DScale(transformx, 1, 1, 1);
        [view showView].layer.transform = transformx;
        [view showView].alpha = 1;
        if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
            [view mantleView].alpha = 1;
        }
    };
    return blockEnd;
}
+(BlockPopupAnimation) __creteDefaultBlcokPopupShowAnmation{
    static BlockPopupAnimation blockAnimation;
    blockAnimation = ^(UIView *view, BlockPopupEndAnmation _blockEnd_){
        @weakify(view)
        __block typeof(_blockEnd_) __b_BlockEnd = _blockEnd_;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(view)
            static NSUInteger totalNum = 20;
            NSUInteger num = totalNum;
            while (num) {
                if ([view isShow] == true) {
                    num--;
                    __block CGFloat value = (CGFloat)num/(CGFloat)totalNum;
                    value = 1 - value*value*value;
                    dispatch_barrier_async(dispatch_get_main_queue(), ^{
                        CATransform3D transformx = CATransform3DIdentity;
                        transformx = CATransform3DScale(transformx, value, value, 1);
                        [view showView].layer.transform = transformx;
                        [view showView].alpha = value;
                        if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                            [view mantleView].alpha = value;
                        }
                    });
                    [NSThread sleepForTimeInterval:0.5/20];
                }else{
                    num = 0;
                }
            }
            if (__b_BlockEnd) {
                __b_BlockEnd();
            }
        });
    };
    return blockAnimation;
}
+(BlockPopupEndAnmation) __creteDefaultBlcokPopupHiddenEndAnmationWithTarget:(UIView*) view{
    static BlockPopupEndAnmation blockEnd;
    @weakify(view)
    blockEnd = ^(void){
        @strongify(view)
        if ([view isShow] == false) {
            @weakify(view)
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                @strongify(view)
                UIView *showView = [view showView];
                [showView removeFromSuperview];
                [view removeFromSuperview];
                CATransform3D transformx = CATransform3DIdentity;
                transformx = CATransform3DScale(transformx, 1, 1, 1);
                [view showView].layer.transform = transformx;
                if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                    view.mantleView.alpha = 1;
                    [[view mantleView] removeFromSuperview];
                }
            });
        }
    };
    return blockEnd;
}
+(BlockPopupAnimation) __creteDefaultBlcokPopupHiddenAnmation{
    static BlockPopupAnimation blockAnimation;
    blockAnimation = ^(UIView *view, BlockPopupEndAnmation _blockEnd_){
        @weakify(view)
        __block typeof(_blockEnd_) __b_BlockEnd_ = _blockEnd_;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(view)
            static NSUInteger totalNum = 20;
            NSUInteger num = totalNum;
            @weakify(view)
            while (num) {
                num--;
                if ([view isShow] == false) {
                    @synchronized(view) {
                        __block CGFloat value = (CGFloat)num/(CGFloat)totalNum;
                        value = value*value*value;
                        dispatch_barrier_async(dispatch_get_main_queue(), ^{
                            @strongify(view)
                            CATransform3D transformx = CATransform3DIdentity;
                            transformx = CATransform3DScale(transformx, value, value, 1);
                            [view showView].layer.transform = transformx;
                            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                                view.mantleView.alpha = value;
                            }
                        });
                    }
                    [NSThread sleepForTimeInterval:0.5/20];
                }else{
                    num = 0;
                }
            }
            if (__b_BlockEnd_) {
                __b_BlockEnd_();
            }
        });
    };

    return blockAnimation;
}
@end



@implementation PYPopupTools
+(void) setMoveable:(BOOL) moveable targetView:(nonnull UIView*) targetView{
    [targetView moveable:moveable];
}

//==>
+(void) showWithTargetView:(nonnull UIView*) targetView{
    [targetView popupShow];
}
+(void) hiddenWithTargetView:(nonnull UIView*) targetView{
    [targetView popupHidden];
}
//<==
/**
 半通明的遮挡的View
 */
+(nonnull UIView*) mantleViewWithTargetView:(nonnull UIView*) targetView{
    return [targetView mantleView];
}
+(void) setMantleView:(UIView*) mantleView targetView:(nonnull UIView*) targetView{
    [targetView setMantleView:mantleView];
}
//==>
/**
 弹出框显示的位置
 */
+(CGPoint) getCenterPointFromTargetView:(nonnull UIView*) targetView{
    return [targetView getCenterPoint];
}
+(void) setCenterPoint:(CGPoint)center targetView:(nonnull UIView*) targetView{
    [targetView setCenterPoint:center];
}
//<==
//==>
/**
 弹出的View默认是当前的View
 */
+(nonnull UIView*) getShowViewFromTargetView:(nonnull UIView*) targetView{
    return [targetView showView];
}
+(void) setShowView:(nonnull UIView*) showView targetView:(nonnull UIView*) targetView{
    [targetView setShowView:showView];
}
//<==
//是否显示了
+(BOOL) isShowWithTargetView:(nonnull UIView*) targetView{
    return [targetView isShow];
}
+(void) setBlockShowAnimation:(BlockPopupAnimation) block targetView:(nonnull UIView*) targetView{
    [targetView setBlockShowAnimation:block];
}
+(void) setBlockHiddenAnimation:(BlockPopupAnimation) block targetView:(nonnull UIView*) targetView{
    [targetView setBlockHiddenAnimation:block];
}

@end