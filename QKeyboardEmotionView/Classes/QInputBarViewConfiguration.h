//
//  QInputBarViewConfiguration.h
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QInputBarViewConfiguration : NSObject

- (instancetype)init NS_UNAVAILABLE;


/**
 默认相册配置
 */
+ (instancetype)defaultInputBarViewConfiguration;


@property (nonatomic, strong) UIColor *inputBarBackgroundColor;//输入条颜色，默认仿微信的灰色

@property (nonatomic, strong) UIColor *inputBarBoardColor;//输入条上方的的那一条细横线的颜色

@property (nonatomic, strong) UIColor *textColor;//输入栏textview的颜色

@property (nonatomic, strong) UIColor *textViewBackgroundColor;//输入栏textview的背景颜色，默认白色

@property (nonatomic, strong) UIColor *recordButtonTitleColor;//按住说话按钮的字体颜色

@property (nonatomic, strong) UIButton *rightSendButton;//如果不为nil，那么替换掉右边的"+"按钮 //default is nil

//语音条上的title，当voiceButtonHidden为No时候才有效
@property (nonatomic, strong) NSString *speakButtonTitle;//default is nil。nil就显示@"按住说话"

/// 是否隐藏发送语音
@property (nonatomic, assign) BOOL voiceButtonHidden; // default is NO

/// 是否隐藏发送多媒体
@property (nonatomic, assign) BOOL extendButtonHidden; // default is NO

/// 是否隐藏发送表情
@property (nonatomic, assign) BOOL emotionButtonHidden; // default is NO

/// 点击键盘右下角的按钮是否是发送，NO表示普通回车换行，YES表示回调Delegate的Send方法
@property (nonatomic, assign) BOOL keyboardSendEnabled; // default is YES

///  输入栏TextView的高度发送变化的动画时长（秒）
@property (nonatomic, assign) NSTimeInterval inputBarHeightChangeAnimationDuration; // default is 0.2

@end
