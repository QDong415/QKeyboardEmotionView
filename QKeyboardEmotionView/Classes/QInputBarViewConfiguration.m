//
//  QKeyboardConfiguration.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "QInputBarViewConfiguration.h"

@implementation QInputBarViewConfiguration

+ (instancetype)defaultInputBarViewConfiguration
{
    QInputBarViewConfiguration *configuration = [QInputBarViewConfiguration new];

    if (@available(iOS 11.0, *)) {
        configuration.inputBarBackgroundColor = [UIColor colorNamed:@"q_input_gray_bg"];
        configuration.inputBarBoardColor = [UIColor colorNamed:@"q_border223"];
        configuration.textColor = [UIColor colorNamed:@"q_black_gray"];
        configuration.textViewBackgroundColor = [UIColor colorNamed:@"q_input"];
        configuration.recordButtonTitleColor = [UIColor colorNamed:@"q_black_white"];
    } else {
        configuration.inputBarBackgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1];
        configuration.inputBarBoardColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1];
        
        configuration.textColor = [UIColor blackColor];
        configuration.textViewBackgroundColor = [UIColor whiteColor];
        configuration.recordButtonTitleColor = [UIColor darkGrayColor];
    }
    configuration.keyboardSendEnabled = YES;
    return configuration;
}

@end
