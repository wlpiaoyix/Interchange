//
//  ViewController.m
//  DialogScourceCode
//
//  Created by wlpiaoyi on 15/10/23.
//  Copyright © 2015年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "PYDailogTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void) viewDidAppear:(BOOL)animated{
    UIView *view = [UIView new];
    [PYDailogTools setTitle:@"title" targetView:view];
    [PYDailogTools setMessage:@"message...message...message... -- \n -- message...message...message...message..." blockStyle:nil targetView:view];
    [PYDailogTools showWithTargetView:view block:^(UIView * _Nonnull view, NSUInteger index) {
        [PYPopupTools hiddenWithTargetView:view];
    } buttonNames:@[@"button1",@"button2"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
