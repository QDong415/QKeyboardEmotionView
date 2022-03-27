//
//  UITextView+QEmotion.h
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (QEmotion)

// 给textView插入表情图片，比如😊
- (void)insertEmotionAttributedString:(NSAttributedString *)emotionAttributedString;

// 给textView插入表情的文本，比如[微笑]
- (void)insertEmotion:(NSString *)emotionKey;

// textView删除表情
// @return YES 表示刚才成功删除了一个表情；
// @return NO 表示刚才没删掉表情（于是本类就什么都不操作，由外部vc实现删除操作。这样做因为vc的自定义tv可能要实现文字块删除，比如 @人名）
- (BOOL)deleteEmotion;

- (NSString *)normalText;

@end

NS_ASSUME_NONNULL_END
