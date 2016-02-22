//
//  ViewController.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "PYProgressView.h"
#import "PYPopupTools.h"
#import "UIView+Dialog.h"
PYProgressView *progressView;

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)onClickLoad:(id)sender {
    PYProgressView *view = [PYProgressView new];
    view.progressText = [[NSAttributedString alloc] initWithString:@"请稍后..."];
    [PYPopupTools showWithTargetView:view];
    [PYPopupTools setMoveable:YES targetView:view];
    progressView = view;
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:3.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYPopupTools hiddenWithTargetView:progressView];
            progressView.flagStop = true;
        });
        
        [NSThread sleepForTimeInterval:3.0f];
        progressView.flagStop = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYPopupTools showWithTargetView:view];
        });
        [NSThread sleepForTimeInterval:1.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYPopupTools hiddenWithTargetView:progressView];
            progressView.flagStop = true;
            
            progressView.flagStop = false;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PYPopupTools showWithTargetView:view];
                });
            });
        });
        
        [NSThread sleepForTimeInterval:4.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYPopupTools hiddenWithTargetView:progressView];
            progressView.flagStop = true;
        });
    });
}
- (IBAction)onclickNextView:(id)sender {
    UIView *view = [UIView new];
    view.dialogTitle = @"动画测试";
    [view setDialogMessage:@"我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下我就测试一下" blockStyle:^(NSMutableAttributedString * _Nonnull attArg) {
        [attArg addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attArg.length/2)];//颜色
        [attArg addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, attArg.length/2)];
    }];
    [view dialogShowWithBlock:^(UIView * _Nonnull view, NSUInteger index) {
        [view dialogHidden];
        if (index) {
            return ;
        }
        [self performSegueWithIdentifier:@"view2" sender:nil];
    } buttonNames:@[@"确定",@"取消"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
