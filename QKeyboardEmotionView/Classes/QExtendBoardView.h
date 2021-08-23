//
//  QExtendBoardView.h
//  QKeyBoardDemo
//
//  Created by QDong on 14-5-1.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QExtendBoardItemModel : NSObject

/**
 *  Cell图片
 */
@property (nonatomic, strong) UIImage *normalIconImage;

/**
 *  Cell标题
 */
@property (nonatomic, strong) NSString *title;

/**
 *  根据正常图片和标题初始化一个Model对象
 *
 *  @param normalIconImage 正常图片
 *  @param title           标题
 *
 *  @return 返回一个Model对象
 */
- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title;

@end


@protocol QExtendBoardViewDelegate <NSObject>

@optional
/**
 *  点击拓展面板的cell
 *
 *  @param shareMenuItem 被点击的第三方Model对象，可以在这里做一些特殊的定制
 *  @param index         被点击的位置
 */
- (void)didSelectExtendBoardItem:(QExtendBoardItemModel *)shareMenuItem atIndex:(NSInteger)index;

@end


@interface QExtendBoardView : UIView

//第三方功能Models
@property (nonatomic, strong) NSArray *extendBoardItems;

@property (nonatomic, weak) id <QExtendBoardViewDelegate> delegate;

/**
 *  根据数据源刷新第三方功能按钮的布局
 */
- (void)reloadData;


- (void)reloadItemOfIndex:(int)index withNormalIconImage:(UIImage *)image withTitle:(NSString *)title ;

@end
