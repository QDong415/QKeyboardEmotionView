//
//  QKeyboardBaseManager.h
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QInputBarViewConfiguration.h"

@interface QKeyboardBaseManager : NSObject

- (instancetype)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, weak) UIViewController *viewController;//当前vc

//  输入栏TextView的高度发送变化的动画时长（秒）
@property (nonatomic, assign) NSTimeInterval inputBarHeightChangeAnimationDuration; // default is 0.2

@end
