//
//  QPlaceHolderTextView.h
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QPlaceHolderTextView : UITextView


/**
 *   placeholder 的文字
 */
@property(nonatomic, copy) IBInspectable NSString *placeholder;

/**
 *  placeholder 文字的颜色
 */
@property(nonatomic, strong) IBInspectable UIColor *placeholderColor;

/**
 *  placeholder 在默认位置上的偏移（默认位置会自动根据 textContainerInset、contentInset 来调整）
 */
@property(nonatomic, assign) UIEdgeInsets placeholderMargins;


@end
