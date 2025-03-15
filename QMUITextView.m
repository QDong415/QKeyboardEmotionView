/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITextView.m
//  qmui
//
//  Created by QMUI Team on 14-8-5.
//
#import "QMUITextView.h"

/// 系统 textView 默认的字号大小，用于 placeholder 默认的文字大小。实测得到，请勿修改。
const CGFloat kSystemTextViewDefaultFontPointSize = 12.0f;

/// 当系统的 textView.textContainerInset 为 UIEdgeInsetsZero 时，文字与 textView 边缘的间距。实测得到，请勿修改（在输入框font大于13时准确，小于等于12时，y有-1px的偏差）。
const UIEdgeInsets kSystemTextViewFixTextInsets = {0, 5, 0, 5};

@interface QMUITextView ()

@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation QMUITextView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {

    self.scrollsToTop = NO;
    self.placeholderMargins = UIEdgeInsetsZero;

    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.font = [UIFont systemFontOfSize:kSystemTextViewDefaultFontPointSize];
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
    
    // 监听用户手工输入引发的文字变化（代码里通过 setText: 修改的不在这个监听范围内）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:self];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self handleTextChanged:self];
}

- (void)setTypingAttributes:(NSDictionary<NSString *,id> *)typingAttributes {
    [super setTypingAttributes:typingAttributes];
    [self updatePlaceholderStyle];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updatePlaceholderStyle];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self updatePlaceholderStyle];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updatePlaceholderStyle];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.attributedText = placeholder ? [[NSAttributedString alloc] initWithString:_placeholder attributes:self.typingAttributes] : nil;
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
    [self updatePlaceholderLabelHidden];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}

- (void)updatePlaceholderStyle {
    self.placeholder = self.placeholder;// 触发文字样式的更新
}

- (void)updatePlaceholderLabelHidden {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;// 用alpha来让placeholder隐藏，从而尽量避免因为显隐 placeholder 导致 layout
    }
}

- (CGRect)preferredPlaceholderFrameWithSize:(CGSize)size {
    if (self.placeholder.length <= 0) return CGRectZero;
    
    UIEdgeInsets allInsets = self.allInsets;
    UIEdgeInsets labelMargins = UIEdgeInsetsMake(allInsets.top - self.adjustedContentInset.top, allInsets.left - self.adjustedContentInset.left, allInsets.bottom - self.adjustedContentInset.bottom, allInsets.right - self.adjustedContentInset.right);
    CGFloat limitWidth = size.width - allInsets.left - allInsets.right;
    CGFloat limitHeight = size.height - allInsets.top - allInsets.bottom;
    CGSize labelSize = [self.placeholderLabel sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
    labelSize.width = limitWidth == CGFLOAT_MAX ? MIN(limitWidth, labelSize.width) : limitWidth;// 当 limitWidth 为 CGFLOAT_MAX 时，意味着此时是 sizeToFit 触发的 sizeThatFits:，从而调用到这里，此时语义上希望得到 placeholder 的实际内容宽高，于是拿 labelSize.width 作为返回值。如果不是那边过来的，则让 placeholderLabel 宽度撑满，从而适配 NSTextAlignmentRight。
    labelSize.height = MIN(limitHeight, labelSize.height);
    return CGRectMake(labelMargins.left, labelMargins.top, labelSize.width, labelSize.height);
}

- (void)handleTextChanged:(id)sender {
    QMUITextView *textView = nil;
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QMUITextView *)object;
        }
    } else if ([sender isKindOfClass:[QMUITextView class]]) {
        textView = (QMUITextView *)sender;
    }
    
    if (!textView) return;
    
    // 输入字符的时候，placeholder隐藏
    if (self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width <= 0) size.width = CGFLOAT_MAX;
    if (size.height <= 0) size.height = CGFLOAT_MAX;
    CGSize result = CGSizeZero;
    if (self.placeholder.length > 0 && self.text.length <= 0) {
        UIEdgeInsets allInsets = self.allInsets;
        CGRect frame = [self preferredPlaceholderFrameWithSize:size];
        result.width = CGRectGetWidth(frame) + allInsets.left + allInsets.right;
        result.height = CGRectGetHeight(frame) + allInsets.top + allInsets.bottom;
    } else {
        result = [super sizeThatFits:size];
    }
//    result.height = MIN(result.height, self.maximumHeight);
    return result;
}

- (UIEdgeInsets)allInsets {
    return UIEdgeInsetsConcat(UIEdgeInsetsConcat(UIEdgeInsetsConcat(self.textContainerInset, self.placeholderMargins), kSystemTextViewFixTextInsets), self.adjustedContentInset);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0) {
        CGRect frame = [self preferredPlaceholderFrameWithSize:self.bounds.size];
        self.placeholderLabel.frame = frame;
    }
}

/// 将两个UIEdgeInsets合并为一个
CG_INLINE UIEdgeInsets
UIEdgeInsetsConcat(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    insets1.top += insets2.top;
    insets1.left += insets2.left;
    insets1.bottom += insets2.bottom;
    insets1.right += insets2.right;
    return insets1;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    [self updatePlaceholderLabelHidden];
//}

@end
