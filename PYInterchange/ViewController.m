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

@interface ViewController ()
@property (nonatomic,weak) PYProgressView *progressView;
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
    [PYPopupTools setMoveable:NO targetView:view];
    self.progressView = view;
    //  后台执行：
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:3.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [PYPopupTools hiddenWithTargetView:self.progressView];
            self.progressView.flagStop = true;
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
