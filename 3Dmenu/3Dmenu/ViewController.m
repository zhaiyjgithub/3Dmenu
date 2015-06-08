//
//  ViewController.m
//  3Dmenu
//
//  Created by chuck on 15-6-8.
//  Copyright (c) 2015年 ZK. All rights reserved.
//

#import "ViewController.h"

#define MENU_TABLEVIEW_WIDTH  80

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property(nonatomic,weak)UIScrollView * containView;
@property(nonatomic,weak)UITableView * menuTableView;
@property(nonatomic,weak)UIView * detailView;
@property(nonatomic,weak)UIImageView * imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"3D menu";
    
    UIScrollView * containScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _containView = containScrollView;
    _containView.backgroundColor = [UIColor lightGrayColor];
    _containView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width + MENU_TABLEVIEW_WIDTH, 0);
    _containView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _containView.pagingEnabled = NO;
    _containView.bounces = NO;
    _containView.delegate = self;
    _containView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:containScrollView];
    
    UITableView * tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MENU_TABLEVIEW_WIDTH, [UIScreen mainScreen].bounds.size.height) style:(UITableViewStylePlain)];
    _menuTableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_containView addSubview:_menuTableView];
    
    UIView * detailView = [[UIView alloc] initWithFrame:CGRectMake(MENU_TABLEVIEW_WIDTH, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    detailView.backgroundColor = [UIColor redColor];
    _detailView = detailView;
    [_containView addSubview:detailView];
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    image.image = [UIImage imageNamed:@"touch"];
    _imageView = image;
    [self.detailView addSubview:image];
}

/**
 *  锚点设置：为什么设置锚点为{1.0,0.5},因为菜单视图需要沿Y轴旋转，设置为该点后
 *视图的旋转几点就是最右边的中点。那么，视图选择才能完整显示，如果按照默认的锚点，就是只有一半被显示出来。
 同时，该视图因为再scrollview中，它的位置已经向右边移动，那么只会显示左边的一半。
 */
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.menuTableView.layer.anchorPoint = CGPointMake(1.0, 0.5);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.containView.bounds.size.height - 64)/6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellID = @"UITableViewCell";
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:cellID];
    }
    cell.imageView.image = [UIImage imageNamed:@"icon"];
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor redColor];
    }else if (indexPath.row == 1){
        cell.backgroundColor = [UIColor purpleColor];
    }else if (indexPath.row == 2){
        cell.backgroundColor = [UIColor blueColor];
    }else if (indexPath.row == 3){
        cell.backgroundColor = [UIColor cyanColor];
    }else if (indexPath.row == 4){
        cell.backgroundColor = [UIColor brownColor];
    }else if (indexPath.row == 5){
        cell.backgroundColor = [UIColor orangeColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        _detailView.backgroundColor = [UIColor redColor];
    }else if (indexPath.row == 1){
        _detailView.backgroundColor = [UIColor purpleColor];
    }else if (indexPath.row == 2){
        _detailView.backgroundColor = [UIColor blueColor];
    }else if (indexPath.row == 3){
        _detailView.backgroundColor = [UIColor cyanColor];
    }else if (indexPath.row == 4){
        _detailView.backgroundColor = [UIColor brownColor];
    }else if (indexPath.row == 5){
        _detailView.backgroundColor = [UIColor orangeColor];
    }
}

/**
 *  在这里更改menu以及detailview 的 平移以及角度，并在最后设置,是否使能翻页效果，实现了直接切换
 *
 *  @param scrollView <#scrollView description#>
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat multiplier = 1.0 / CGRectGetWidth(self.menuTableView.bounds);
    CGFloat offset = scrollView.contentOffset.x * multiplier;
    CGFloat fraction = 1.0 - offset;
    self.menuTableView.layer.transform = [self roateView:fraction];
    self.menuTableView.alpha = fraction;
    [self roate:fraction imageView:self.imageView];
    self.containView.pagingEnabled = self.containView.contentOffset.x < (self.containView.contentSize.width - CGRectGetWidth(self.containView.frame));
}

/**
 *  根据scrollview的offset对菜单视图的偏移百分比，从而得到偏移与角度之间的比例关系
 *  注意 CATransform3DConcat 方法的同时可以视图的两个形变同时执行
 *  @param fraction <#fraction description#>
 *
 *  @return <#return value description#>
 */
- (CATransform3D)roateView:(CGFloat)fraction{
    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = -1.0/1000.0;
    CGFloat angle = (1.0 - fraction)* (- M_PI_2);
    CGFloat xOffset = CGRectGetWidth(self.menuTableView.bounds) * 0.5;
    CATransform3D rotateTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0);
    CATransform3D translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0);
    return CATransform3DConcat(rotateTransform, translateTransform);
}

/**
 *  图片的旋转
 *
 *  @param fraction  <#fraction description#>
 *  @param imageView <#imageView description#>
 */
- (void)roate:(CGFloat)fraction imageView:(UIImageView *)imageView{
    // NSLog(@"anch:%@",NSStringFromCGPoint(self.detailView.layer.anchorPoint));
    CGFloat angle = (fraction) * M_PI_2;
    imageView.transform = CGAffineTransformMakeRotation((angle));
}

@end

