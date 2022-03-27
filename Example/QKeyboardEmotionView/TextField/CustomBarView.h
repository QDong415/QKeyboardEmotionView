//
//  CustomBarView.h
//  QKeyBoardDemo
//
//  Created by QDong on 14-4-24.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomBarView;

@protocol CustomBarViewDelegate <NSObject>

@optional

/**
 *  点击了系统键盘的发送按钮
 *  @param inputText 目标文本消息
 */
- (void)inputBarView:(CustomBarView *)inputBarView onKeyboardSendClick:(NSString *)inputNormalText;

/**
 *  点击+号按钮Action
 */
- (void)inputBarView:(CustomBarView *)inputBarView onExtendButtonClick:(UIButton *)extendSwitchButton;

/**
 *  发送第三方表情
 */
- (void)inputBarView:(CustomBarView *)inputBarView onEmotionButtonClick:(UIButton *)emotionSwitchButton;

@end

//自定义输入条
@interface CustomBarView : UIView

@property (nonatomic, weak) id <CustomBarViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *emotionSwitchButton;

@property (nonatomic, strong, readonly) UIButton *atSwitchButton;

@end
