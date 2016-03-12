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
#import "GlLoadingView.h"
#import "UIView+Popup.h"
#import <Utile/UIView+Expand.h>

UIView *progressView;

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)onClickLoad:(id)sender {
    progressView = [GlLoadingView new];
    [progressView setCornerRadiusAndBorder:1 borderWidth:1 borderColor:[UIColor redColor]];
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView popupShow];
        });
        
        [NSThread sleepForTimeInterval:3.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView popupHidden];
        });
    });
}
- (IBAction)onclickNextView:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
