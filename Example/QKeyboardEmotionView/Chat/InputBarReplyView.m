//
//  InputBarReplyView.m
//  QKeyBoardDemo
//
//  Created by QDong on 14-4-24.
//


#import "InputBarReplyView.h"

@interface InputBarReplyView ()
{
}
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation InputBarReplyView

#pragma mark - Init
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60 , 40)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - 10 - CGRectGetWidth(buttonFrame), 10);
        button.frame = buttonFrame;
        [self addSubview:button];
        
        
        self.deleteButton = button;
        
        self.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1];
    }
    return self;
}


@end
