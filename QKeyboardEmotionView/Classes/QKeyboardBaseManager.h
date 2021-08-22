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


@end
