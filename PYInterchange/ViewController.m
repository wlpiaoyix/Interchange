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
    self.progressView = progressView;
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [NSThread sleepForTimeInterval:3.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *view = [UIView new];
            view.frame = CGRectMake(0, 0, 320, 580);
            view.backgroundColor = [UIColor blueColor];
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        });
        [NSThread sleepForTimeInterval:4.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView popupHidden];
        });
    });
    
}
- (IBAction)onclickNextView:(id)sender {
    PYProgressView * pv = [PYProgressView new];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    view.frameSize = CGSizeMake(150, 50);
//    pv.viewProgress = view;
    pv.textProgress = [[NSAttributedString alloc] initWithString:@"请稍后请稍后请稍后请稍后请..."];
    [pv popupShow];
    [pv setBlockCancel:^(PYProgressView * _Nonnull pv) {
        [pv popupHidden];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
