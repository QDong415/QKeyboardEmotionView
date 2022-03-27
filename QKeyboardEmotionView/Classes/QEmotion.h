//
//  QEmotion.h
//  QKeyboardEmotionView
//
//  Created by DongJin on 2022/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  代表一个表情的数据对象
 */
@interface QEmotion : NSObject

/// 当前表情的标识符，可用于区分不同表情
@property(nonatomic, copy) NSString *identifier;

/// 当前表情展示出来的名字，可用于输入框里的占位文字，请务必使用统一的左右标识符将表情名称包裹起来（例如常见的“[]”），否则在 `QMUIEmotionInputManager` 里会因为找不到标识符而无法准确识别出一串文本里的哪些字符是代表一个表情。合法的 displayName 例子：“[委屈]”
@property(nonatomic, copy) NSString *displayName;

/// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
@property(nonatomic, strong) UIImage *image;
            
/**
 *  快速生成一个`QMUIEmotion`对象，并且以`identifier`为图片名在当前项目里查找，作为表情的图片
 *  @param  identifier  表情的标识符，也会被当成图片的名字
 *  @param  displayName 表情展示出来的名字
 */
+ (instancetype)emotionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName;

@end

NS_ASSUME_NONNULL_END
