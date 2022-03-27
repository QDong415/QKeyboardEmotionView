//
//  QEmotionAttachment.h
//  QKeyboardEmotionView
//
//  Created by DongJin on 2022/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//为了获取输入框里的纯文本，只能自己新建一个类
@interface QEmotionAttachment : NSTextAttachment

@property (nonatomic, strong) NSString *displayText;

@end

NS_ASSUME_NONNULL_END
