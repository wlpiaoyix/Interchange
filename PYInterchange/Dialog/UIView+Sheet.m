//
//  UIView+Sheet.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/5/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+Sheet.h"
#import <objc/runtime.h>

static const void *UIViewSheetFloatViewPointer = &UIViewSheetFloatViewPointer;
static const void *UIViewSheetTitleViewPointer = &UIViewSheetTitleViewPointer;
static const void *UIViewSheetTitlePointer = &UIViewSheetTitlePointer;
static const void *UIViewBlockSheetShowPointer = &UIViewBlockSheetShowPointer;
static const void *UIViewBlockSheetHiddenPointer = &UIViewBlockSheetHiddenPointer;

@implementation UIView(Sheet)
-(UIView *) floatView{
    return objc_getAssociatedObject(self, UIViewSheetFloatViewPointer);
}
-(void) setFloatView:(UIView *) floatView{
    objc_setAssociatedObject(self, UIViewSheetFloatViewPointer, floatView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView *) sheetTitleView{
    return objc_getAssociatedObject(self, UIViewSheetFloatViewPointer);
}
-(void) setSheetTitleView:(UIView *)sheetTitleView{
    objc_setAssociatedObject(self, UIViewSheetFloatViewPointer, sheetTitleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *) sheetTitle{
    return objc_getAssociatedObject(self, UIViewSheetTitleViewPointer);
}
-(void) setSheetTitle:(NSString *)sheetTitle{
    objc_setAssociatedObject(self, UIViewSheetTitleViewPointer, sheetTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void (^) (UIView * _Nullable view)) blockSheetShow{
    return objc_getAssociatedObject(self, UIViewBlockSheetShowPointer);
}
-(void) setBlockSheetShow:(void (^)(UIView * _Nullable view))blockSheetShow{
    objc_setAssociatedObject(self, UIViewSheetTitleViewPointer, blockSheetShow, OBJC_ASSOCIATION_COPY);
}
-(void (^) (UIView * _Nullable view)) blockSheetHidden{
    return objc_getAssociatedObject(self, UIViewBlockSheetHiddenPointer);
}
-(void) setBlockSheetHidden:(void (^)(UIView * _Nullable view))blockSheetHidden{
    objc_setAssociatedObject(self, UIViewBlockSheetHiddenPointer, blockSheetHidden, OBJC_ASSOCIATION_COPY);
}
-(void) sheetShow:(UIView *)superView{
    if ([self floatView]) {
        return;
    }
    superView = superView ? superView : [UIApplication sharedApplication].delegate.window;
    UIView * floatView = [UIView new];
    floatView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    floatView.frame = superView.bounds;
    [superView addSubview:floatView];
    
    [self setFloatView:floatView];
    [floatView addSubview:self];
    
    CGRect r = self.bounds;
    r.origin.y = floatView.bounds.size.height;
    self.frame = r;
    __unsafe_unretained typeof(self) uuself = self;
    [UIView animateWithDuration:.2 animations:^{
        CGRect r = uuself.bounds;
        r.origin.y = [uuself floatView].bounds.size.height - r.size.height;
        uuself.frame = r;
    }];
}
-(void) sheetHidden{
    __unsafe_unretained typeof(self) uuself = self;
    [UIView animateWithDuration:.2 animations:^{
        CGRect r = uuself.bounds;
        r.origin.y = [uuself floatView].bounds.size.height;
        uuself.frame = r;
    } completion:^(BOOL finished) {
        [[uuself floatView] removeFromSuperview];
        [uuself removeFromSuperview];
        [self setFloatView:nil];
    }];
}

+(UIView *) createTitle:(NSString *) title blockShow:(void (^)(UIView * _Nullable view)) blockShow blockHidden:(void (^)(UIView * _Nullable view)) blockHidden{
    return nil;
}

@end
