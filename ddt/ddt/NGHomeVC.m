//
//  NGHomeVC.m
//  ddt
//
//  Created by gener on 15/7/26.
//  Copyright (c) 2015年 Light. All rights reserved.
//

#import "NGHomeVC.h"
#import "NGCollectionViewCell.h"

#define ScrollViewHeight    100
#define CollectionHeaderViewHight 140

static NSString *NGCollectionHeaderReuseID = @"NGCollectionHeaderReuseID";

@interface NGHomeVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation NGHomeVC
{
    UIButton *leftBtn ;
    UIPageControl *_pageCtr;
    UIScrollView *_topScrollView;
    UICollectionView *_collectionView;
    NSTimer *_timer;
    
    NSArray *_itemArray;//item元素项
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path= [[NSBundle mainBundle]pathForResource:@"menuItem" ofType:@"plist"];
    _itemArray = [[NSArray alloc]initWithContentsOfFile:path];
    [self initCollectionView];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    //获取位置信息
    [SVProgressHUD showWithStatus:@"正在获取位置"];
    [[LocationManger shareManger]getLocationWithSuccessBlock:^(NSString *str) {
        [SVProgressHUD dismiss];
        NSLog(@"current location : %@",str);
        [leftBtn setTitle:str forState:UIControlStateNormal];
    } andFailBlock:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"获取位置信息失败"];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_timer setFireDate:[NSDate distantPast]];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer setFireDate:[NSDate distantFuture]];
}
-(void)awakeFromNib
{
    [self initTopView];
}

#pragma mark-init subview
-(void)initTopView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 60, 40);
    [leftBtn setImage:[UIImage imageNamed:@"bar_down_icon"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"未知" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftBtn setTitleEdgeInsets:UIEdgeInsetsMake(3, -20, 3, -5)];
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, -10, 5, 52)];
    [leftBtn addTarget:self action:@selector(locationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 40);
    [rightBtn setImage:[UIImage imageNamed:@"bar_qiandao_icon"] forState:UIControlStateNormal];
    [rightBtn setTitle:@"签到" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -10)];
    [rightBtn addTarget:self action:@selector(siginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    //搜索栏初始化
    
    //topScrollView
    _pageCtr = [[UIPageControl alloc]initWithFrame:CGRectMake((CurrentScreenWidth - 100)/2.0, ScrollViewHeight - 20, 100, 20)];
    _pageCtr.numberOfPages  = 4;
    _pageCtr.currentPageIndicatorTintColor =[UIColor colorWithRed:0.345 green:0.678 blue:0.910 alpha:1];
    _pageCtr.pageIndicatorTintColor = [UIColor lightGrayColor];
    _topScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, ScrollViewHeight)];
    _topScrollView.backgroundColor = [UIColor lightGrayColor];
    _topScrollView.contentSize = CGSizeMake(CurrentScreenWidth * 4, ScrollViewHeight);
    _topScrollView.contentInset = UIEdgeInsetsZero;
    //[self.view addSubview:_topScrollView];
    _topScrollView.delegate  =self;
    _topScrollView.pagingEnabled = YES;
    _topScrollView.showsHorizontalScrollIndicator = NO;
    
    //...test
    for (int i=0; i < 4; i++) {
        UIImageView *imgv = [[UIImageView alloc]init];
        imgv.frame = CGRectMake(CurrentScreenWidth * i, 0, CurrentScreenWidth, ScrollViewHeight);
        imgv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d.png",i]];
        [_topScrollView addSubview:imgv];
    }
    [_topScrollView addSubview:_pageCtr];
}

-(void)initCollectionView
{
    float _w = (CurrentScreenWidth -20 -3) / 4.0;
    UICollectionViewFlowLayout *_layout = [[UICollectionViewFlowLayout alloc]init];
    _layout.itemSize =CGSizeMake(_w, 80);
    _layout.minimumLineSpacing = 10;
    _layout.minimumInteritemSpacing = 1;
    _layout.sectionInset = UIEdgeInsetsMake(5, 10, 10, 10);
    _layout.headerReferenceSize = CGSizeMake(0, CollectionHeaderViewHight);//_topScrollView.frame.origin.y+ScrollViewHeight
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, CurrentScreenWidth, CurrentScreenHeight -64-44) collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    _collectionView.delegate = self;
    _collectionView.dataSource  = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"NGCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"NGCollectionViewCellID"];
    [_collectionView registerNib:[UINib nibWithNibName:@"NGCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NGCollectionHeaderReuseID];
}

#pragma mark -timer action
-(void)timerAction
{
    CGPoint currentPoint = _topScrollView.contentOffset;
    currentPoint.x += CurrentScreenWidth;
    if (currentPoint.x > 3 * CurrentScreenWidth) {
        currentPoint = CGPointZero;
        _topScrollView.contentOffset = CGPointMake(0, 0);
    }
    
    [UIView animateWithDuration:.2 animations:^{
        _topScrollView.contentOffset = currentPoint;
    } completion:^(BOOL finished) {
        _pageCtr.currentPage = currentPoint.x / CurrentScreenWidth;
        _pageCtr.frame = CGRectMake(currentPoint.x + (CurrentScreenWidth - 100)/2.0, ScrollViewHeight - 20, 100, 20);
    }];
}

#pragma mark -btn Action
-(void)locationBtnAction :(UIButton*)btn
{
    
}

-(void)siginBtnAction :(UIButton*)btn
{
    
}


#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _topScrollView) {
        NSInteger index = scrollView.contentOffset.x / CurrentScreenWidth;
        if (index != _pageCtr.currentPage) {
            _pageCtr.currentPage = scrollView.contentOffset.x / CurrentScreenWidth;
            _pageCtr.frame = CGRectMake(scrollView.contentOffset.x + (CurrentScreenWidth - 100)/2.0, ScrollViewHeight - 20, 100, 20);
        }
    }
}


#pragma mark -UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _itemArray?_itemArray.count:0;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_itemArray && _itemArray.count > 0) {
        NSArray *_arr = [_itemArray objectAtIndex:section];
        return _arr?_arr.count:0;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_arr = [_itemArray objectAtIndex:indexPath.section];
    NSDictionary *dic = [_arr objectAtIndex:indexPath.row];
    
    NGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NGCollectionViewCellID" forIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor lightGrayColor];
    cell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dic objectForKey:@"imagename"]]];
    cell.title.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return nil;
    }
    UICollectionReusableView *reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NGCollectionHeaderReuseID forIndexPath:indexPath];
    for (id _s in reuseView.subviews) {
        [_s removeFromSuperview];
    }
    
    UILabel *_line = [[UILabel alloc]init];
    [reuseView addSubview:_line];
    _line.backgroundColor = [UIColor lightGrayColor];
    
    if (indexPath.section ==0) {
        [reuseView addSubview:_topScrollView];
        
        UIImageView *_igv = [[UIImageView alloc]initWithFrame:CGRectMake(0,ScrollViewHeight+ (CollectionHeaderViewHight - 20 - ScrollViewHeight)/2.0, 20, 20)];
        _igv.image = [UIImage imageNamed:@"footer"];
        [reuseView addSubview:_igv];
        UILabel*_footLab = [[UILabel alloc]initWithFrame:CGRectMake(_igv.frame.origin.x + 20, ScrollViewHeight+(CollectionHeaderViewHight - 20 -ScrollViewHeight)/2.0, 200, 20)];
        _footLab.font = [UIFont systemFontOfSize:11];
        [reuseView addSubview:_footLab];
        _footLab.text = [NSString stringWithFormat:@"足迹: %@ %@ %@",@"信用卡相关",@"信用卡相关",@"信用相关"];//...
        //        _footLab.backgroundColor = [UIColor lightGrayColor];
        _footLab.textColor =[UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1];
        
        UIButton *_shareBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(CurrentScreenWidth -90,ScrollViewHeight+ 0, 90, CollectionHeaderViewHight -ScrollViewHeight);
        //        _shareBtn.backgroundColor = [UIColor redColor];
        [reuseView addSubview:_shareBtn];
        [_shareBtn setTitle:@"分享赚积分" forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"share_icon"] forState:UIControlStateNormal];
        [_shareBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 60)];
        [_shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [_shareBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _line.frame = CGRectMake(0,  CollectionHeaderViewHight - 1, CurrentScreenWidth, 1);
    }
    else if (indexPath.section ==1)
    {
        _line.frame = CGRectMake(0, 1, CurrentScreenWidth, 1);
    }
    return reuseView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d - %d",indexPath.section,indexPath.row);
}

#pragma mark --UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeZero;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return section?CGSizeMake(0, 2): CGSizeMake(0, CollectionHeaderViewHight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -shareBtn Action
-(void)shareBtnAction
{
    NSLog(@"...shareAction");
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end


