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

#import "PYProgressMessageView.h"

CGFloat PYProgressViewContainOffFrame = 12;
UIColor * PYProgressButtonImageLineColor;

@interface PYProgressView()
@property (nonatomic, strong) UIView * viewContain;
@property (nonatomic, strong) UIButton * buttonCancel;

@property (nonatomic, strong, nonnull) NSAttributedString * attributedString;
@property (nonatomic, strong, nonnull) PYProgressMessageView * messageView;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSLayoutConstraint *> * dictLayoutConstraint;


@end

@implementation PYProgressView
+(void) initialize{
    PYProgressButtonImageLineColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1];
}
-(instancetype) init{
    if (self = [super init]) {
        [self initWithParams];
    }
    return self;
}
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initWithParams];
    }
    return self;
}
-(void) initWithParams{
    self.backgroundColor = [UIColor clearColor];
     UIView * viewContain = [UIView new];
    viewContain.backgroundColor = [UIColor clearColor];
    [super addSubview:viewContain];
    [PYViewAutolayoutCenter persistConstraint:viewContain relationmargins:UIEdgeInsetsMake(PYProgressViewContainOffFrame, PYProgressViewContainOffFrame, PYProgressViewContainOffFrame, PYProgressViewContainOffFrame) relationToItems:PYEdgeInsetsItemNull()];
    self.viewContain = viewContain;
    self.frameSize = CGSizeMake(200, 200);
    
    self.viewContain.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.viewContain.layer.shadowOffset = CGSizeMake(2,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.viewContain.layer.shadowOpacity = 0.5;//阴影透明度，默认0
    self.viewContain.layer.shadowRadius = 2;//阴影半径，默认3
}
-(void) addSubview:(UIView *)view{
    if (self.viewContain) {
        [self.viewContain addSubview:view];
    }
    if (!self.dictLayoutConstraint) {
        return;
    }
    NSDictionary<NSString *, NSLayoutConstraint *> * dictLayoutConstraint = self.dictLayoutConstraint;
    self.dictLayoutConstraint = nil;
    NSLayoutConstraint * margins = dictLayoutConstraint[@"superTop"];
    if (margins) {
        [margins.secondItem removeConstraint:margins];
    }
    margins = dictLayoutConstraint[@"superBottom"];
    if (margins) {
        [margins.secondItem removeConstraint:margins];
    }
    margins = dictLayoutConstraint[@"superLeft"];
    if (margins) {
        [margins.secondItem removeConstraint:margins];
    }
    margins = dictLayoutConstraint[@"superRight"];
    if (margins) {
        [margins.secondItem removeConstraint:margins];
    }

}

-(void) progressShow{
    [self popupShow];
}
-(void) progressHidden{
    [self popupHidden];
}
-(void) setBlockCancel:(void (^)(PYProgressView * _Nonnull))blockCancel{
    _blockCancel = blockCancel;
    if (!self.buttonCancel) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [super addSubview:button];
        [PYViewAutolayoutCenter persistConstraint:button relationmargins:UIEdgeInsetsMake(0, DisableConstrainsValueMAX, DisableConstrainsValueMAX, 0) relationToItems:PYEdgeInsetsItemNull()];
        [PYViewAutolayoutCenter persistConstraint:button size:CGSizeMake(PYProgressViewContainOffFrame * 2, PYProgressViewContainOffFrame * 2)];
        UIImage * imageNormal = [UIImage imageWithSize:CGSizeMake(PYProgressViewContainOffFrame * 4, PYProgressViewContainOffFrame * 4) blockDraw:^(CGContextRef  _Nonnull context, CGRect rect) {
            UIColor * colorLine = PYProgressButtonImageLineColor;
            CGFloat widthLine = PYProgressViewContainOffFrame / 3;
            
            CGPoint pointCenter = CGPointMake(rect.size.width / 2, rect.size.height/2);
            CGFloat radius = rect.size.width / 2 - widthLine / 2;
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:pointCenter radius:radius strokeColor:colorLine.CGColor fillColor:[UIColor clearColor].CGColor strokeWidth:widthLine startDegree:0 endDegree:179];
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:pointCenter radius:radius strokeColor:colorLine.CGColor fillColor:[UIColor clearColor].CGColor strokeWidth:widthLine startDegree:178 endDegree:358];
            [PYGraphicsDraw drawCircleWithContext:context pointCenter:pointCenter radius:radius strokeColor:colorLine.CGColor fillColor:[UIColor clearColor].CGColor strokeWidth:widthLine startDegree:357 endDegree:5];
            
            CGPoint point1 = CGPointMake(rect.size.width / 2 + sin(parseDegreesToRadians(45)) * rect.size.width / 2, rect.size.height / 2 - cos(parseDegreesToRadians(45)) * rect.size.height / 2);
            CGPoint point2 = CGPointMake(rect.size.width / 2 - cos(parseDegreesToRadians(45)) * rect.size.width / 2, rect.size.height / 2 + sin(parseDegreesToRadians(45)) * rect.size.height / 2);
            [PYGraphicsDraw drawLineWithContext:context startPoint:point1 endPoint:point2 strokeColor:colorLine.CGColor strokeWidth:widthLine lengthPointer:nil length:0];
            
            CGPoint point3 = CGPointMake(point2.x, point1.y);
            CGPoint point4 = CGPointMake(point1.x, point2.y);
            [PYGraphicsDraw drawLineWithContext:context startPoint:point3 endPoint:point4 strokeColor:colorLine.CGColor strokeWidth:widthLine lengthPointer:nil length:0];
            
        }];
        [button setImage:imageNormal forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onclickCancel) forControlEvents:UIControlEventTouchUpInside];
        self.buttonCancel = button;
        self.buttonCancel.layer.shadowColor = [UIColor whiteColor].CGColor;//shadowColor阴影颜色
        self.buttonCancel.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.buttonCancel.layer.shadowOpacity = 0.5;//阴影透明度，默认0
        self.buttonCancel.layer.shadowRadius = 2;//阴影半径，默认3
    }
    self.buttonCancel.hidden = self.blockCancel == nil;

}
-(void) onclickCancel{
    if (self.blockCancel) {
        self.blockCancel(self);
        [self progressHidden];
    }
}
-(void) dealloc{
}

@end

@implementation PYProgressView(Message)
-(void) setAttributedString:(NSAttributedString *)attributedString{
    _attributedString = attributedString;
    if (self.messageView == nil) {
        PYProgressMessageView * messageView = [PYProgressMessageView new];
        [self addSubview:messageView];
        self.dictLayoutConstraint = [PYViewAutolayoutCenter persistConstraint:messageView relationmargins:UIEdgeInsetsMake(0, 0, 0, 0) relationToItems:PYEdgeInsetsItemNull()];
        self.messageView = messageView;
    }
    self.messageView.attributedString = self.attributedString;
    self.frameSize = CGSizeMake(self.messageView.frameWidth + PYProgressViewContainOffFrame * 2 , self.messageView.frameHeight + PYProgressViewContainOffFrame * 2);
}

@end

