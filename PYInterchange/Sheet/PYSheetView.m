//
//  PYSheetView.m
//  PYInterchange
//
//  Created by wlpiaoyi on 16/5/17.
//  Copyright © 2016年 wlpiaoyi. All rights reserved.
//

#import "PYSheetView.h"
#import <Utile/PYUtile.h>
#import <Utile/UIView+Expand.h>

static NSString * PYSheetViewCellIdentify = @"PYSheetViewCellIdentify";
static CGFloat PYSheetViewCellTValue = .3;

@interface PYSheetViewCell : UITableViewCell
@property (nonatomic, strong, nullable) UIView * viewShow;
@property (nonatomic) CGSize sizePre;
@end
@implementation PYSheetViewCell

-(void) setViewShow:(UIView *)viewShow{
    @synchronized (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        CGRect r = viewShow.bounds;
        r.size = self.frame.size;
        viewShow.frame = r;
        if (self.viewShow) {
            [self.viewShow removeFromSuperview];
        }
        [self.contentView addSubview:viewShow];
        _viewShow = viewShow;
    }
}
-(void) layoutSubviews{
    [super layoutSubviews];
    if (((NSInteger)self.frame.size.width) == ((NSInteger)self.sizePre.width) && ((NSInteger)self.frame.size.height) == ((NSInteger)self.sizePre.height)) {
        return;
    }
    self.sizePre = self.frame.size;
    @synchronized (self) {
        if (self.viewShow) {
            self.viewShow = self.viewShow;
        }
    }
}

@end

@interface PYSheetFloatView : UIView
@property (nonatomic, strong, nullable)  UIColor * colorLine;
@end
@implementation PYSheetFloatView{
@private
    UIView * viewLine01;
    UIView * viewLine02;
    CGSize sizePre;
}

-(instancetype) init{
    if (self = [super init]) {
        [self initParams];
    }
    return self;
}
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder: aDecoder]) {
        [self initParams];
    }
    return self;
}

-(void) initParams{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    viewLine01 = [UIView new];
    viewLine01.backgroundColor = [UIColor grayColor];
    viewLine02 = [UIView new];
    viewLine02.backgroundColor = [UIColor grayColor];
    sizePre = CGSizeMake(-1, -1);
    [self addSubview:viewLine01];
    [self addSubview:viewLine02];
}

-(void) layoutSubviews{
    [super layoutSubviews];
    if (((NSInteger)self.frame.size.width) == ((NSInteger)sizePre.width) && ((NSInteger)self.frame.size.height) == ((NSInteger)sizePre.height)) {
        return;
    }
    sizePre = self.frame.size;
    CGRect r = CGRectMake(0, 0, self.frame.size.width, .5);
    viewLine01.frame = r;
    r.origin.y = self.frame.size.height - r.size.height;
    viewLine02.frame = r;
}

@end

@interface PYSheetView()<UITableViewDelegate,UITableViewDataSource>{
@private
    UIView * viewLine01;
    UIView * viewLine02;
}
@property (nonatomic, strong, nonnull) UITableView * tableView;
@property (nonatomic, strong, nullable) NSHashTable <PYSheetViewCell*>* viewCurs;
@property (nonatomic, weak, nullable) PYSheetViewCell * viewCur;
@property (nonatomic) CGRect  rectfloat;
@property (nonatomic) CGSize sizePre;
@property (nonatomic) CGFloat selectIndexPre;

@property (nonatomic) BOOL flagHasReload;
@property (nonatomic) CGFloat yTouchOffset;
@end

@implementation PYSheetView
-(instancetype) init{
    if (self = [super init]) {
        [self initParams];
    }
    return self;
}
-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder: aDecoder]) {
        [self initParams];
    }
    return self;
}

-(void) initParams{
    self.viewCurs = [NSHashTable weakObjectsHashTable];
    self.backgroundColor = [UIColor clearColor];
    self.tableView = [UITableView new];
    self.tableView.allowsSelection = true;
    self.tableView.showsVerticalScrollIndicator = false;
    self.tableView.allowsMultipleSelection = false;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.decelerationRate = .4;
    self.tableView.backgroundColor = [UIColor whiteColor];
    CGRect r = self.bounds;
    self.tableView.frame = r;
    [self addSubview:self.tableView];
    
    
    viewLine01 = [UIView new];
    viewLine01.backgroundColor = [UIColor grayColor];
    viewLine02 = [UIView new];
    viewLine02.backgroundColor = [UIColor grayColor];
    [self addSubview:viewLine01];
    [self addSubview:viewLine02];
    
    self.sizePre = CGSizeMake(-1, -1);

    self.selectIndexPre = 0;
}

- (void)selectRowAtIndexRow:(NSInteger ) indexRow animated:(BOOL)animated{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition: IOS9_OR_LATER ? UITableViewScrollPositionMiddle : UITableViewScrollPositionBottom];
    self.selectIndexPre = indexPath.row;
}

#pragma UIScrollViewDelegate ==>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.yTouchOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;{
    NSInteger centerY = scrollView.contentOffset.y + self.rectfloat.origin.y - scrollView.contentInset.top;
    NSInteger  targetH = self.rectfloat.size.height;
    [self.viewCurs removeAllObjects];
    
    for (PYSheetViewCell * cell in [self.tableView visibleCells]) {
        NSInteger cellY = cell.frame.origin.y - scrollView.contentInset.top;
        NSInteger offsetH = MIN(labs(cellY - centerY), targetH);
        CGFloat value = 0;
        if(offsetH < targetH){
            value = ((CGFloat)(targetH - offsetH)) / ((CGFloat) targetH) ;
            cell.alpha = value  * .5 + .5;
            value *= PYSheetViewCellTValue;
            [self.viewCurs addObject:cell];
        }else{
            cell.alpha =  .5;
        }
        CATransform3D transformx = CATransform3DIdentity;
        transformx = CATransform3DScale(transformx,  1 + value, 1 +value, 1);
        cell.viewShow.layer.transform = transformx;
    }
    if (!self.viewCur || (self.viewCurs && ![self.viewCurs containsObject:self.viewCur])) {
        for (PYSheetViewCell * view in self.viewCurs) {
            self.viewCur = view;
            break;
        }
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    const NSInteger centerY = scrollView.contentOffset.y + self.rectfloat.origin.y - scrollView.contentInset.top;
    NSInteger offsetY = NSIntegerMax;
    
    UITableViewCell * cellCenter = nil;
    for (UITableViewCell * cell in [self.tableView visibleCells]) {
        NSInteger cellY = cell.frame.origin.y - scrollView.contentInset.top;
        NSInteger __offsetY = cellY - centerY;
        if (labs(__offsetY) < labs(offsetY)) {
            offsetY = __offsetY;
            cellCenter = cell;
        }
    }
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cellCenter];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + offsetY) animated:YES];
}
#pragma UIScrollViewDelegate <==

#pragma UITableViewDelegate ==>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.delegate sheetView:self heightOfRowIndex:indexPath.row];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectRowAtIndexRow:indexPath.row animated:YES];
   
    if(self.delegate && [self.delegate respondsToSelector:@selector(sheetView:didSelectRowAtRowIndex:)]){
        [self.delegate sheetView:self didSelectRowAtRowIndex:indexPath.row];
    }
    
    UITableViewCell * cellCenter = [tableView cellForRowAtIndexPath:indexPath];
    [cellCenter.superview bringSubviewToFront:cellCenter];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
}
#pragma UITableViewDelegate <==

#pragma UITableViewDataSource ==>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.delegate numberOfRowInSheetView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PYSheetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PYSheetViewCellIdentify];
    [cell.contentView setCornerRadiusAndBorder:5 borderWidth:5 borderColor:[UIColor redColor]];
    if (!cell) {
        cell = [[PYSheetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PYSheetViewCellIdentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (!cell.viewShow) {
        cell.viewShow = [self.delegate cellOfsheetView:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sheetView:cell:cellOfRowIndex:)]) {
        [self.delegate sheetView:self cell:cell.viewShow cellOfRowIndex:indexPath.row];
    }
    return cell;
}
#pragma UITableViewDataSource <==

-(void) setViewCur:(PYSheetViewCell *)viewCur{
    _viewCur = viewCur;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sheetView:didDidChangeCell:)]) {
        [self.delegate sheetView:self didDidChangeCell:self.viewCur.viewShow];
    }
}
-(void) reloadData{
    [self.tableView reloadData];
    [self scrollViewDidScroll:self.tableView];
    [self synFloatView:[self.delegate sheetView:self heightOfRowIndex:self.selectIndexPre]];
    if ([self tableView:self.tableView numberOfRowsInSection:0] && !self.flagHasReload) {
        self.flagHasReload = true;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self selectRowAtIndexRow:0 animated:false];
    }
}
-(void) synFloatView:(CGFloat) height{
    CGRect r = self.bounds;
    r.origin.y = r.size.height/2 - height/2;
    r.size.height = height;
    self.rectfloat = r;
    self.tableView.contentInset = UIEdgeInsetsMake(r.origin.y, 0, r.origin.y, 0);
    
    r.size.height = .5;
    r.origin.y -= self.rectfloat.size.height * PYSheetViewCellTValue / 2;
    viewLine01.frame = r;
    r.origin.y += self.rectfloat.size.height * (1+ PYSheetViewCellTValue);
    viewLine02.frame = r;

}
-(void) layoutSubviews{
    [super layoutSubviews];
    if (((NSInteger)self.frame.size.width) == ((NSInteger)self.sizePre.width) && ((NSInteger)self.frame.size.height) == ((NSInteger)self.sizePre.height)) {
        return;
    }
    self.sizePre = self.frame.size;
    CGRect r = self.tableView.bounds;
    r.size = self.frame.size;
    self.tableView.frame = r;
    [self reloadData];
}
@end
