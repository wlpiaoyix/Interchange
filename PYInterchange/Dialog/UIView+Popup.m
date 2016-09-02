//
//  UIView+Popup.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+Popup.h"
#import "UIView+Remove.h"
#import "UIView+LayerSwitch.h"
#import <Utile/EXTScope.h>
#import <Utile/PYViewAutolayoutCenter.h>
#import <Utile/PYUtile.h>
#import <objc/runtime.h>


CGFloat PYPopupAnimationTime = 10.0;
const CGFloat PYPopupAnimationTimeOffset = .05;

static const void *UIViewPopupFramePointer = &UIViewPopupFramePointer;
static const void *UIViewPopupAnimationingPointer = &UIViewPopupAnimationingPointer;
static const void *UIViewPopupDisplayViewPointer = &UIViewPopupDisplayViewPointer;
static const void *UIViewPopupMantlePointer = &UIViewPopupMantlePointer;
static const void *UIViewPopupBasePointer = &UIViewPopupBasePointer;
static const void *UIViewPopupIsShowPointer = &UIViewPopupIsShowPointer;
static const void *UIViewPopupOffsetSizePointer = &UIViewPopupOffsetSizePointer;
static const void *UIViewPopupOffsetOrginPointer = &UIViewPopupOffsetOrginPointer;
static const void *UIViewPopupBlockShowAnimationPointer = &UIViewPopupBlockShowAnimationPointer;
static const void *UIViewPopupBlockEndShowAnimationPointer = &UIViewPopupBlockEndShowAnimationPointer;
static const void *UIViewPopupBlockHiddenAnimationPointer = &UIViewPopupBlockHiddenAnimationPointer;
static const NSString *OffsetSize_W = @"W";
static const NSString *OffsetSize_H = @"H";
static const NSString *OffsetOrgin_X = @"X";
static const NSString *OffsetOrgin_Y = @"Y";


@protocol TagMantelViewHookLayout <NSObject>@end
@protocol TagMantelViewHookAutoLayout <NSObject>@end

@interface PYMantleView : UIView<TagMantelViewHookLayout> @end
@implementation PYMantleView
-(void) removeFromSuperview{
    [super removeFromSuperview];
}
@end
@interface PYRect : NSObject
@property (nonatomic) CGRect rect;
@end
@implementation PYRect

-(instancetype) init{
    if (self = [super init]) {
        self.rect = CGRectMake(-1, -1, -1, -1);
    }
    return self;
}

@end

@implementation UIView(Popup)
-(CGRect) frameOrg{
    PYRect * pyRect = objc_getAssociatedObject(self, UIViewPopupFramePointer);
    return pyRect ? pyRect.rect : CGRectNull;
}
-(void) setFrameOrg:(CGRect) frame{
    PYRect * pyRect = objc_getAssociatedObject(self, UIViewPopupFramePointer);
    pyRect = pyRect ? pyRect : [PYRect new];
    pyRect.rect = frame;
    objc_setAssociatedObject(self, UIViewPopupFramePointer, pyRect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL) isAnimationing{
    NSNumber *animationing = objc_getAssociatedObject(self, UIViewPopupAnimationingPointer);
    return animationing ? [animationing boolValue] : false;
}
-(void) setIsAnimationing:(BOOL)isAnimationing{
    objc_setAssociatedObject(self, UIViewPopupAnimationingPointer, @(isAnimationing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) _hooklayoutSubviews{
    
    [self _hooklayoutSubviews];
    if (IOS8_OR_LATER) {
        if (!self.mantleView || self.isAnimationing) {
            return;
        }
        CGRect rectOrg = [self frameOrg];
        if ((rectOrg.size.width == self.showView.bounds.size.width && rectOrg.size.height == self.showView.bounds.size.height)
            && ([UIScreen mainScreen].bounds.size.width == self.mantleView.frame.size.width && [UIScreen mainScreen].bounds.size.height == self.mantleView.frame.size.height)) {
            return;
        }
        [self setFrameOrg:self.showView.bounds];
        if(class_conformsToProtocol([self.mantleView class], @protocol(TagMantelViewHookLayout))){
            self.mantleView.frame = [UIScreen mainScreen].bounds;
            [self reSetCenter];
        }
    }
}
-(void) popupShow{
    @synchronized(self){
        
        UIView *showView = self.showView;
        
        if (showView.isShow) return;
        
        self.isShow = true;
        if (self.baseView == nil) {
            self.baseView = [UIApplication sharedApplication].delegate.window;
        }
        
        if (!self.mantleView) {
            PYMantleView *mantle = [PYMantleView new];
            mantle.frame = self.baseView.bounds;
            mantle.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.3];
            [self.baseView addSubview:mantle];
            self.mantleView = mantle;
        }
        showView.moveable = true;
        
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
            [UIView animateWithDuration:PYPopupAnimationTime * PYPopupAnimationTimeOffset animations:^{
                @strongify(self);
                [self reSetCenter];
            }];
        }];
        
        [showView removeFromSuperview];
        [self.mantleView addSubview:showView];
        if ([self.mantleView isKindOfClass:[PYMantleView class]]) {
           self.mantleView.layerSwitchToFront = YES;
        }
        
        [self setOffsetSize:self.showView.frame.size];
        [self reSetCenter];
        [self setFrameOrg:self.showView.bounds];
        
        BlockPopupAnimation blockAnimation = [self blockShowAnimation];
        if (!blockAnimation) {
            blockAnimation = [[self class] __creteDefaultBlcokPopupShowAnmation];
        }
        BlockPopupEndAnmation blockEnd = [[self class] __creteDefaultBlcokPopupShowEndAnmation];
        blockAnimation(self, blockEnd);
    }
}

-(void) popupHidden{
    @synchronized(self) {
        
        UIView *showView = self.showView;
        if (!showView) {
            return;
        }
        @synchronized (self) {
            if (!self.isShow) {
                return;
            }
            self.isShow = false;
        }
        
        [self reSetCenter];
        
        if ([self.mantleView isKindOfClass:[PYMantleView class]]) {
            self.mantleView.alpha = 1;
        }
        
        BlockPopupAnimation block = [self blockHiddenAnimation];
        if (!block) {
            block = [[self class] __creteDefaultBlcokPopupHiddenAnmation];
        }
        BlockPopupEndAnmation blockEnd = [[self class] __creteDefaultBlcokPopupHiddenEndAnmation];
        block(self,blockEnd);
    }
}

-(CGPoint) centerPoint{
    NSDictionary *dict = objc_getAssociatedObject(self, UIViewPopupOffsetOrginPointer);
    if (!dict || !self.mantleView) {
        return CGPointMake(-9999, -9999);
    }
    CGPoint p = CGPointMake(((NSNumber*)dict[OffsetOrgin_X]).floatValue, ((NSNumber*)dict[OffsetOrgin_Y]).floatValue);
    p.x = self.mantleView.frame.size.width * p.x;
    p.y = self.mantleView.frame.size.height * p.y;
    return p;
}

-(void) setCenterPoint:(CGPoint)center{
    if (center.x <= -9998 || center.y <= -9998) {
        objc_setAssociatedObject(self, UIViewPopupOffsetOrginPointer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    CGSize size;
    if (self.mantleView) {
        size = self.mantleView.frame.size;
    }else{
        size = [UIScreen mainScreen].bounds.size;
    }
    NSDictionary *dict = @{OffsetOrgin_X:[NSNumber numberWithFloat:center.x / size.width],OffsetOrgin_Y:[NSNumber numberWithFloat:center.y / size.height]};
    objc_setAssociatedObject(self, UIViewPopupOffsetOrginPointer, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL) isShow{
    NSNumber *_isShow =  objc_getAssociatedObject(self, UIViewPopupIsShowPointer);
    return _isShow ? _isShow.boolValue : false;
}
-(void) setIsShow:(BOOL) isShow{
    NSNumber *number = [NSNumber numberWithFloat:isShow];
    objc_setAssociatedObject(self, UIViewPopupIsShowPointer, number, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void) reSetCenter{
    @synchronized(self) {
        CGRect r = self.showView.frame;
        r.size = [self offsetSize];
        CGPoint p = self.centerPoint;
        if (p.x <= -9998) {
            p = CGPointMake(self.mantleView.frame.size.width / 2, self.mantleView.frame.size.height / 2);
            [self setCenterPoint:p];
        }
        p.x = p.x - r.size.width / 2;
        p.y = p.y - r.size.height / 2;
        r.origin = p;
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DScale(transform, 1, 1,1);
        self.showView.layer.transform = transform;
        self.showView.frame = r;
    }
}
-(UIView*) baseView{
    return objc_getAssociatedObject(self, UIViewPopupBasePointer);
}
-(void) setBaseView:(UIView*) baseView{
    objc_setAssociatedObject(self, UIViewPopupBasePointer, baseView, OBJC_ASSOCIATION_ASSIGN);
}
-(UIView*) mantleView{
    return objc_getAssociatedObject(self, UIViewPopupMantlePointer);
}
-(void) setMantleView:(UIView*) mantleView{
    objc_setAssociatedObject(self, UIViewPopupMantlePointer, mantleView, OBJC_ASSOCIATION_ASSIGN);
}
-(UIView*) showView{
    UIView *view = objc_getAssociatedObject(self, UIViewPopupDisplayViewPointer);
    if (!view) {
        view = self;
    }
    return view;
}
-(void) setShowView:(UIView*) view{
    if (view != self) {
        objc_setAssociatedObject(self, UIViewPopupDisplayViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
-(CGSize) offsetSize{
    NSDictionary *dict = objc_getAssociatedObject(self, UIViewPopupOffsetSizePointer);
    CGSize s = CGSizeMake(((NSNumber*)dict[OffsetSize_W]).floatValue, ((NSNumber*)dict[OffsetSize_H]).floatValue);
    return s;
}
-(void) setOffsetSize:(CGSize) size{
    NSDictionary *dict = @{OffsetSize_W:[NSNumber numberWithFloat:size.width],OffsetSize_H:[NSNumber numberWithFloat:size.height]};
    objc_setAssociatedObject(self, UIViewPopupOffsetSizePointer, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) setBlockShowAnimation:(BlockPopupAnimation) block{
    objc_setAssociatedObject(self, UIViewPopupBlockShowAnimationPointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockPopupAnimation) blockShowAnimation{
    BlockPopupAnimation block = objc_getAssociatedObject(self, UIViewPopupBlockShowAnimationPointer);
    return block;
}
-(void) setBlockHiddenAnimation:(BlockPopupAnimation) block{
    objc_setAssociatedObject(self, UIViewPopupBlockHiddenAnimationPointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockPopupAnimation) blockHiddenAnimation{
    BlockPopupAnimation block = objc_getAssociatedObject(self, UIViewPopupBlockHiddenAnimationPointer);
    return block;
}
+(BlockPopupAnimation) __creteDefaultBlcokPopupShowAnmation{
    BlockPopupAnimation blockAnimation = ^(UIView *view, BlockPopupEndAnmation _blockEnd_){
        @synchronized(view) {
            
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 2, 2, 1);
            [view showView].layer.transform = transformx;
            [view showView].alpha = 0;
            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                [view mantleView].alpha = 0;
            }
        }
        
        view.isAnimationing = true;
        @unsafeify(view);
        @unsafeify(_blockEnd_);
        [UIView animateWithDuration:PYPopupAnimationTime * PYPopupAnimationTimeOffset animations:^{
            @strongify(view);
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            [view showView].layer.transform = transformx;
            [view showView].alpha = 1;
            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                [view mantleView].alpha = 1;
            }
        } completion:^(BOOL finished) {
            @strongify(_blockEnd_);
            @strongify(view);
            if (!view) return;
            @synchronized(view) {
                if(_blockEnd_)_blockEnd_(view);
            }
        }];
        
    };
    return blockAnimation;
}
+(BlockPopupEndAnmation) __creteDefaultBlcokPopupShowEndAnmation{
    BlockPopupEndAnmation blockEnd = ^(UIView * view){
        view.isAnimationing = false;
        if ([view isShow]) {
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            [view showView].layer.transform = transformx;
            [view showView].alpha = 1;
            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                [view mantleView].alpha = 1;
            }
        }
    };
    return blockEnd;
}

+(BlockPopupAnimation) __creteDefaultBlcokPopupHiddenAnmation{
    BlockPopupAnimation blockAnimation = ^(UIView *view, BlockPopupEndAnmation _blockEnd_){
        
        @synchronized(view) {
            
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            [view showView].layer.transform = transformx;
            [view showView].alpha = 1;
            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                [view mantleView].alpha = 1;
            }
        }
        
        
        view.isAnimationing = true;
        @unsafeify(view);
        @unsafeify(_blockEnd_);
        [UIView animateWithDuration:PYPopupAnimationTime * PYPopupAnimationTimeOffset * .2 animations:^{
            @strongify(view);
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1.2, 1.2, 1);
            [view showView].layer.transform = transformx;
            
        } completion:^(BOOL finished) {
            @strongify(_blockEnd_);
            @strongify(view);
            
            @unsafeify(view);
            @unsafeify(_blockEnd_);
            [UIView animateWithDuration:PYPopupAnimationTime * PYPopupAnimationTimeOffset animations:^{
                @strongify(view);
                CATransform3D transformx = CATransform3DIdentity;
                transformx = CATransform3DScale(transformx, .01, .01, 1);
                [view showView].layer.transform = transformx;
                [view showView].alpha = 0;
                if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                    [view mantleView].alpha = 0;
                }
                
            } completion:^(BOOL finished) {
                @strongify(_blockEnd_);
                @strongify(view);
                
                view.isAnimationing = false;
                
                if (!view) return;
                @synchronized(view) {
                    if(_blockEnd_)_blockEnd_(view);
                }
            }];
        }];
        
    };
    
    return blockAnimation;
}
+(BlockPopupEndAnmation) __creteDefaultBlcokPopupHiddenEndAnmation{
    BlockPopupEndAnmation blockEnd = ^(UIView * view){
        view.isAnimationing = false;
        if (view.isShow == false) {
            UIView *showView = [view showView];
            UIView *mantleView = [view mantleView];
            [showView removeFromSuperview];
            [view removeFromSuperview];
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 1, 1, 1);
            showView.layer.transform = transformx;
            if ([mantleView isKindOfClass:[PYMantleView class]]) {
                mantleView.alpha = 1;
                [mantleView removeFromSuperview];
            }
        }
    };
    return blockEnd;
}
@end
