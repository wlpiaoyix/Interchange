//
//  PYProgressView.h
//  DialogScourceCode
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>
extern CGFloat MAXPYProgressViewWidth;
extern CGFloat MAXPYProgressViewHeight;
extern CGFloat MINPYProgressViewWith;
extern CGFloat MINPYProgressViewHeight;
extern CGFloat MAXPYProgressMessageSpace;

@interface PYProgressView : UIView
@property (nonatomic, strong, nonnull) NSAttributedString * progressText;
@property (nonatomic) BOOL flagStop;
@end
