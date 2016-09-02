//
//  PYProgressView.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
extern CGFloat MAXPYProgressViewWidth;
extern CGFloat MINPYProgressViewWidth;
extern CGFloat MAXPYProgressViewHeight;
extern CGFloat PYProgressMessageSpace;

@interface PYProgressView : UIView
@property (nonatomic, copy, nullable) void (^blockCancel)(PYProgressView * _Nonnull target);
-(void) progressShow;
-(void) progressHidden;
@end

@interface PYProgressView(Message)
@property (nonatomic, strong, nonnull) NSAttributedString * attributedString;
@end
