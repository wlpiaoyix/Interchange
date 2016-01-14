//
//  ViewAutolayoutCenter.h
//  Common
//
//  Created by wlpiaoyi on 15/1/5.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//


#import <UIKit/UIKit.h>

extern const CGFloat DisableConstrainsValueMAX;
extern const CGFloat DisableConstrainsValueMIN;

typedef struct PYEdgeInsetsItem {
    void  * _Nullable top, * _Nullable left, * _Nullable bottom, * _Nullable right;  // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
} PYEdgeInsetsItem;
PYEdgeInsetsItem PYEdgeInsetsItemMake(void  * _Nullable top, void  * _Nullable left, void  * _Nullable bottom, void  * _Nullable right) {
    PYEdgeInsetsItem insets = {top, left, bottom, right};
    return insets;
}
PYEdgeInsetsItem PYEdgeInsetsItemNull() {
    PYEdgeInsetsItem insets = {nil, nil, nil, nil};
    return insets;
}


@interface PYViewAutolayoutCenter : NSObject
/**
 删除相关的约束
 */
+(void) removeConstraints:(nonnull UIView*) subView;
/**
 新增关系约束
 */
+(void) persistConstraint:(nonnull UIView*) subView relationmargins:(UIEdgeInsets) margins relationToItems:(PYEdgeInsetsItem) toItems;
/**
 新增大小约束
 */
+(void) persistConstraint:(nonnull UIView*) subView size:(CGSize) size;
/*
 新增布局约束
 */
+(void) persistConstraint:(nonnull UIView*) subView centerPointer:(CGPoint) pointer;

@end
