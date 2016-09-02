//
//  UIView+layerSwitch.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/4/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+LayerSwitch.h"
#import <objc/runtime.h>
#import <Utile/NSObject+Hook.h>

@interface NSObjectHookBaseDelegateLS : NSObject<NSObjectHookBaseDelegate>
-(void) beforeExcuteDealloc:(nonnull BOOL *) isExcute target:(nonnull NSObject *) target;
@end

@implementation NSObjectHookBaseDelegateLS
-(void) beforeExcuteDealloc:(nonnull BOOL *) isExcute target:(nonnull NSObject *) target{
    if ([target isKindOfClass:[UIView class]]) {
        [((UIView*) target).hashTableUIViewLayerSwitch removeAllObjects];
    }
}
@end

static NSObjectHookBaseDelegateLS * xNSObjectHookBaseDelegateLS;


static const void *UIViewLayerSwitchToFrontPointer = &UIViewLayerSwitchToFrontPointer;
static const void *UIViewLayerSwitchToBackPointer = &UIViewLayerSwitchToBackPointer;
static const void *HashTableUIViewLayerSwitchPointer = &HashTableUIViewLayerSwitchPointer;

@implementation UIView(LayerSwitch)
-(NSMutableArray<NSNumber *> *) hashTableUIViewLayerSwitch{
    return objc_getAssociatedObject(self, HashTableUIViewLayerSwitchPointer);
}
-(void) setHashTableUIViewLayerSwitch:(NSMutableArray<NSNumber *> *) hashTableUIViewLayerSwitch{
    objc_setAssociatedObject(self, HashTableUIViewLayerSwitchPointer, hashTableUIViewLayerSwitch, OBJC_ASSOCIATION_RETAIN);
}
-(void) setLayerSwitchToFront:(BOOL)layerSwitchToFront{
    [UIView layerSwitchHook];
    [self synLayerIndexHashWithSuperView:self.superview isRemove:!layerSwitchToFront];
    if (layerSwitchToFront) {
        [self.superview bringSubviewToFront:self];
    }
    objc_setAssociatedObject(self, UIViewLayerSwitchToFrontPointer, @(layerSwitchToFront), OBJC_ASSOCIATION_RETAIN);
}
-(BOOL) layerSwitchToFront{
    NSNumber * value = objc_getAssociatedObject(self, UIViewLayerSwitchToFrontPointer);
    if (value) {
        return value.floatValue;
    }
    return false;
}

-(void) setLayerSwitchToBack:(BOOL)layerSwitchToBack{
    [UIView layerSwitchHook];
    [self synLayerIndexHashWithSuperView:self.superview isRemove:!layerSwitchToBack];
    if (layerSwitchToBack) {
        [self.superview sendSubviewToBack:self];
    }
    objc_setAssociatedObject(self, UIViewLayerSwitchToBackPointer, @(layerSwitchToBack), OBJC_ASSOCIATION_RETAIN);
}
-(BOOL) layerSwitchToBack{
    NSNumber * value = objc_getAssociatedObject(self, UIViewLayerSwitchToBackPointer);
    if (value) {
        return value.floatValue;
    }
    return false;
}
-(void) layerSwitch_removeFromSuperview{
    if(self.layerSwitchToBack || self.layerSwitchToFront){
        [self synLayerIndexHashWithSuperView:self.superview isRemove:true];
    }
    [self layerSwitch_removeFromSuperview];
}
-(void) layerSwitch_addSubview:(UIView *) view{
    [self layerSwitch_addSubview:view];
    [view synLayerIndexHashWithSuperView:view.superview isRemove:!view.layerSwitchToFront && !view.layerSwitchToBack];
    if (![self.hashTableUIViewLayerSwitch count]) {
        return;
    }
    __unsafe_unretained typeof(self) uself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __unsafe_unretained typeof(uself) uuself = uself;
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (uuself.hashTableUIViewLayerSwitch) {
                for (NSNumber * viewPointer in uuself.hashTableUIViewLayerSwitch) {
                    UIView * view = (__bridge UIView *)((void *)viewPointer.integerValue);
                    if (view.layerSwitchToFront) {
                        [view.superview bringSubviewToFront:view];
                    }else if(view.layerSwitchToBack){
                        [view.superview sendSubviewToBack:view];
                    }
                }
            }
        });
    });
}

-(bool) synLayerIndexHashWithSuperView:(UIView *) superView isRemove:(BOOL) isRemove{
    if (!superView) {
        return false;
    }
    @synchronized (superView) {
        if (!superView.hashTableUIViewLayerSwitch) {
            superView.hashTableUIViewLayerSwitch = [NSMutableArray<NSNumber *> new];
        }
    }
    @synchronized (superView.hashTableUIViewLayerSwitch) {
        void * selfPointer = (__bridge void *)(self);
        NSInteger indexPointer = 0;
        for (NSNumber * pointer in superView.hashTableUIViewLayerSwitch) {
            if (pointer.integerValue == (NSInteger)selfPointer) {
                break;
            }
            indexPointer ++;
        }
        if (isRemove) {
            if(indexPointer < superView.hashTableUIViewLayerSwitch.count){
                [superView.hashTableUIViewLayerSwitch removeObjectAtIndex:indexPointer];
            }
        }else if(indexPointer >= superView.hashTableUIViewLayerSwitch.count){
            [superView.hashTableUIViewLayerSwitch addObject:@((NSInteger)selfPointer)];
        }
    }
    return true;
}

+(void) layerSwitchHook{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        [NSObject hookWithMethodNames:nil];
        if (!xNSObjectHookBaseDelegateLS) {
            xNSObjectHookBaseDelegateLS = [NSObjectHookBaseDelegateLS new];
        }
        [[NSObject delegateBase] addObject:xNSObjectHookBaseDelegateLS];
        
        SEL addSubviewSEL = @selector(addSubview:);
        SEL layerSwitch_addSubviewSEL = @selector(layerSwitch_addSubview:);
        Method orgm = class_getInstanceMethod([UIView class], addSubviewSEL);
        Method hookm = class_getInstanceMethod([UIView class], layerSwitch_addSubviewSEL);
        method_exchangeImplementations(hookm, orgm);
        
        SEL removeFromSuperviewSEL = @selector(removeFromSuperview);
        SEL layerSwitch_removeFromSuperviewSEL = @selector(layerSwitch_removeFromSuperview);
        orgm = class_getInstanceMethod([UIView class], removeFromSuperviewSEL);
        hookm = class_getInstanceMethod([UIView class], layerSwitch_removeFromSuperviewSEL);
        method_exchangeImplementations(hookm, orgm);
    });
}
@end
