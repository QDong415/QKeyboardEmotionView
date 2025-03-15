//
//  HolderTextView.h
//  TextViewDemo
//
//  Created by YiChe on 16/6/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

//记录插入文本的索引
#define SPECIAL_TEXT_NUM   @"specialTextNum"


@class QCustomTextView;

@protocol HolderTextViewDelegate <NSObject>

@optional
/**
 *  HolderTextView输入了done的回调
 *  一般在self.textView.returnKeyType = UIReturnKeyDone;时执行该回调
 */
- (void)holderTextViewEnterDone:(QCustomTextView *)textView;

// 用户输入了@
- (BOOL)holderTextViewEnterAt:(QCustomTextView *)textView;

/**
 *  HolderTextView自动改变高度
 */
- (void)holderTextView:(QCustomTextView *)textView heightChanged:(CGRect)frame;

- (BOOL)textViewShouldBeginEditing:(QCustomTextView *)textView;
- (BOOL)textViewShouldEndEditing:(QCustomTextView *)textView;

- (void)textViewDidBeginEditing:(QCustomTextView *)textView;
- (void)textViewDidEndEditing:(QCustomTextView *)textView;

- (BOOL)textView:(QCustomTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(QCustomTextView *)textView;

- (void)textViewDidChangeSelection:(QCustomTextView *)textView;

- (BOOL)textView:(QCustomTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
- (BOOL)textView:(QCustomTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);

@end

@interface QCustomTextView : UITextView

@property (nonatomic, weak) id<HolderTextViewDelegate> holderTextViewDelegate;
@property (nonatomic, copy, setter=setPlaceHoldString:)   NSString *placeHoldString;
@property (nonatomic, strong, setter=setPlaceHoldTextFont:) UIFont *placeHoldTextFont;
@property (nonatomic, strong, setter=setPlaceHoldTextColor:) UIColor *placeHoldTextColor;

/**
 *  placeHold提示内容Insets值(default (4, 4, 4, 4))
 */
@property (nonatomic, assign, setter=setPlaceHoldContainerInset:) UIEdgeInsets placeHoldContainerInset;

/**
 *  是否根据输入内容自动调整高度(default NO)
 */
@property (nonatomic, assign, setter=setAutoLayoutHeight:) BOOL autoLayoutHeight;
/**
 *  autoLayoutHeight为YES时的最大高度(default MAXFLOAT)
 */
@property (nonatomic, assign) CGFloat maxHeight;

/**
 *  插入文本的颜色(default self.textColor)
 */
@property (nonatomic, strong, getter=getSpecialTextColor) UIColor *specialTextColor;

/**
 *  插入文本是否可编辑(default NO)
 */
@property (nonatomic, assign) BOOL enableEditInsterText;

/**
 *  在指定位置插入字符，并返回插入字符后的SelectedRange值
 *
 *  @param specialText    要插入的字符
 *  @param selectedRange  插入位置
 *  @param attributedText 插入前的文本
 *
 *  @return 插入字符后的光标位置
 */
- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText;

/**
 *  HolderTextView直接显示富文本需先设置一下初始值显示效果才有效
 */
- (void)installStatus;

/**
 *  2017-01-16 DQ 删除
 */
- (void)deleteWords;

/**
 *  插入表情key，isDelete表示删除
 */
- (void)insertEmotion:(NSString *)emotionKey isDelete:(BOOL)isDelete;

@end
