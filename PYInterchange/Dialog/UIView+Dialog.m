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
#import <objc/runtime.h>


UIColor * _Nullable STATIC_TITLEVIEW_BACKGROUNDCLOLOR = nil;
UIColor * _Nullable STATIC_TITLEVIEW_BORDERCLOLOR = nil;
CGFloat DialogFrameWith = 280;

static const void *BlockButtonStylePointer = &BlockButtonStylePointer;
static const void *BlockTitleStylePointer = &BlockTitleStylePointer;
static const void *BlockButtonCreatePointer = &BlockButtonCreatePointer;
static const void *BlockDialogOptPointer = &BlockDialogOptPointer;
static const void *UIViewButtonViewPointer = &UIViewButtonViewPointer;
static const void *UIViewAttributeTitlePointer = &UIViewAttributeTitlePointer;
static const void *UIViewMessageViewPointer = &UIViewMessageViewPointer;
static const void *UIViewTitleViewPointer = &UIViewTitleViewPointer;
static const void *UIViewMessagePointer = &UIViewMessagePointer;

@implementation UIView(Dialog)

-(void) setDialogTitle:(nullable NSString *) title{
    NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = NSMakeRange(0, attTitle.length);
    [attTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];//颜色
    [attTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
    self.dialogAttributeTitle = attTitle;
}
-(nullable NSString *) dialogTitle{
    return self.dialogAttributeTitle.string;;
}
-(NSAttributedString *) dialogAttributeTitle{
    return objc_getAssociatedObject(self, UIViewAttributeTitlePointer);
}
-(void) setDialogAttributeTitle:(NSAttributedString *)dialogAttributeTitle{
    objc_setAssociatedObject(self, UIViewAttributeTitlePointer, dialogAttributeTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
-(void) setDialogMessage:(NSString *)dialogMessage{
    NSMutableAttributedString *attMsg = [[NSMutableAttributedString alloc] initWithString:dialogMessage];
    NSRange range = NSMakeRange(0, attMsg.length);
    [attMsg removeAttribute:NSForegroundColorAttributeName range:range];
    [attMsg removeAttribute:NSFontAttributeName range:range];
    [attMsg addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, attMsg.length)];//颜色
    [attMsg addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attMsg.length)];
    self.dialogAttributeMessage = attMsg;
}
-(NSString *) dialogMessage{
    return self.dialogAttributeMessage.string;
}
-(void) setDialogAttributeMessage:(NSAttributedString *)dialogAttributeMessage{
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
    r.size.width = DialogFrameWith;
    self.frame = r;
    
    r = CGRectMake(5, 0, DialogFrameWith -10, 44);
    [self messageLable].frame = r;
    [self messageLable].attributedText = dialogAttributeMessage;
    [self addSubview:[self messageLable]];
    
    r = [self messageLable].frame;
    r.size = [PYUtile getBoundSizeWithAttributeTxt:dialogAttributeMessage size:CGSizeMake([self messageLable].frame.size.width, 999)];
    r.size.height += 30;
    r.size.width = [self messageLable].frame.size.width;
    [self messageLable].frame = r;
    
    r = self.frame;
    r.size.height = [self messageLable].frame.size.height;
    self.frame = r;
}
-(NSAttributedString *) dialogAttributeMessage{
    return [self messageLable].attributedText;
}
-(void) dialogShowWithBlock:(BlockDialogOpt) block buttonNames:(nonnull NSArray<NSString*>*)buttonNames{
    
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
    [self setDialogTitleView:[self createTitleViewWithTitle:self.dialogAttributeTitle]];
    [self setButtonView:[self createButtonView:buttonNames]];
    
    CGRect r;
    if([self dialogTitleView]){
        r = [self dialogTitleView].frame;
        r.origin = CGPointMake(0, 0);
        [self dialogTitleView].frame  = r;
    }
    
    r = self.frame;
    r.size.height += [self dialogTitleView] ? [self dialogTitleView].frame.size.height : 0;
    r.size.height += [self buttonView] ? [self buttonView].frame.size.height : 0;
    showView.frame = r;
    
    r = self.frame;
    r.origin.y = [self dialogTitleView] ? [self dialogTitleView].frame.size.height : 0;
    r.origin.x = 0;
    self.frame = r;
    [showView addSubview:self];
    if([self buttonView]){
        r = [self buttonView].frame;
        r.origin.x = 0;
        r.origin.y = [self dialogTitleView].frame.size.height + self.frame.size.height;
        [self buttonView].frame = r;
    }
    if([self dialogTitleView]){
        [showView addSubview:[self dialogTitleView]];
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
-(void) dialogHidden{
    [self popupHidden];
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
    view.backgroundColor = [self dialogTitleView].backgroundColor;
    view.layer.borderColor = [self dialogTitleView].layer.borderColor;
    view.layer.borderWidth = [self dialogTitleView].layer.borderWidth;
    view.layer.cornerRadius = [self dialogTitleView].layer.cornerRadius;
    view.layer.shadowRadius = [self dialogTitleView].layer.shadowRadius;
    view.layer.shadowOpacity = [self dialogTitleView].layer.shadowOpacity;
    view.layer.shadowColor = [view.backgroundColor CGColor];
    view.layer.shadowOffset = [self dialogTitleView].layer.shadowOffset;
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
        
        void (^blockButtonStyle)(UIButton *button, NSUInteger index)  =  [self blockButtonStyle];
        if (blockButtonStyle) {
            blockButtonStyle(button,indexName);
        }else{
            button.backgroundColor = [self dialogTitleView].backgroundColor;
            button.layer.borderColor = view.layer.borderColor;
            button.layer.borderWidth = view.layer.borderWidth;
            button.layer.cornerRadius = 0;
            button.clipsToBounds = YES;
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
    [button setTitleColor:[UIColor colorWithCGColor:[self dialogTitleView].layer.borderColor] forState:UIControlStateNormal];
    [button setTitleColor:backgroundColor forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[[self class] imageWithColor:backgroundColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[[self class] imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    return button;
}
-(UIView*) createTitleViewWithTitle:(NSAttributedString*) title{
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
    lable.attributedText = title;
    lable.numberOfLines = 1;
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

-(UIView*) dialogTitleView{
    return objc_getAssociatedObject(self, UIViewTitleViewPointer);
}
-(void) setDialogTitleView:(UIView*) view{
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

