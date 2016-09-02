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
CGFloat  STATIC_TITLEVIEW_HEIGHT = 44;
CGFloat STATIC_TITLEVIEW_BORDERWIDTH = 0;

CGFloat STATIC_BUTTON_OFFSETWIDTH = 2;
CGFloat STATIC_BUTTON_HEIGHT= 44;

CGFloat DialogFrameWith = 280;

static const void *BlockButtonStylePointer = &BlockButtonStylePointer;
static const void *BlockTitleStylePointer = &BlockTitleStylePointer;
static const void *BlockButtonCreatePointer = &BlockButtonCreatePointer;
static const void *BlockDialogOptPointer = &BlockDialogOptPointer;
static const void *UIViewButtonViewPointer = &UIViewButtonViewPointer;
static const void *UIViewDialogAttributeTitlePointer = &UIViewDialogAttributeTitlePointer;
static const void *UIViewDialogMessageViewPointer = &UIViewDialogMessageViewPointer;
static const void *UIViewDialogTitleViewPointer = &UIViewDialogTitleViewPointer;
//static const void *UIViewDialogMessagePointer = &UIViewDialogMessagePointer;
static const void *UIViewDialogUserInfoPointer = &UIViewDialogUserInfoPointer;

@implementation UIView(Dialog)
-(void) setDialogUserInfo:(id)dialogUserInfo{
    objc_setAssociatedObject(self, UIViewDialogUserInfoPointer, dialogUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id) dialogUserInfo{
    return objc_getAssociatedObject(self, UIViewDialogUserInfoPointer);
}
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
    return objc_getAssociatedObject(self, UIViewDialogAttributeTitlePointer);
}
-(void) setDialogAttributeTitle:(NSAttributedString *)dialogAttributeTitle{
    objc_setAssociatedObject(self, UIViewDialogAttributeTitlePointer, dialogAttributeTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    if ([self showView] == self) {
        UIView *showView = [UIView new];
        showView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        showView.layer.borderWidth = 0.5;
        showView.layer.cornerRadius = 0;
        showView.backgroundColor = [UIColor whiteColor];
        [showView setClipsToBounds:YES];
        [self setShowView:showView];
    }
    [self setBlockDialogOpt:block];
    
    if (!self.dialogTitleView) {
        self.dialogTitleView = [self createTitleViewWithTitle:self.dialogAttributeTitle];
    }
    if(self.dialogTitleView && self.dialogTitleView.superview != [self showView]){
        [[self showView] addSubview:self.dialogTitleView];
        [PYViewAutolayoutCenter persistConstraint:self.dialogTitleView size:CGSizeMake(DisableConstrainsValueMAX, STATIC_TITLEVIEW_HEIGHT)];
        [PYViewAutolayoutCenter persistConstraint:self.dialogTitleView relationmargins:UIEdgeInsetsMake(0, 0, DisableConstrainsValueMAX, 0) relationToItems:PYEdgeInsetsItemNull()];
    }
    
    CGFloat buttonViewHeight = 0;
    if (![self buttonView]) {
        UIView * buttonView = [self createButtonView:buttonNames heightPointer:&buttonViewHeight];
        [self setButtonView:buttonView];
        if(buttonView && buttonViewHeight > 0){
            [self setButtonView:buttonView];
            [[self showView] addSubview:[self buttonView]];
            [PYViewAutolayoutCenter persistConstraint:buttonView relationmargins:UIEdgeInsetsMake(DisableConstrainsValueMAX, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull()];
            [PYViewAutolayoutCenter persistConstraint:buttonView size:CGSizeMake(DisableConstrainsValueMAX, buttonViewHeight)];
        }
    }else{
        buttonViewHeight = [self buttonView].frameHeight;
    }
    if (self.superview != [self showView]) {
        [self removeFromSuperview];
        [[self showView] addSubview:self];
        [PYViewAutolayoutCenter persistConstraint:self relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemMake((__bridge void * _Nullable)([self dialogTitleView]), nil, (__bridge void * _Nullable)([self buttonView]), nil)];
        self.showView.frameSize = CGSizeMake(self.frameWidth,  STATIC_TITLEVIEW_HEIGHT+ self.frameHeight + buttonViewHeight);
    }
    [self popupShow];

}
-(void) dialogHidden{
    [self popupHidden];
}
-(UIView*) createButtonView:(NSArray*) names heightPointer:(CGFloat *) heightPointer{
    if (!names || ![names count]) {
        return nil;
    }
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = STATIC_TITLEVIEW_BORDERCLOLOR;
    view.layer.borderColor = STATIC_TITLEVIEW_BORDERCLOLOR.CGColor;
    view.layer.borderWidth = STATIC_TITLEVIEW_BORDERWIDTH;
    view.layer.cornerRadius = STATIC_TITLEVIEW_BORDERWIDTH;
    view.layer.shadowRadius = self.dialogTitleView.layer.shadowRadius;
    view.layer.shadowOpacity = self.dialogTitleView.layer.shadowOpacity;
    view.layer.shadowColor = STATIC_TITLEVIEW_BACKGROUNDCLOLOR.CGColor;
    view.layer.shadowOffset = self.dialogTitleView.layer.shadowOffset;
    view.clipsToBounds = NO;
    
    if (names.count <= 2 ) {
        *heightPointer = STATIC_BUTTON_HEIGHT;
    }else{
        *heightPointer = names.count * STATIC_BUTTON_HEIGHT + (names.count - 1) * STATIC_BUTTON_OFFSETWIDTH;
    }
    
    NSUInteger indexName = 0;
    NSMutableArray<UIButton *> * buttons = [NSMutableArray new];
    for (NSString * name in names) {
        UIButton *button = nil;
        UIButton* (^blockButtonCreate) (NSUInteger index) = [self blockButtonCreate];
        if (blockButtonCreate) {
            button = blockButtonCreate(indexName);
        }
        if (!button) {
            button = [self createButtonWithName:name];
        }
        button.tag = indexName;
        [button addTarget:self action:@selector(onclick:) forControlEvents:UIControlEventTouchUpInside];
        void (^blockButtonStyle)(UIButton *button, NSUInteger index)  =  [self blockButtonStyle];
        if (blockButtonStyle) {
            blockButtonStyle(button,indexName);
        }else{
            button.backgroundColor = [UIColor clearColor];
            button.clipsToBounds = YES;
        }
        [buttons addObject:button];
        indexName ++;
    }
    for (UIButton * button in buttons) {
        [view addSubview:button];
    }
    
    
    if([buttons count] == 2){
        [PYViewAutolayoutCenter persistConstraintHorizontal:buttons relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull() offset:STATIC_BUTTON_OFFSETWIDTH];
    }else if ([buttons count] == 1){
        [PYViewAutolayoutCenter persistConstraint:buttons.firstObject relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull()];
    }else{
        [PYViewAutolayoutCenter persistConstraintVertical:buttons relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull() offset:STATIC_BUTTON_OFFSETWIDTH];
    }
    
    return view;
}

-(void) onclick:(UIButton*) sender{
    BlockDialogOpt block = [self blockDialogOpt];
    if (block) {
        block(self,sender.tag);
    }
}

-(UIButton*) createButtonWithName:(NSString*) name{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:STATIC_TITLEVIEW_BORDERCLOLOR forState:UIControlStateNormal];
    [button setTitleColor:STATIC_TITLEVIEW_BACKGROUNDCLOLOR forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[[self class] imageWithColor:STATIC_TITLEVIEW_BACKGROUNDCLOLOR] forState:UIControlStateNormal];
    [button setBackgroundImage:[[self class] imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    return button;
}
-(UIView*) createTitleViewWithTitle:(NSAttributedString*) title{
    if (!title ||  !title.length) {
        return nil;
    }
    UIView *view = [UIView new];
    view.backgroundColor = STATIC_TITLEVIEW_BACKGROUNDCLOLOR;
    view.layer.borderColor = [STATIC_TITLEVIEW_BORDERCLOLOR CGColor];
    view.layer.borderWidth = STATIC_TITLEVIEW_BORDERWIDTH;
    view.layer.cornerRadius = STATIC_TITLEVIEW_BORDERWIDTH;
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
    [PYViewAutolayoutCenter persistConstraint:lable relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull()];
    return view;
}

-(UIView*) dialogTitleView{
    return objc_getAssociatedObject(self, UIViewDialogTitleViewPointer);
}
-(void) setDialogTitleView:(UIView*) view{
    objc_setAssociatedObject(self, UIViewDialogTitleViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView*) buttonView{
    return objc_getAssociatedObject(self, UIViewButtonViewPointer);
}
-(void) setButtonView:(UIView*) view{
    objc_setAssociatedObject(self, UIViewButtonViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UILabel*) messageLable{
    return objc_getAssociatedObject(self, UIViewDialogMessageViewPointer);
}
-(void) setMessageLable:(UILabel*) view{
    objc_setAssociatedObject(self, UIViewDialogMessageViewPointer, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

