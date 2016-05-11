//
//  UIView+layerSwitch.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/4/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+LayerSwitch.h"
#import <objc/runtime.h>


static const void *UIViewLayerSwitchToFrontPointer = &UIViewLayerSwitchToFrontPointer;
static const void *UIViewLayerSwitchToBackPointer = &UIViewLayerSwitchToBackPointer;
static NSHashTable<UIView *> * HashTableUIViewLayerSwitch;

@implementation UIView(LayerSwitch)

-(void) setLayerSwitchToFront:(BOOL)layerSwitchToFront{
    [UIView layerSwitchHook];
    @synchronized (HashTableUIViewLayerSwitch) {
        BOOL containSelf = [HashTableUIViewLayerSwitch containsObject:self];
        if (layerSwitchToFront && !containSelf) {
            [HashTableUIViewLayerSwitch addObject:self];
        }else if(containSelf){
            [HashTableUIViewLayerSwitch removeObject:self];
        }
    }
    
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
    @synchronized (HashTableUIViewLayerSwitch) {
        BOOL containSelf = [HashTableUIViewLayerSwitch containsObject:self];
        if (layerSwitchToBack && !containSelf) {
            [HashTableUIViewLayerSwitch addObject:self];
        }else if(containSelf){
            [HashTableUIViewLayerSwitch removeObject:self];
        }
    }
    
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
-(void) layerSwitch_addSubview:(UIView *) view{
    [self layerSwitch_addSubview:view];
    [UIView layerSwitchCheck];
}
-(void) layerSwitch_dealloc{
    @synchronized (HashTableUIViewLayerSwitch) {
        if([HashTableUIViewLayerSwitch containsObject:self]){
            [HashTableUIViewLayerSwitch removeObject:self];
        }
    }
    objc_removeAssociatedObjects(self);
    [self layerSwitch_dealloc];
}

/**
 检查图层
 */
+(void) layerSwitchCheck{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (HashTableUIViewLayerSwitch) {
                for (UIView * _view_ in HashTableUIViewLayerSwitch) {
                    if (_view_.layerSwitchToFront) {
                        [_view_.superview bringSubviewToFront:_view_];
                    }else if(_view_.layerSwitchToBack){
                        [_view_.superview sendSubviewToBack:_view_];
                    }
                }
            }
        });
    });
}

+(void) layerSwitchHook{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        SEL deallocSEL = sel_getUid("dealloc");
        SEL layerSwitch_deallocSEL = @selector(layerSwitch_dealloc);
        Method orgm = class_getInstanceMethod([UIView class], deallocSEL);
        Method hookm = class_getInstanceMethod([UIView class], layerSwitch_deallocSEL);
        method_exchangeImplementations(hookm, orgm);
        
        SEL addSubviewSEL = @selector(addSubview:);
        SEL layerSwitch_addSubviewSEL = @selector(layerSwitch_addSubview:);
        orgm = class_getInstanceMethod([UIView class], addSubviewSEL);
        hookm = class_getInstanceMethod([UIView class], layerSwitch_addSubviewSEL);
        method_exchangeImplementations(hookm, orgm);
        HashTableUIViewLayerSwitch =[NSHashTable<UIView *> weakObjectsHashTable];
    });
}
@end
