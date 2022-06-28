//
//  FaceManager.m
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "QEmotionHelper.h"
#import "QEmotionAttachment.h"

@interface QEmotionHelper()

//key是 图片名：比如：[微笑] ；   value是😊(Image)
//把[微笑]转为😊的时候，用这个。//占用内存0.2M
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *cacheTotalImageDictionary;

//key是 图片名+font：比如：[微笑]17 ；  value是😊(NSAttributedString)
//Tips：ios15用不到这个
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSAttributedString *> *cacheAttributedDictionary;

//把[微笑]转为😊的正则
@property (strong, nonatomic) NSRegularExpression * regularExpression;


@end

@implementation QEmotionHelper

+ (QEmotionHelper *)sharedEmotionHelper {
    static QEmotionHelper *_sharedFaceManager = nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedFaceManager = [[QEmotionHelper alloc] init];
       
        _sharedFaceManager.regularExpression =
        [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                  options:kNilOptions
                                                    error:nil];
        
        _sharedFaceManager.cacheAttributedDictionary = [NSMutableDictionary dictionary];
    });
    return _sharedFaceManager;
}

#pragma mark - public
//本方法我这里只是demo演示；实际开发中，可以改为你自己的获取表情列表的写法
//由于emotionArray包含Image，测试结果是占用0.5MB的内存（永驻）
- (void)setEmotionArray:(NSArray<QEmotion *> *)emotionArray {
    
    _emotionArray = emotionArray;
      
    //重置Image字典
    _cacheTotalImageDictionary = nil;
    [self cacheTotalImageDictionary];
}

//懒加载；key是 图片名：比如：[微笑] ；   value是😊(Image)
- (NSDictionary<NSString *, UIImage *> *)cacheTotalImageDictionary {
    if (!_cacheTotalImageDictionary) {
        NSMutableDictionary<NSString *, UIImage *> *emotionImageDictionary = [[NSMutableDictionary alloc] init];
        for (QEmotion *e in _emotionArray) {
            if (!e.image) {
                //建议在外部AppDelegate里就设置好image，不建议走这里
                e.image = [UIImage imageNamed:e.identifier];
            }
            [emotionImageDictionary setObject:e.image forKey:e.displayName];
        }
        _cacheTotalImageDictionary = emotionImageDictionary;
    }
    return _cacheTotalImageDictionary;
}

//把整段String：@"害~你好[微笑]" 转为 @"害~你好😊"
- (NSMutableAttributedString *)attributedStringByText:(NSString *)text font:(UIFont *)font {
    
    NSArray<NSTextCheckingResult *> *emojis = [self.regularExpression matchesInString:text options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [text length])];
    
    NSMutableAttributedString *intactAttributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 逆序遍历数组
    [emojis enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSTextCheckingResult *result = (NSTextCheckingResult *)obj;
        
        NSString *emojiKey = [text substringWithRange:result.range];

        BOOL useCache = YES;
        if (@available(iOS 15.0, *)) {
            //在ios15上不可以用缓存的NSAttributedString，会只出现1个表情，在ios14以及之前是可以。
            //ios15他采用了NSTextAttachmentViewProvider，具体我没研究
            useCache = NO;
        }
        NSAttributedString *imageAttributedString = [self obtainAttributedStringByImageKey:emojiKey font:font useCache:useCache];
        if (imageAttributedString) {
            [intactAttributeString replaceCharactersInRange:result.range withAttributedString:imageAttributedString];
        }
    }];
    
    // 修复由于插入AttributeString而导致font改变的问题；防止插入表情后textView的font变小
    [intactAttributeString addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, intactAttributeString.length)];
    
    return intactAttributeString;
}

#pragma mark - public
//把只是单纯的一个表情转为AttributedString
//imageKey：[微笑] ，font：label的Font，返回😊
//把 @"[微笑]" 转为 @"😊"
- (NSAttributedString *)obtainAttributedStringByImageKey:(NSString *)imageKey font:(UIFont *)font useCache:(BOOL)useCache {
    
    if (!useCache) {
        //不从缓存中取AttributedString，（因为输入栏中的AttributedString如果是同一个对象，在ios12上会有长按bug）
        UIImage *image = self.cacheTotalImageDictionary[imageKey];
        if (!image){
            //说明压根就没匹配上，比如：[随便打的字]
            return nil;
        }
        QEmotionAttachment *attachMent = [[QEmotionAttachment alloc] init];
        attachMent.displayText = imageKey;
        attachMent.image = image;
        attachMent.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
        return [NSAttributedString attributedStringWithAttachment:attachMent];
    }
    
    //keyFont 是： [微笑]17 、[旺柴]17
    NSString *keyFont = [NSString stringWithFormat:@"%@%.1f", imageKey, font.pointSize];
    //在ios15上不可以用缓存的NSAttributedString，在ios14以及之前是可以
    NSAttributedString *result = _cacheAttributedDictionary[keyFont];
    if (result){
        //从缓存中取
        return result;
    }
    
    UIImage *image = self.cacheTotalImageDictionary[imageKey];
    if (!image){
        //说明压根就没匹配上，比如：[随便打的字]
        return nil;
    }
    QEmotionAttachment *attachMent = [[QEmotionAttachment alloc] init];
    attachMent.image = image;
    attachMent.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
    attachMent.displayText = imageKey;
    result = [NSAttributedString attributedStringWithAttachment:attachMent];
    //[微笑]17 对应的NSAttributedString 缓存到Dictionary中
    [_cacheAttributedDictionary setObject:result forKey:keyFont];
    return result;
}


@end
