//
//  QExtendBoardView.m
//  QKeyBoardDemo
//
//  Created by QDong on 14-5-1.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "QExtendBoardView.h"

const int UIPageControlHeight = 56;

const int UIMenuItemCellWidth = 80;

const int UIMenuItemCellHeight = 90;

const int UIPerColumItemCount = 2;

@implementation QExtendBoardItemModel

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title {
    self = [super init];
    if (self) {
        self.normalIconImage = normalIconImage;
        self.title = title;
    }
    return self;
}

- (void)dealloc {
    self.normalIconImage = nil;
    self.title = nil;
}

@end

@interface QExtendBoardCollectionCell : UIView

/**
 *  第三方按钮
 */
@property (nonatomic, weak) UIButton *shareMenuItemButton;
/**
 *  第三方按钮的标题
 */
@property (nonatomic, weak) UILabel *shareMenuItemTitleLabel;

/**
 *  配置默认控件的方法
 */
- (void)setup;
@end

@implementation QExtendBoardCollectionCell

- (void)setup {
    if (!_shareMenuItemButton) {
        UIButton *shareMenuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareMenuItemButton.frame = CGRectMake(0, 0, UIMenuItemCellWidth, UIMenuItemCellWidth);
        shareMenuItemButton.backgroundColor = [UIColor clearColor];
        [self addSubview:shareMenuItemButton];
        
        self.shareMenuItemButton = shareMenuItemButton;
    }
    
    if (!_shareMenuItemTitleLabel) {
        UILabel *shareMenuItemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuItemButton.frame), UIMenuItemCellWidth, 17)];
        shareMenuItemTitleLabel.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            shareMenuItemTitleLabel.textColor = [UIColor colorNamed:@"q_text_black_gray"];
        } else {
            shareMenuItemTitleLabel.textColor = [UIColor colorWithRed:91/255.0f green:91/255.0f blue:91/255.0f alpha:1];
        }
        shareMenuItemTitleLabel.font = [UIFont systemFontOfSize:15];
        shareMenuItemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:shareMenuItemTitleLabel];
        
        self.shareMenuItemTitleLabel = shareMenuItemTitleLabel;
    }
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end

@interface QExtendBoardView () <UIScrollViewDelegate>

/**
 *  这是背景滚动视图
 */
@property (nonatomic, weak) UIScrollView *shareMenuScrollView;

/**
 *  显示页码的视图
 */
@property (nonatomic, weak) UIPageControl *shareMenuPageControl;

/**
 *  第三方按钮点击的事件
 *
 *  @param sender 第三方按钮对象
 */
- (void)shareMenuItemButtonClicked:(UIButton *)sender;

/**
 *  配置默认控件
 */
- (void)setup;

@end

@implementation QExtendBoardView

- (void)shareMenuItemButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectExtendBoardItem:atIndex:)]) {
        NSInteger index = sender.tag;
        if (index < self.extendBoardItems.count) {
            [self.delegate didSelectExtendBoardItem:[self.extendBoardItems objectAtIndex:index] atIndex:index];
        }
    }
}

- (void)reloadItemOfIndex:(int)index withNormalIconImage:(UIImage *)image withTitle:(NSString *)title {
    if ([self.shareMenuScrollView.subviews count] > index) {
        QExtendBoardCollectionCell *shareMenuItemView = self.shareMenuScrollView.subviews[index];
        [shareMenuItemView.shareMenuItemButton setImage:image forState:UIControlStateNormal];
        shareMenuItemView.shareMenuItemTitleLabel.text = title;
    }
}

- (void)reloadData {
    if (!_extendBoardItems.count)
        return;
    // 每行有4个
    int perRowItemCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 10 : 4;
    
    [self.shareMenuScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat paddingX = 10;
    CGFloat paddingY = 10;
    for (QExtendBoardItemModel *shareMenuItem in self.extendBoardItems) {
        NSInteger index = [self.extendBoardItems indexOfObject:shareMenuItem];
        NSInteger page = index / (perRowItemCount * UIPerColumItemCount);
        CGRect shareMenuItemViewFrame = [self getFrameWithPerRowItemCount:perRowItemCount
                                                        perColumItemCount:UIPerColumItemCount
                                                                itemWidth:UIMenuItemCellWidth
                                                               itemHeight:UIMenuItemCellHeight
                                                                 paddingX:paddingX
                                                                 paddingY:paddingY
                                                                  atIndex:index
                                                                   onPage:page];
        QExtendBoardCollectionCell *shareMenuItemView = [[QExtendBoardCollectionCell alloc] initWithFrame:shareMenuItemViewFrame];
        
        shareMenuItemView.shareMenuItemButton.tag = index;
        [shareMenuItemView.shareMenuItemButton addTarget:self action:@selector(shareMenuItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareMenuItemView.shareMenuItemButton setImage:shareMenuItem.normalIconImage forState:UIControlStateNormal];
        shareMenuItemView.shareMenuItemTitleLabel.text = shareMenuItem.title;
        
        [self.shareMenuScrollView addSubview:shareMenuItemView];
    }
    
    self.shareMenuPageControl.numberOfPages = (self.extendBoardItems.count / (perRowItemCount * 2) + (self.extendBoardItems.count % (perRowItemCount * 2) ? 1 : 0));
    [self.shareMenuScrollView setContentSize:CGSizeMake(((self.extendBoardItems.count / (perRowItemCount * 2) + (self.extendBoardItems.count % (perRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(self.shareMenuScrollView.bounds))];
}

/**
 *  通过目标的参数，获取一个grid布局
 *
 *  @param perRowItemCount   每行有多少列
 *  @param perColumItemCount 每列有多少行
 *  @param itemWidth         gridItem的宽度
 *  @param itemHeight        gridItem的高度
 *  @param paddingX          gridItem之间的X轴间隔
 *  @param paddingY          gridItem之间的Y轴间隔
 *  @param index             某个gridItem所在的index序号
 *  @param page              某个gridItem所在的页码
 *
 *  @return 返回一个已经处理好的gridItem frame
 */
- (CGRect)getFrameWithPerRowItemCount:(NSInteger)perRowItemCount
                    perColumItemCount:(NSInteger)perColumItemCount
                            itemWidth:(CGFloat)itemWidth
                           itemHeight:(NSInteger)itemHeight
                             paddingX:(CGFloat)paddingX
                             paddingY:(CGFloat)paddingY
                              atIndex:(NSInteger)index
                               onPage:(NSInteger)page {
    CGRect itemFrame = CGRectMake((index % perRowItemCount) * (itemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / perRowItemCount) - perColumItemCount * page) * (itemHeight + paddingY) + paddingY, itemWidth, itemHeight);
    return itemFrame;
}

#pragma mark - Life cycle

- (void)setup {
    
    if (!_shareMenuScrollView) {
        UIScrollView *shareMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - UIPageControlHeight)];
        shareMenuScrollView.delegate = self;
        shareMenuScrollView.canCancelContentTouches = NO;
        shareMenuScrollView.delaysContentTouches = YES;
        shareMenuScrollView.backgroundColor = self.backgroundColor;
        shareMenuScrollView.showsHorizontalScrollIndicator = NO;
        shareMenuScrollView.showsVerticalScrollIndicator = NO;
        [shareMenuScrollView setScrollsToTop:NO];
        shareMenuScrollView.pagingEnabled = YES;
        [self addSubview:shareMenuScrollView];
        
        self.shareMenuScrollView = shareMenuScrollView;
    }
    
    if (!_shareMenuPageControl) {
        UIPageControl *shareMenuPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuScrollView.frame), CGRectGetWidth(self.bounds), UIPageControlHeight)];
        shareMenuPageControl.backgroundColor = self.backgroundColor;
        shareMenuPageControl.hidesForSinglePage = YES;
        shareMenuPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:shareMenuPageControl];
        
        self.shareMenuPageControl = shareMenuPageControl;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shareMenuScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - UIPageControlHeight);
    self.shareMenuPageControl.frame = CGRectMake(0, CGRectGetMaxY(self.shareMenuScrollView.frame), CGRectGetWidth(self.bounds), UIPageControlHeight);
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.extendBoardItems = nil;
//    self.shareMenuScrollView.delegate = self;
    self.shareMenuScrollView = nil;
    self.shareMenuPageControl = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.shareMenuPageControl setCurrentPage:currentPage];
}

@end
