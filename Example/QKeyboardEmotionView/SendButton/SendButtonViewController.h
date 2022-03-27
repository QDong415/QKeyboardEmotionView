//
//  ViewController.h
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import <UIKit/UIKit.h>
#import "QKeyboardManager.h"
#import "QInputBarView.h"

@interface SendButtonViewController : UIViewController

//我是为了封装demo才把这两个变量设置为public，实际开发中, 无需对外开放
@property(nonatomic,strong)QKeyboardManager *keyboardManager;

@property(nonatomic,strong)QInputBarView *inputView;

@end

