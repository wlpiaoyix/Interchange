//
//  ViewController.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/23.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "PYDailogTools.h"
#import "PYPopupTools.h"
#import "PYToastTools.h"
#import "PYSheetTools.h"
#import <Utile/Utile.Framework.h>

@interface UIViewTest : UIView

@end
@implementation UIViewTest

-(void) layoutSubviews{
    [super layoutSubviews];
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void) viewDidAppear:(BOOL)animated{

}
- (IBAction)onClickDialog:(id)sender {
    void (^block) (void) = ^(void){
        UIView *view = [UIView new];
        [PYDailogTools setTitle:@"title" targetView:view];
        [PYDailogTools setMessage:@"message...message...message... -- \n -- message...message...message...message..." blockStyle:nil targetView:view];
        [PYDailogTools showWithTargetView:view block:^(UIView * _Nonnull view, NSUInteger index) {
            [PYPopupTools hiddenWithTargetView:view];
        } buttonNames:@[@"button1",@"button2"]];
    };
    block();
}
- (IBAction)onClickToast:(id)sender {
    [PYToastTools toastWithMessage:@"adsfasdfasdfasdf \n 我 \n 拉开刘德华里卡多好绿卡等级哈利的房间阿拉克 绿卡等级 拉开 阿里客服哈可怜的离开骄傲的法律框架啊绿卡了空间啊六角恐龙看见了看见了就离开"];
}
- (IBAction)onClickSheet:(id)sender {
    UIView *view = [[UIViewTest alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.backgroundColor = [UIColor greenColor];
    [PYSheetTools showWithTargetView:view];
    __block __weak typeof(view) __b_view = view;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block __weak typeof(__b_view) __ttv_ = __b_view;
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (__ttv_) {
                [PYPopupTools hiddenWithTargetView:__ttv_];
            }
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
