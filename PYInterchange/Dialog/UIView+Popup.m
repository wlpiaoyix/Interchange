//
//  UIView+Popup.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+Popup.h"
#import "UIView+Remove.h"
#import <Utile/EXTScope.h>
#import <Utile/PYViewAutolayoutCenter.h>
#import <Utile/PYUtile.h>
#import <objc/runtime.h>


CGFloat PYPopupAnimationTime = 10.0;
const CGFloat PYPopupAnimationTimeOffset = .05;

static const void *UIViewAnimationingPointer = &UIViewAnimationingPointer;
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

@interface PYMantleView : UIView<TagMantelViewHookLayout> @end
@implementation PYMantleView
-(void) removeFromSuperview{
    [super removeFromSuperview];
}
@end

@implementation UIView(Popup)
-(BOOL) isAnimationing{
    NSNumber *animationing = objc_getAssociatedObject(self, UIViewAnimationingPointer);
    return animationing ? [animationing boolValue] : false;
}
-(void) setIsAnimationing:(BOOL)isAnimationing{
    objc_setAssociatedObject(self, UIViewAnimationingPointer, @(isAnimationing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) _hooklayoutSubviews{
    
    [self _hooklayoutSubviews];
    
    if (!self.mantleView || self.isAnimationing) {
        return;
    }
    
    if(class_conformsToProtocol([self.mantleView class], @protocol(TagMantelViewHookLayout))){
        self.mantleView.frame = [UIScreen mainScreen].bounds;
        [self reSetCenter];
    }
    
}
-(void) popupShow{
    @synchronized(self){
        
        UIView *showView = self.showView;
        
        if ([showView isShow]) return;
        
        if (!self.mantleView) {
            PYMantleView *mantle = [PYMantleView new];
            mantle.frame = [UIScreen mainScreen].bounds;
            mantle.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.3];
            self.mantleView = mantle;
        }
        self.isShow = true;
        self.moveable = false;
        self.mantleView.moveable = true;
        
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
            [self.mantleView removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow addSubview:self.mantleView];
        }
        
        [self setOffsetSize:self.showView.frame.size];
        [self reSetCenter];
        
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
        
        [self setIsShow:false];
        
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
    NSDictionary *dict = objc_getAssociatedObject(self, OffsetOrginPointer);
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
        objc_setAssociatedObject(self, OffsetOrginPointer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    CGSize size;
    if (self.mantleView) {
        size = self.mantleView.frame.size;
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
+(BlockPopupAnimation) __creteDefaultBlcokPopupShowAnmation{
    BlockPopupAnimation blockAnimation = ^(UIView *view, BlockPopupEndAnmation _blockEnd_){
        @synchronized(view) {
            CATransform3D transformx = CATransform3DIdentity;
            transformx = CATransform3DScale(transformx, 0, 0, 1);
            [view showView].layer.transform = transformx;
            [view mantleView].alpha = 0;
        }
        @unsafeify(view);
        @unsafeify(_blockEnd_);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(view);
            @strongify(_blockEnd_);
            
            @synchronized(view) {
                
                view.isAnimationing = true;
                NSUInteger num = PYPopupAnimationTime;
                while (num) {
                    if ([view isShow] == true) {
                        num--;
                        __block CGFloat value = (CGFloat)num/PYPopupAnimationTime;
                        value = 1 - value*value*value;
                        @unsafeify(view);
                        dispatch_barrier_async(dispatch_get_main_queue(), ^{
                            @strongify(view);
                            CATransform3D transformx = CATransform3DIdentity;
                            transformx = CATransform3DScale(transformx, value, value, 1);
                            [view showView].layer.transform = transformx;
                            [view showView].alpha = value;
                            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                                [view mantleView].alpha = value;
                            }
                        });
                        [NSThread sleepForTimeInterval:PYPopupAnimationTimeOffset];
                    }else{
                        num = 0;
                    }
                }
                view.isAnimationing = false;
            }
            
            @unsafeify(view);
            @unsafeify(_blockEnd_);
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                @strongify(_blockEnd_);
                @strongify(view);
                
                if (!view) return;
                @synchronized(view) {
                    if(_blockEnd_)_blockEnd_(view);
                }
            });
        });
    };
    return blockAnimation;
}
+(BlockPopupEndAnmation) __creteDefaultBlcokPopupShowEndAnmation{
    BlockPopupEndAnmation blockEnd = ^(UIView * view){
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
            [view mantleView].alpha = 1;
            
        }
        
        @unsafeify(view);
        @unsafeify(_blockEnd_);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @synchronized(view) {
                view.isAnimationing = true;
                
                NSUInteger num = PYPopupAnimationTime;
                @strongify(view);
                @strongify(_blockEnd_);
                while (num) {
                    num--;
                    if ([view isShow] == false) {
                        __block CGFloat value = (CGFloat)num/PYPopupAnimationTime;
                        value = value*value*value;
                        @unsafeify(view);
                        dispatch_barrier_async(dispatch_get_main_queue(), ^{
                            @strongify(view);
                            CATransform3D transformx = CATransform3DIdentity;
                            transformx = CATransform3DScale(transformx, value, value, 1);
                            [view showView].layer.transform = transformx;
                            if ([[view mantleView] isKindOfClass:[PYMantleView class]]) {
                                view.mantleView.alpha = value;
                            }
                        });
                        [NSThread sleepForTimeInterval:PYPopupAnimationTimeOffset];
                    }else{
                        num = 0;
                    }
                    view.isAnimationing = false;
                }
                
                @unsafeify(view);
                @unsafeify(_blockEnd_);
                dispatch_barrier_async(dispatch_get_main_queue(), ^{
                    @strongify(_blockEnd_);
                    @strongify(view);
                    
                    if (!view) return;
                    
                    @synchronized(view) {
                        if(_blockEnd_)_blockEnd_(view);
                    }
                });
            }
        });
        
    };
    
    return blockAnimation;
}
+(BlockPopupEndAnmation) __creteDefaultBlcokPopupHiddenEndAnmation{
    BlockPopupEndAnmation blockEnd = ^(UIView * view){
        if ([view isShow] == false) {
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
