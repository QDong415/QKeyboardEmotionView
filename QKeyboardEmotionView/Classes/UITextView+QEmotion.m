//
//  UITextView+QEmotion.h
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "UITextView+QEmotion.h"
#import "QEmotionAttachment.h"

@implementation UITextView (QEmotion)

// 给textView插入表情图片，比如😊
- (void)insertEmotionAttributedString:(NSAttributedString *)emotionAttributedString {
    if (!emotionAttributedString){
        return;
    }
    NSMutableAttributedString *content = self.attributedText.mutableCopy;
    // 获得光标所在的位置
    int location = (int)self.selectedRange.location;
    [content insertAttributedString:emotionAttributedString atIndex:location];
    // 修复由于插入AttributeString而导致font改变的问题；防止插入表情后textView的font变小
    [content addAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor} range:NSMakeRange(location, emotionAttributedString.length)];
    
    self.attributedText = content;
    //重新设置光标位置
    NSRange range;
    range.location = location + emotionAttributedString.length;
    range.length = 0;
    self.selectedRange = range;
}

// 给textView插入表情的文本，比如[微笑]
- (void)insertEmotion:(NSString *)emotionKey {
    NSMutableAttributedString *content = self.attributedText.mutableCopy;
    // 获得光标所在的位置
    int location = (int)self.selectedRange.location;
    [content insertAttributedString:[[NSAttributedString alloc] initWithString:emotionKey attributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor}] atIndex:location];
    // 将调整后的字符串添加到UITextView上面
    self.attributedText = content;
    //重新设置光标位置
    NSRange range;
    range.location = location + emotionKey.length;
    range.length = 0;
    self.selectedRange = range;
}

// textView删除表情
// @return YES 表示刚才成功删除了一个表情；
// @return NO 表示刚才没删掉表情（于是本类就什么都不操作，由外部vc实现删除操作。这样做因为vc的自定义tv可能要实现文字块删除，比如 @人名）
- (BOOL)deleteEmotion {
    //点的是删除按钮，获得光标所在的位置
    int location = (int)self.selectedRange.location;
    if(location == 0){
        return NO;
    }
    // 先获取前半段
    NSString *headresult = [self.text substringToIndex:location];

    if ([headresult hasSuffix:@"]"]) {
        //最后一位是]
        for (int i = (int)[headresult length]; i>=0 ; i--) {
            //往前找，找到"["
            char tempString = [headresult characterAtIndex:(i-1)];
            if (tempString == '[') {
                NSMutableAttributedString *content = self.attributedText.mutableCopy;
                //砍掉[XXX]，重新赋值前半段
                [content deleteCharactersInRange:NSMakeRange(i - 1,location - i + 1)];
                self.attributedText = content;
                //重新设置光标位置
                NSRange range;
                range.location = [headresult length];
                range.length = 0;
                self.selectedRange = range;
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)normalText {
    NSMutableString *normalMutableString = self.attributedText.string.mutableCopy;

    [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, [self.attributedText length])
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[QEmotionAttachment class]]) {
            QEmotionAttachment *valueAttachment = (QEmotionAttachment *)value;
            NSRange newRange = NSMakeRange(range.location, range.length);
            [normalMutableString replaceCharactersInRange:newRange withString:valueAttachment.displayText];
        }
    }];
    return normalMutableString;
}

@end
