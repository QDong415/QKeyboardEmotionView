//
//  QKeyboardBaseManager.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "QKeyboardBaseManager.h"

@interface QKeyboardBaseManager()

@end

@implementation QKeyboardBaseManager

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        
        // 键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        //经过DQ测试，ios13死活收不到UIKeyboardDidShowNotification，情况不明
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardDidShowNotification:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardDidHideNotification:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        //  输入栏TextView的高度发送变化的动画时长（秒）
        self.inputBarHeightChangeAnimationDuration = 0.2;
    }
    return self;
}

#pragma mark - Keyboard notifications
- (void)onKeyboardDidShowNotification:(NSNotification *)notification {

}

- (void)onKeyboardDidHideNotification:(NSNotification *)notification {

}

//在模拟器上测试：如果模拟器的键盘无法弹出，那么点击输入栏不会收到WillShowNotification，而是直接收到WillHideNotification，但是这种情况下依然会走textViewShouldBeginEditing
- (void)onKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self onKeyboardWillShowOrHideByNotifications:keyboardRect animationOptions:[self animationOptionsForCurve:curve] duration:duration showKeyboard:YES];
}

- (void)onKeyboardWillHideNotification:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self onKeyboardWillShowOrHideByNotifications:keyboardRect animationOptions:[self animationOptionsForCurve:curve] duration:duration showKeyboard:NO];
}

#pragma mark - Need Override
- (void)onKeyboardWillShowOrHideByNotifications:(CGRect)keyboardRect animationOptions:(UIViewAnimationOptions)animationOptions duration:(double)duration showKeyboard:(BOOL)showKeyboard {
}

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return kNilOptions;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
