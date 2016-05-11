//
//  PYProgressView.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "PYProgressView.h"
#import <Utile/UILable+Expand.h>
#import <Utile/PYUtile.h>
#import <Utile/UIView+Expand.h>
#import <Utile/PYGraphicsDraw.h>
#import <Utile/PYGraphicsThumb.h>
#import <Utile/EXTScope.h>
#import <Utile/UIColor+Expand.h>
#import <Utile/PYViewAutolayoutCenter.h>
#import <Utile/UIImage+Expand.h>
#import <Utile/PYGraphicsDraw.h>
#import <Utile/PYUtile.h>
#import "UIView+Popup.h"

static NSTimer * PYPogressTimer;
static NSHashTable<PYProgressView *> * HashTablePYProgressView;

CGFloat MAXPYProgressViewWidth = 260;
CGFloat MAXPYProgressViewHeight = 300;
CGFloat MINPYProgressViewWith = 80;
CGFloat MINPYProgressViewHeight = 40;
CGFloat MAXPYProgressMessageSpace = 10;
CGFloat MAXPYProgressBorderWidth = 10;

UIImage * UIImagePYProgressButtonCancelNormal;
UIImage * UIImagePYProgressButtonCancelHighlight;

@interface PYProgressView()
@property (nonatomic, strong) NSLayoutConstraint * layoutContaraintDispalyHeight;
@property (nonatomic, strong) NSLayoutConstraint * layoutContaraintDispalyTop;
@property (nonatomic, strong) UIView * viewBase;
@property (nonatomic, strong) UIButton * buttonCancel;
@property (nonatomic, strong) UIView * viewContainer;
@property (nonatomic, strong) UIView * viewDisplay;
@property (nonatomic, strong) UILabel *lableMessage;
@property (nonatomic, strong) PYGraphicsThumb *gt;
@property (nonatomic) CGFloat valueGht;
@end

@implementation PYProgressView
+(void) initialize{
    
    @unsafeify(self);
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        @strongify(self);
        HashTablePYProgressView=[NSHashTable<PYProgressView *> weakObjectsHashTable];
        PYPogressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(GraphicsProgressLayer) userInfo:nil repeats:YES];
        [PYPogressTimer fire];
        CGFloat width = MAXPYProgressBorderWidth * 2;
        UIImagePYProgressButtonCancelNormal = [UIImage imageWithSize:CGSizeMake(width * 2, width * 2) blockDraw:^(CGContextRef  _Nonnull context, CGRect rect) {
            UIColor * strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            UIColor * fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
            UIColor * borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
            
            CGFloat borderW = width / 4;
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:CGPointMake(width, width) radius:width - borderW / 2 strokeColor:borderColor.CGColor fillColor:[UIColor clearColor].CGColor strokeWidth:borderW startDegree:0 endDegree:-0.001];
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:CGPointMake(width, width) radius:width - borderW / 2 strokeColor:strokeColor.CGColor fillColor:fillColor.CGColor strokeWidth:borderW / 2 startDegree:0 endDegree:-0.001];
            
            CGFloat xw = cos(parseRadiansToDegrees(45)) * (width- borderW) * 2 / 3;
            CGFloat yw = sin(parseRadiansToDegrees(45)) * (width- borderW)  * 2 / 3;
            
            
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width - xw , width - yw) endPoint:CGPointMake(width  + xw , width + yw) strokeColor:borderColor.CGColor strokeWidth:borderW * 2 lengthPointer:nil length:0];
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width + xw, width - yw) endPoint:CGPointMake(width - xw, width + yw) strokeColor:borderColor.CGColor strokeWidth:borderW * 2 lengthPointer:nil length:0];
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width - xw , width - yw) endPoint:CGPointMake(width  + xw , width + yw) strokeColor:strokeColor.CGColor strokeWidth:borderW lengthPointer:nil length:0];
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width + xw, width - yw) endPoint:CGPointMake(width - xw, width + yw) strokeColor:strokeColor.CGColor strokeWidth:borderW lengthPointer:nil length:0];
        }];
        UIImagePYProgressButtonCancelHighlight= [UIImage imageWithSize:CGSizeMake(width * 2, width * 2) blockDraw:^(CGContextRef  _Nonnull context, CGRect rect) {
            UIColor * fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            UIColor * strokeColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
            
            CGFloat borderW = width / 4;
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:CGPointMake(width, width) radius:width - borderW / 2 strokeColor:strokeColor.CGColor fillColor:fillColor.CGColor strokeWidth:borderW startDegree:0 endDegree:-0.001];
            
            CGFloat xw = cos(parseRadiansToDegrees(45)) * (width- borderW) * 2 / 3;
            CGFloat yw = sin(parseRadiansToDegrees(45)) * (width- borderW)  * 2 / 3;
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width - xw , width - yw) endPoint:CGPointMake(width  + xw , width + yw) strokeColor:strokeColor.CGColor strokeWidth:borderW lengthPointer:nil length:0];
            [PYGraphicsDraw drawLineWithContext:context startPoint:CGPointMake(width + xw, width - yw) endPoint:CGPointMake(width - xw, width + yw) strokeColor:strokeColor.CGColor strokeWidth:borderW lengthPointer:nil length:0];
        }];
    });
}
+(void) GraphicsProgressLayer{
    @synchronized (HashTablePYProgressView) {
        for (PYProgressView * pv in HashTablePYProgressView) {
            CGFloat  value = pv.valueGht;
            value += 0.1;
            if (value > 1) {
                value = 0;
            }
            pv.valueGht = value;
            [pv.gt executDisplay:nil];
        }
    }
}
-(instancetype) init{
    if (self = [super init]) {
        [self initWithParams];
    }
    return self;
}
-(void) setViewDisplayHeight:(CGFloat) height{
    if (self.layoutContaraintDispalyHeight) {
        [self.viewDisplay removeConstraint:self.layoutContaraintDispalyHeight];
    }
    if (self.layoutContaraintDispalyTop) {
        [self.viewDisplay.superview removeConstraint:self.layoutContaraintDispalyTop];
    }
    self.layoutContaraintDispalyHeight = [PYViewAutolayoutCenter persistConstraint:self.viewDisplay size:CGSizeMake(DisableConstrainsValueMAX, height)][@"selfHeight"];
    CGFloat top = MAXPYProgressMessageSpace * (self.viewProgress ? 2 : 1);
    self.layoutContaraintDispalyTop =  [PYViewAutolayoutCenter persistConstraint:self.viewDisplay relationmargins:UIEdgeInsetsMake(top, DisableConstrainsValueMAX, DisableConstrainsValueMAX, DisableConstrainsValueMAX) relationToItems:PYEdgeInsetsItemNull()][@"superTop"];
}
-(void) initWithParams{
    self.backgroundColor = [UIColor clearColor];
    
    self.viewBase = [UIView new];
    self.viewBase.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.viewBase setCornerRadiusAndBorder:5 borderWidth:1 borderColor:[UIColor whiteColor]];
    [self addSubview:self.viewBase];
    [PYViewAutolayoutCenter persistConstraint:self.viewBase relationmargins:UIEdgeInsetsMake(MAXPYProgressBorderWidth, MAXPYProgressBorderWidth, MAXPYProgressBorderWidth, MAXPYProgressBorderWidth) relationToItems:PYEdgeInsetsItemNull()];
    
    self.buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonCancel setImage:UIImagePYProgressButtonCancelNormal forState:UIControlStateNormal];
    [self.buttonCancel setImage:UIImagePYProgressButtonCancelHighlight forState:UIControlStateHighlighted];
    [self addSubview:self.buttonCancel];
    [PYViewAutolayoutCenter persistConstraint:self.buttonCancel relationmargins:UIEdgeInsetsMake(0, DisableConstrainsValueMAX, DisableConstrainsValueMAX, 0) relationToItems:PYEdgeInsetsItemNull()];
    [PYViewAutolayoutCenter persistConstraint:self.buttonCancel size:CGSizeMake(MAXPYProgressBorderWidth * 2, MAXPYProgressBorderWidth * 2)];
    [self.buttonCancel addTarget:self action:@selector(onclickCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCancel setHidden:YES];
    
    self.viewContainer = [UIView new];
    self.viewContainer.backgroundColor = [UIColor clearColor];
    [self.viewBase addSubview:self.viewContainer];
    
    [PYViewAutolayoutCenter persistConstraint:self.viewContainer relationmargins:UIEdgeInsetsMake(MAXPYProgressMessageSpace, MAXPYProgressMessageSpace, MAXPYProgressMessageSpace, MAXPYProgressMessageSpace) relationToItems:PYEdgeInsetsItemNull()];
    
    
    self.viewDisplay = [UIView new];
    self.viewDisplay.backgroundColor = [UIColor clearColor];
    [self.viewBase addSubview:self.viewDisplay];
    
    self.lableMessage = [UILabel new];
    self.lableMessage.backgroundColor = [UIColor clearColor];
    self.lableMessage.numberOfLines = 0;
    self.lableMessage.textAlignment = NSTextAlignmentCenter;
    self.lableMessage.font = [UIFont boldSystemFontOfSize:16];
    self.lableMessage.textColor = [UIColor whiteColor];
    [self.viewBase addSubview:self.lableMessage];
    
    [self setViewDisplayHeight:0];
    [PYViewAutolayoutCenter persistConstraint:self.viewDisplay relationmargins:UIEdgeInsetsMake(DisableConstrainsValueMAX, MAXPYProgressMessageSpace, DisableConstrainsValueMAX, MAXPYProgressMessageSpace) relationToItems:PYEdgeInsetsItemNull()];
    void * topPoint = (__bridge void *)(self.viewDisplay);
    [PYViewAutolayoutCenter persistConstraint:self.lableMessage relationmargins:UIEdgeInsetsMake(0, MAXPYProgressMessageSpace, MAXPYProgressMessageSpace, MAXPYProgressMessageSpace) relationToItems:PYEdgeInsetsItemMake(topPoint, nil, nil, nil)];
    
    UIActivityIndicatorView * div = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [div startAnimating];
    self.viewProgress = div;
    
    self.valueGht = 0;
    @unsafeify(self);
    self.gt = [PYGraphicsThumb graphicsThumbWithView:self.viewContainer block:^(CGContextRef ctx, id userInfo) {
        @strongify(self);
        CGFloat value = self.valueGht;
        if (userInfo && [userInfo isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)userInfo).floatValue;
        }
        if (value < 0) {
            return;
        }
        
        value = MAX(0, value);
        value = MIN(1, value);
        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(self.viewContainer.frameWidth , self.viewContainer.frameHeight);
        UIColor *color1 = self.color1 ? self.color1 : [UIColor grayColor];
        UIColor *color2 = self.color2 ? self.color2 : [UIColor clearColor];
        [PYGraphicsDraw drawLinearGradientWithContext:ctx colorValues:(CGFloat[]){
            color1.red, color1.green, color1.blue, color1.alpha,
            color2.red, color2.green, color2.blue, color2.alpha,
            color1.red, color1.green, color1.blue, color1.alpha
        } alphas:(CGFloat[]){
            0.0f,
            value,
            1.0f
        } length:3  startPoint:p1 endPoint:p2];
    }];
    @synchronized (HashTablePYProgressView) {
        [HashTablePYProgressView addObject:self];
    }
}
-(void) setTextProgress:(NSAttributedString *)progressText{
    _textProgress = progressText;
    self.lableMessage.attributedText = progressText;
    CGFloat width = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(9999, self.lableMessage.font.pointSize)].width + MAXPYProgressMessageSpace;
    if (width < self.viewProgress.frameWidth) {
        width = self.viewProgress.frameWidth;
    }
    CGFloat height = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(width, 9999)].height;
    if (width >  MAXPYProgressViewWidth) {
        width = MAXPYProgressViewWidth;
        height = [PYUtile getBoundSizeWithTxt:[progressText string] font:self.lableMessage.font size:CGSizeMake(width, 9999)].height;
    }else if(width < MINPYProgressViewWith){
        width = MINPYProgressViewWith;
    }
    
    if (height > MAXPYProgressViewHeight) {
        height = MAXPYProgressViewHeight;
    }else if(height < MINPYProgressViewHeight){
        height = MINPYProgressViewHeight;
    }
    CGSize size = CGSizeMake(width + MAXPYProgressMessageSpace * 2, height + MAXPYProgressMessageSpace * (self.viewProgress ? 3 : 2) + self.viewProgress.frameHeight);
    size.width += MAXPYProgressBorderWidth * 2;
    size.height += MAXPYProgressBorderWidth * 2;
    self.frameSize = size;
    
    self.viewProgress.frameOrigin = CGPointMake((self.frameWidth - MAXPYProgressMessageSpace * 2 - self.viewProgress.frameWidth) / 2, 0);
}
-(void) setViewProgress:(UIView *)viewProgress{
    _viewProgress = viewProgress;
    for (UIView * view in self.viewDisplay.subviews) {
        [view removeFromSuperview];
    }
    [self setViewDisplayHeight:viewProgress.frameHeight];
    [self.viewDisplay addSubview:self.viewProgress];
    
    self.textProgress = self.textProgress;
}

-(void) progressShow{
    [self popupShow];
}
-(void) progressHidden{
    [self popupHidden];
}
-(void) setBlockCancel:(void (^)(PYProgressView * _Nonnull))blockCancel{
    _blockCancel = blockCancel;
    self.buttonCancel.hidden = self.blockCancel ? NO : YES;
}
-(void) onclickCancel{
    if (self.blockCancel) {
        self.blockCancel(self);
        [self progressHidden];
    }
}
-(void) dealloc{
    @synchronized (HashTablePYProgressView) {
        [HashTablePYProgressView removeObject:self];
    }
}

@end
