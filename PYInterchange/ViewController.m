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
#import "UIView+Popup.h"
#import "UIView+Dialog.h"
#import <Utile/UIView+Expand.h>


@interface ViewController ()
@property (nonatomic, assign) UIView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)onClickLoad:(id)sender {
    UIView * progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    [progressView setCornerRadiusAndBorder:1 borderWidth:1 borderColor:[UIColor redColor]];
    [progressView popupShow];
    progressView.dialogTitle = @"你猜";
    progressView.dialogMessage = @"我去，打开一个应用";
    [progressView dialogShowWithBlock:^(UIView * _Nonnull view, NSUInteger index) {
        [view dialogHidden];
        NSString *sUrl = [NSString stringWithFormat:@"sme://login"];///A0VbYC7Si7yvfYnJuTpHl5+r2RW9aPXsIP+eDbVI1h4iM2IgX91o4K7/4HuA+pzWB73D1e1b9bYOxsLkHT3NKuDfzQvVT9wk8tNOuwU+SEo=
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
    } buttonNames:@[@"确定"]];
    
}
- (IBAction)onclickNextView:(id)sender {
    PYProgressView * pv = [PYProgressView new];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    view.frameSize = CGSizeMake(150, 50);
//    pv.viewProgress = view;
    pv.textProgress = [[NSAttributedString alloc] initWithString:@"请稍后请稍后请稍后请稍后请..."];
    [pv progressShow];
    [pv setBlockCancel:^(PYProgressView * _Nonnull pv) {
        [pv progressHidden];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
