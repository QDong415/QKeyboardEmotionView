//
//  QInputBarView.h
//  QKeyBoardDemo
//
//  Created by QDong on 14-4-24.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QInputBarViewConfiguration.h"

//整个Bar的最小高度（即文字只有1行时候的高度）
extern const int UIInputBarViewMinHeight;

@class QInputBarView;

@protocol QInputBarViewDataSource <NSObject>
@optional

//@return 输入条上的UITextView，返回你自定义的UITextView；如果不实现这个方法，本类会自己创建一个UITextView
- (UITextView *)textViewForInputBarView:(QInputBarView *)inputBarView;

@end

@protocol QInputBarViewDelegate <NSObject>

@optional


// 输入框刚好开始编辑
- (void)inputBarView:(QInputBarView *)inputBarView inputTextViewDidBeginEditing:(UITextView *)inputTextView;

// 输入框将要开始编辑
- (void)inputBarView:(QInputBarView *)inputBarView inputTextViewShouldBeginEditing:(UITextView *)inputTextView;

// 输入框的高度发生了改变（因为输入了值）
- (void)inputBarView:(QInputBarView *)inputBarView inputTextView:(UITextView *)inputTextView heightDidChange:(CGFloat)changeValue;

/**
 *  在发送文本和语音之间发送改变时，会触发这个回调函数
 */
- (void)inputBarView:(QInputBarView *)inputBarView onVoiceSwitchButtonClick:(UIButton *)voiceSwitchButton;

/**
 *  点击了系统键盘的发送按钮
 *  @param inputText 目标文本消息
 */
- (void)inputBarView:(QInputBarView *)inputBarView onKeyboardSendClick:(NSString *)inputText;

/**
 *  点击+号按钮Action
 */
- (void)inputBarView:(QInputBarView *)inputBarView onExtendButtonClick:(UIButton *)extendSwitchButton;

/**
 *  发送第三方表情
 */
- (void)inputBarView:(QInputBarView *)inputBarView onEmotionButtonClick:(UIButton *)emotionSwitchButton;

@end

//输入条View，不包含表情面板
@interface QInputBarView : UIView

@property (nonatomic, strong, readonly) UITextView *inputTextView;

@property (nonatomic, strong, readonly) UIButton *recordButton;

@property (nonatomic, weak) id <QInputBarViewDelegate> delegate;

@property (nonatomic, weak) id <QInputBarViewDataSource> dataSource;

// 根据配置设置UI，本方法只需要调用一次
- (void)setupWithConfiguration:(QInputBarViewConfiguration *)configuration;


// 让textView获取焦点
- (void)textViewBecomeFirstResponder;

// 让textView失去焦点
- (void)textViewResignFirstResponder;

// 获取textView的内容文本
- (NSString *)textViewInputText;

// 给textView插入表情
- (void)insertEmotion:(NSString *)emotionKey;

// textView删除表情
// @return YES 表示刚才成功删除了一个表情；
// @return NO 表示刚才没删掉表情（于是本类就什么都不操作，由外部vc实现删除操作。这样做因为vc的自定义tv可能要实现文字块删除，比如 @人名）
- (BOOL)deleteEmotion;

@end
