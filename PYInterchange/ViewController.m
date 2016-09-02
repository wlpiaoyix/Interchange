//
//  ViewController.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/1/18.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "PYProgressView.h"
#import "UIView+Popup.h"
#import "UIView+Dialog.h"
#import <Utile/UIView+Expand.h>
#import "PYSheetView.h"
#import "UIView+Sheet.h"


@interface ViewController ()<PYSheetViewDelegate>
@property (strong, nonatomic) IBOutlet PYSheetView *view03;
@property (strong, nonatomic)  PYSheetView *view02;
@property (nonatomic, assign) UIView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view03.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)onClickLoad:(id)sender {
    UIView * progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    [progressView popupShow];
    progressView.dialogTitle = @"你猜";
    progressView.dialogMessage = @"我去，打开一个应用";
    [progressView dialogShowWithBlock:^(UIView * _Nonnull view, NSUInteger index) {
        [view dialogHidden];
        if(index != 0) return;
        NSString *sUrl = [NSString stringWithFormat:@"sme://login"];///A0VbYC7Si7yvfYnJuTpHl5+r2RW9aPXsIP+eDbVI1h4iM2IgX91o4K7/4HuA+pzWB73D1e1b9bYOxsLkHT3NKuDfzQvVT9wk8tNOuwU+SEo=
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
    } buttonNames:@[@"确定",@"取消"]];

}
//- (IBAction)onclickNextView:(id)sender {
//    if (self.view03.superview == self.view) {
//        [self.view03 removeFromSuperview];
//    }
//    if (!self.view02) {
//        self.view02 = [PYSheetView new];
//        self.view02.frame = self.view03.bounds;
//        self.view02.delegate = self;
//    }
//    [self.view02 sheetShow:self.view];
//    [self.view02 reloadData];
//    [self.view02 selectRowAtIndexRow:2 animated:YES];
//}
- (IBAction)onclickNextView:(id)sender {
    PYProgressView * pv = [PYProgressView new];
//        pv.viewProgress = view;
    pv.attributedString = [[NSAttributedString alloc] initWithString:@"请稍后..." attributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:1 green:1 blue:1 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    [pv progressShow];
    [pv setBlockCancel:^(PYProgressView * _Nonnull pv) {
        [pv progressHidden];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSUInteger) numberOfRowInSheetView:(nonnull PYSheetView *) sheetView{
    return 20;
}
-(CGFloat)  sheetView:(nonnull PYSheetView *) sheetView heightOfRowIndex:(NSInteger) rowIndex{
    return 50;
}
-(nonnull UIView *)  cellOfsheetView:(nonnull PYSheetView *) sheetView{
    UILabel * lable = [UILabel new];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor = [UIColor greenColor];
    return lable;
}
-(void) sheetView:(nonnull PYSheetView *) sheetView cell:(nonnull UIView *) cell cellOfRowIndex:(NSInteger) rowIndex{
    ((UILabel*)cell).text = [NSString stringWithFormat:@"%d===", rowIndex];
}
-(void) sheetView:(nonnull PYSheetView *) sheetView didSelectRowAtRowIndex:(NSInteger) rowIndex{

}
-(void) sheetView:(PYSheetView *)sheetView didDidChangeCell:(UIView *)cell{
    NSString * text = ((UILabel *) cell).text;
    NSLog(text);
}

@end
