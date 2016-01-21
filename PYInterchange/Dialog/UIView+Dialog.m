//
//  UIView+Dialog.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/21.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "UIView+Dialog.h"
#import "UIView+Popup.h"
#import "UIView+Remove.h"
#import <Utile/Utile.Framework.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>


UIColor * _Nullable STATIC_TITLEVIEW_BACKGROUNDCLOLOR = nil;
UIColor * _Nullable STATIC_TITLEVIEW_BORDERCLOLOR = nil;
CGFloat DailogFrameWith = 280;

static const void *BlockButtonStylePointer = &BlockButtonStylePointer;
static const void *BlockTitleStylePointer = &BlockTitleStylePointer;
static const void *BlockButtonCreatePointer = &BlockButtonCreatePointer;
static const void *BlockDialogOptPointer = &BlockDialogOptPointer;
static const void *UIViewButtonViewPointer = &UIViewButtonViewPointer;
static const void *UIViewTitlePointer = &UIViewTitlePointer;
static const void *UIViewTitleFontPointer = &UIViewTitleFontPointer;
static const void *UIViewMessageViewPointer = &UIViewMessageViewPointer;
static const void *UIViewTitleViewPointer = &UIViewTitleViewPointer;
static const void *UIViewMessagePointer = &UIViewMessagePointer;

@implementation UIView(Dialog)

-(void) setDailogTitle:(nullable NSString *) title{
    objc_setAssociatedObject(self, UIViewTitlePointer, title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(nullable NSString *) dailogTitle{
    return objc_getAssociatedObject(self, UIViewTitlePointer);
}

-(void) setDailogTitleFont:(nullable UIFont *) font{
    objc_setAssociatedObject(self, UIViewTitleFontPointer, font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(nullable UIFont *) dailogTitleFont{
    return objc_getAssociatedObject(self, UIViewTitleFontPointer);
}
-(void) setBlockDialogOpt:(BlockDialogOpt) block{
    objc_setAssociatedObject(self, BlockDialogOptPointer, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BlockDialogOpt) blockDialogOpt{
    return objc_getAssociatedObject(self, BlockDialogOptPointer);
}
-(void) setBlockButtonCreate:(UIButton* (^)(NSUInteger index)) blockButtonCreate{
    objc_setAssociatedObject(self, BlockButtonCreatePointer, blockButtonCreate, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(UIButton* (^) (NSUInteger index)) blockButtonCreate{
    UIButton* (^blockButtonCreate) (NSUInteger index) = objc_getAssociatedObject(self, BlockButtonCreatePointer);
    return blockButtonCreate;
}

-(void) setDialogMessage:(NSString*) message blockStyle:(void (^) (NSMutableAttributedString* attArg)) blockStyle{
    if (![self messageLable]) {
        UILabel *lable = [UILabel new];
        lable.font = [UIFont systemFontOfSize:16];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.numberOfLines = 0;
        lable.textColor = [UIColor grayColor];
        [self setMessageLable:lable];
    }
    NSArray *array = [NSArray arrayWithArray:self.subviews];
    for (UIView *subView in array) {
        [subView removeFromSuperview];
    }
    CGRect r = self.frame;
    r.size.width = DailogFrameWith;
    self.frame = r;
    
    r = CGRectMake(5, 0, DailogFrameWith -10, 44);
    [self messageLable].frame = r;
    NSMutableAttributedString *attMsg = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange range = NSMakeRange(0, attMsg.length);
    [attMsg removeAttribute:(NSString*)kCTForegroundColorAttributeName range:range];
    [attMsg removeAttribute:(NSString*)kCTFontAttributeName range:range];
    [attMsg addAttribute:(NSString*)kCTForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, attMsg.length)];//颜色
    [attMsg addAttribute:(NSString*)kCTFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attMsg.length)];
    if (blockStyle) {
        blockStyle(attMsg);
    }
    [self messageLable].attributedText = attMsg;
    [self addSubview:[self messageLable]];
    
    r = [self messageLable].frame;
    r.size = [PYUtile getBoundSizeWithTxt:message font:[self messageLable].font size:CGSizeMake([self messageLable].frame.size.width, 999)];
    r.size.height += 30;
    r.size.width = [self messageLable].frame.size.width;
    [self messageLable].frame = r;
    
    r = self.frame;
    r.size.height = [self messageLable].frame.size.height;
    self.frame = r;
    
}
-(void) showWithBlock:(BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if(!STATIC_TITLEVIEW_BACKGROUNDCLOLOR){
            STATIC_TITLEVIEW_BACKGROUNDCLOLOR = [UIColor colorWithRed:0.086 green:0.345 blue:0.773 alpha:1];
        }
        if (!STATIC_TITLEVIEW_BORDERCLOLOR) {
            STATIC_TITLEVIEW_BORDERCLOLOR = [UIColor whiteColor];
        }
    });
    UIView *showView = [UIView new];
    [self setBlockDialogOpt:block];
    [self setDailogTitleView:[self createTitleViewWithTitle:[self dailogTitle]]];
    [self setButtonView:[self createButtonView:buttonNames]];
    
    CGRect r;
    if([self dailogTitleView]){
        r = [self dailogTitleView].frame;
        r.origin = CGPointMake(0, 0);
        [self dailogTitleView].frame  = r;
    }
    
    r = self.frame;
    r.size.height += [self dailogTitleView] ? [self dailogTitleView].frame.size.height : 0;
    r.size.height += [self buttonView] ? [self buttonView].frame.size.height : 0;
    showView.frame = r;
    
    r = self.frame;
    r.origin.y = [self dailogTitleView] ? [self dailogTitleView].frame.size.height : 0;
    r.origin.x = 0;
    self.frame = r;
    [showView addSubview:self];
    if([self buttonView]){
        r = [self buttonView].frame;
        r.origin.x = 0;
        r.origin.y = [self dailogTitleView].frame.size.height + self.frame.size.height;
        [self buttonView].frame = r;
    }
    if([self dailogTitleView]){
        [showView addSubview:[self dailogTitleView]];
    }
    if([self buttonView]){
        [showView addSubview:[self buttonView]];
    }
    showView.moveable = true;
    self.moveable = false;
    [self setShowView:showView];
    [self popupShow];
    
    
    showView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    showView.layer.borderWidth = 0.5;
    showView.layer.cornerRadius = 0;
    showView.backgroundColor = [UIColor whiteColor];
    [showView setClipsToBounds:YES];
}
-(UIView*) createButtonView:(NSArray*) names{
    if (!names || ![names count]) {
        return nil;
    }
    CGRect r = CGRectZero;
    r.size = self.frame.size;
    r.origin = CGPointMake(0, 0);
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    view.frame = r;
    view.backgroundColor = [self dailogTitleView].backgroundColor;
    view.layer.borderColor = [self dailogTitleView].layer.borderColor;
    view.layer.borderWidth = [self dailogTitleView].layer.borderWidth;
    view.layer.cornerRadius = [self dailogTitleView].layer.cornerRadius;
    view.layer.shadowRadius = [self dailogTitleView].layer.shadowRadius;
    view.layer.shadowOpacity = [self dailogTitleView].layer.shadowOpacity;
    view.layer.shadowColor = [view.backgroundColor CGColor];
    view.layer.shadowOffset = [self dailogTitleView].layer.shadowOffset;
    view.clipsToBounds = NO;
    
    if ([names count] == 0) {
        return nil;
    }
    r.size.height = 44;
    
    NSUInteger indexName = 0;
    
    if([names count] == 2){
        r.size.width /= 2;
    }
    for (NSString *name in names) {
        UIButton *button = nil;
        
        UIButton* (^blockButtonCreate) (NSUInteger index) = [self blockButtonCreate];
        if (blockButtonCreate) {
            button = blockButtonCreate(indexName);
        }
        if (!button) {
            button = [self createButtonWithName:name backgroundColor:view.backgroundColor];
        }
        button.tag = indexName;
        
        [button addTarget:self action:@selector(onclick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = indexName;
        
        
        button.backgroundColor = [self dailogTitleView].backgroundColor;
        button.layer.borderColor = view.layer.borderColor;
        button.layer.borderWidth = view.layer.borderWidth;
        button.layer.cornerRadius = 0;
        button.clipsToBounds = YES;
        void (^blockButtonStyle)(UIButton *button, NSUInteger index)  =  [self blockButtonStyle];
        if (blockButtonStyle) {
            blockButtonStyle(button,indexName);
        }
        
        CGRect _r_ = r;
        _r_.size.height += button.layer.borderWidth;
        if([names count] == 2){
            r.origin.x += r.size.width;
            if (indexName == 1) {
                r.origin.y = r.size.height;
            }else{
                _r_.size.width += button.layer.borderWidth * 2;
            }
        }else{
            r.origin.y += r.size.height;
        }
        button.frame = _r_;
        [view addSubview:button];
        
        indexName++;
    }
    
    
    CGRect _r = view.frame;
    _r.size.height = r.origin.y;
    view.frame = _r;
    
    return view;
}

-(void) onclick:(UIButton*) sender{
    BlockDialogOpt block = [self blockDialogOpt];
    if (block) {
        block(self,sender.tag);
    }
}

-(UIButton*) createButtonWithName:(NSString*) name backgroundColor:(UIColor*) backgroundColor{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithCGColor:[self dailogTitleView].layer.borderColor] forState:UIControlStateNormal];
    [button setTitleColor:backgroundColor forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[[self class] imageWithColor:backgroundColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[[self class] imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    return button;
}
-(UIView*) createTitleViewWithTitle:(NSString*) title{
    UIView *view = [UIView new];
    view.backgroundColor = STATIC_TITLEVIEW_BACKGROUNDCLOLOR;
    view.layer.borderColor = [STATIC_TITLEVIEW_BORDERCLOLOR CGColor];
    view.layer.borderWidth = 2;
    view.layer.cornerRadius = 1;
    view.layer.shadowRadius = 2;
    view.layer.shadowOpacity = 1;
    view.layer.shadowColor = [view.backgroundColor CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.clipsToBounds = NO;
    void (^blockTitleStyle)(UIView *titelView) =  [self blockTitleStyle];
    if(blockTitleStyle){
        blockTitleStyle(view);
    }
    
    
    UILabel *lable = [UILabel new];
    lable.text = title ? title : @"";
    lable.numberOfLines = 1;
    if (![self dailogTitleFont]) {
        [self setDailogTitleFont:[UIFont systemFontOfSize:20]];
    }
    lable.font = [self dailogTitleFont];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor colorWithCGColor:view.layer.borderColor];
    lable.backgroundColor = [UIColor clearColor];
    [view addSubview:lable];
    CGRect r =  view.frame;
    r.origin = CGPointMake(0, 0);
    r.size = self.frame.size;
    r.size.height = (title && title.length) ? 44 : 0;
    view.frame = r;
    lable.frame = r;
    return view;
}

-(UIView*) dailogTitleView{
    return objc_getAssociatedObject(self, UIViewTitleViewPointer);
}
-(void) setDailogTitleView:(UIView*) view{
    objc_setAssociatedObject(self, UIViewTitleViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView*) buttonView{
    return objc_getAssociatedObject(self, UIViewButtonViewPointer);
}
-(void) setButtonView:(UIView*) view{
    objc_setAssociatedObject(self, UIViewButtonViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UILabel*) messageLable{
    return objc_getAssociatedObject(self, UIViewMessageViewPointer);
}
-(void) setMessageLable:(UILabel*) view{
    objc_setAssociatedObject(self, UIViewMessageViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void) setBlockButtonStyle:(void (^)(UIButton *button, NSUInteger index)) blockButtonStyle{
    objc_setAssociatedObject(self, BlockButtonStylePointer, blockButtonStyle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIButton *button, NSUInteger index)) blockButtonStyle{
    void (^blockButtonStyle)(UIButton *button, NSUInteger index) = objc_getAssociatedObject(self, BlockButtonStylePointer);
    return blockButtonStyle;
}
-(void) setBlockTitleStyle:(void (^)(UIView *titleView)) blockTitleStyle{
    objc_setAssociatedObject(self, BlockTitleStylePointer, blockTitleStyle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIView *titleView)) blockTitleStyle{
    void (^blockTitleStyle)(UIView *titelView) = objc_getAssociatedObject(self, BlockTitleStylePointer);
    return blockTitleStyle;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

