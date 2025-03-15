//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//


#import "ChatSendButtonViewController.h"

@interface ChatSendButtonViewController ()
{

}

@end

@implementation ChatSendButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天（自动感应右侧sendButton）";

}

- (IBAction)chatInputOrderClick:(UITapGestureRecognizer *)tap {
    NSLog(@"chatInputOrderClick");
}

#pragma mark - Override
- (QInputBarViewConfiguration *)inputBarViewConfiguration {
    //输入条配置，子类可以重写
    QInputBarViewConfiguration *config = [QInputBarViewConfiguration defaultInputBarViewConfiguration];
    config.extendButtonHidden = NO;//隐藏右侧拓展按钮
    
    //frame的xy传0就行，宽高你设置为自己的
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [sendButton setTitle:@"发" forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor blueColor]];
    [sendButton addTarget:self action:@selector(onSendButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    config.rightSendButton = sendButton;
    
    
    //demo：输入栏里添加东西
    UIImageView *chatInputOrderImageView = [UIImageView new];
    chatInputOrderImageView.contentMode = UIViewContentModeCenter;
    chatInputOrderImageView.image = [UIImage imageNamed:@"chat_input_order"];
    [chatInputOrderImageView setUserInteractionEnabled: YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatInputOrderClick:)];
    [chatInputOrderImageView addGestureRecognizer:tapGesture];
    CGFloat imageSize = 32;
    chatInputOrderImageView.frame = CGRectMake(0, 0, imageSize, imageSize);
    config.inputInsetRightView = chatInputOrderImageView;
    
    return config;
}

//输入文本变化
- (void)inputBarView:(QInputBarView *)inputBarView textViewDidChange:(UITextView *)inputTextView {
    NSLog(@"子类 输入文本变化");
}

//点击了“发送”按钮
- (IBAction)onSendButtonSelect:(UIButton *)sender {
//    [self sendTextMessage]
}


@end
