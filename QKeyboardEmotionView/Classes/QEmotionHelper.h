//
//  FaceManager.h
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QEmotionBoardView.h"
#import <UIKit/UIKit.h>

//表情转换类
@interface QEmotionHelper : NSObject
{

}

+ (QEmotionHelper *)sharedEmotionHelper;

//显示表情键盘面板的时候，用这个。测试结果是占用0.5MB的内存（永驻）
@property (strong, nonatomic) NSArray<QEmotion *> *emotionArray;

//imageKey：[微笑] font：label的Font，返回😊
//把 @"[微笑]" 转为 @"😊"
- (NSAttributedString *)obtainAttributedStringByImageKey:(NSString *)imageKey font:(UIFont *)font useCache:(BOOL)useCache;

//把 @"害~你好啊[微笑]" 转为 @"害~你好啊😊"
- (NSMutableAttributedString *)attributedStringByText:(NSString *)text font:(UIFont *)font;

@end
