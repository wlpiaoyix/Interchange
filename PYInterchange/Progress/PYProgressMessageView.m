//
//  PYProgressMessageView.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/8/12.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "PYProgressMessageView.h"
#import <Utile/PYUtile.h>
#import <Utile/UIView+Expand.h>
#import <Utile/PYViewAutolayoutCenter.h>

CGFloat PYProgressMessageMAXW= 260;
CGFloat PYProgressMessageMAXH= 300;
CGFloat PYProgressMessageMINW= 150;
CGFloat PYProgressMessageOffFrame = 10;
CGFloat PYProgressMessageActivityFrame= 40;

@interface PYProgressMessageView()
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) UILabel * messageLable;

@end

@implementation PYProgressMessageView

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
    
    UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicatorView startAnimating];
    [self addSubview:activityIndicatorView];
    [PYViewAutolayoutCenter persistConstraint:activityIndicatorView size:CGSizeMake(PYProgressMessageActivityFrame, PYProgressMessageActivityFrame)];
    [PYViewAutolayoutCenter persistConstraint:activityIndicatorView centerPointer:CGPointMake(0, DisableConstrainsValueMAX)];
    [PYViewAutolayoutCenter persistConstraint:activityIndicatorView relationmargins:UIEdgeInsetsMake(PYProgressMessageOffFrame, DisableConstrainsValueMAX, DisableConstrainsValueMAX, DisableConstrainsValueMAX) relationToItems:PYEdgeInsetsItemNull()];
    self.activityIndicatorView = activityIndicatorView;
    
    UILabel * messageLable = [UILabel new];
    messageLable.numberOfLines = 0;
    messageLable.backgroundColor = [UIColor clearColor];
    messageLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:messageLable];
    [PYViewAutolayoutCenter persistConstraint:messageLable relationmargins:UIEdgeInsetsMake(PYProgressMessageOffFrame, PYProgressMessageOffFrame, PYProgressMessageOffFrame, PYProgressMessageOffFrame) relationToItems:PYEdgeInsetsItemMake((__bridge void * _Nullable)(self.activityIndicatorView), nil, nil, nil)];
    self.messageLable = messageLable;
    [self setCornerRadiusAndBorder:2 borderWidth:2 borderColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    
}
-(void) setAttributedString:(NSAttributedString *)attributedString{
    _attributedString = attributedString;
    CGSize size = CGSizeMake(999, 15);
    size = [PYUtile getBoundSizeWithAttributeTxt:self.attributedString size:size];
    if (size.width > PYProgressMessageMAXW - PYProgressMessageOffFrame * 2) {
        size.width = PYProgressMessageMAXW;
    }else if(size.width < PYProgressMessageMINW){
        size.width = PYProgressMessageMINW;
    }else{
        size.width += PYProgressMessageOffFrame * 2;
    }
    size.height = 999;
    size.height = [PYUtile getBoundSizeWithAttributeTxt:attributedString size:size].height;
    if (size.height > PYProgressMessageMAXH - PYProgressMessageActivityFrame - PYProgressMessageOffFrame * 3) {
        size.height = PYProgressMessageMAXH;
    }else{
        size.height += PYProgressMessageActivityFrame + PYProgressMessageOffFrame * 3;
    }
    self.messageLable.attributedText = attributedString;
    self.frameSize = size;
}

-(void) dealloc{
    [self.activityIndicatorView stopAnimating];
}

@end

