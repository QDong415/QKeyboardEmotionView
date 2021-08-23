//
//  ViewController.h
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "CommonViewController.h"

@interface DiscussViewController : CommonViewController

//输入条平时是否在vc下面（NO=平时也显示，YES=平时不显示）
//我是为了封装demo才把这个变量设置为public，实际开发中, 无需对外开放
@property(nonatomic,assign) BOOL belowViewController;

@end

