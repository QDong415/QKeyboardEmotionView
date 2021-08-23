//
//  SubmitToolBarView.m
//  QKeyBoardDemo
//
//  Created by QDong on 14-4-24.
//


#import "SubmitToolBarView.h"

//我这里import QKeyboardBaseManager 仅仅是为了取到pods库中的图片bundle；如果图片换成在你自己项目中的xcassets，就无需import
#import "QKeyboardBaseManager.h"

@interface SubmitToolBarView ()
{
}
@property (nonatomic, strong) UIButton *extendSwitchButton;
@property (nonatomic, strong) UIButton *emotionSwitchButton;

@end

@implementation SubmitToolBarView

#pragma mark - Init
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        
        const int UISwitchButtonWidth = 36; // 3个按钮固定宽高
        const int horizontalPadding = 8; // 水平间隔
        const CGFloat verticalPadding = (frame.size.height - UISwitchButtonWidth )/2;// 垂直间隔
        CGFloat allButtonWidth = 0.0; // 需要显示按钮的总宽度，包括间隔在内

        
        NSBundle *bundle = [NSBundle bundleForClass:[QKeyboardBaseManager class]];
        // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_extend_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onExtendSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        self.extendSwitchButton = button;
        
        // 允许发送表情
        button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_emoji_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_keyboard_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onEmotionSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetMinX(self.extendSwitchButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 1.5;
        button.frame = buttonFrame;
        [self addSubview:button];
        
        self.emotionSwitchButton = button;
        
        //输入条的上方添加一行细线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1 / [UIScreen mainScreen].scale)];
        lineView.backgroundColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1];
        [self addSubview:lineView];
        
        self.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1];
    }
    return self;
}



// 右边表情\键盘切换按钮点击
- (IBAction)onEmotionSwitchButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.extendSwitchButton.selected = NO;
    
    if ([self.delegate respondsToSelector:@selector(inputBarView:onEmotionButtonClick:)]) {
        [self.delegate inputBarView:self onEmotionButtonClick:sender];
    }
}

// 右边表情\键盘切换按钮点击
- (IBAction)onExtendSwitchButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.emotionSwitchButton.selected = NO;
    if ([self.delegate respondsToSelector:@selector(inputBarView:onExtendButtonClick:)]) {
        [self.delegate inputBarView:self onExtendButtonClick:sender];
    }
}


- (void)dealloc {
    _extendSwitchButton = nil;
    _emotionSwitchButton = nil;
}


@end
