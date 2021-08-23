//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//


#import "ChatXibViewController.h"

@interface ChatXibViewController ()
{

}

@end

@implementation ChatXibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天xib界面";


}

#pragma mark - Override
- (CGFloat)tableViewBottomEdgeInsets {
    return 0;
}

@end
