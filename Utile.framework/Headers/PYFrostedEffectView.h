//
//  PYFrostedEffectView.h
//  UtileScourceCode
//
//  Created by wlpiaoyi on 15/12/24.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYFrostedEffectView : UIView
@property (nonatomic) CGFloat effectValue;
@property (nonnull, nonatomic,copy) UIColor * effectColor;
-(void) refreshForstedEffect;

@end
