//
//  QInputBarView.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

//整个Bar的最小高度（即文字只有1行时候的高度）
const int UIInputBarViewMinHeight = 56;

//Bar里面的UITextView的最小高度（即文字只有1行时候的高度）
const int UIInputTextViewMinHeight = 38;

//Bar里面的TextView的最大高度（即文字有超多行时候的高度）
const int UIInputTextViewMaxHeight = 152;

#import "QInputBarView.h"

//默认的输入bar，包含了：左侧的语音切换按钮，中间的textview和按住录音按钮，右侧的表情和拓展按钮，（总之，仿微信的输入条）
//上述按钮都可以设置隐藏，如果还是无法满足你的需求，请自定义UIView，参考TextFieldViewController
@interface QInputBarView () <UITextViewDelegate>
{
}
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIButton *voiceSwitchButton;
@property (nonatomic, strong) UIButton *extendSwitchButton;
@property (nonatomic, strong) UIButton *emotionSwitchButton;
@property (nonatomic, strong) UIButton *recordButton; //按住不松录音的长条按钮

// 点击键盘右下角的按钮是否是发送，NO表示普通回车换行，YES表示回调Delegate的Send方法
@property (nonatomic, assign) BOOL keyboardSendEnabled; // default is YES

//在切换语音和文本消息的时候，需要保存原本已经输入的文本
@property (nonatomic, strong) NSString *inputedText;
//记录旧的textView Heigth
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;

@end

@implementation QInputBarView

#pragma mark - Init
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupWithConfiguration:(QInputBarViewConfiguration *)configuration
{
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.keyboardSendEnabled = configuration.keyboardSendEnabled;
    
    const int UISwitchButtonWidth = 36; // 3个按钮固定宽高
    const int horizontalPadding = 8; // 水平间隔
    const CGFloat verticalPadding = (UIInputBarViewMinHeight - UISwitchButtonWidth )/2;// 垂直间隔
    CGFloat textViewFrameX = 0;// 输入框的frame.x
    CGFloat rightViewsMinX = 0;// 输入框右边的按钮的minY，为了计算textView的宽度
    const CGFloat textViewHorizontalMargin = 8; //输入框的左右margin
    CGFloat safeAreaInsetsLeft = 0;
    CGFloat safeAreaInsetsRight = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetsLeft = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.left;
        safeAreaInsetsRight = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.right;
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // 允许发送语音
    if (!configuration.voiceButtonHidden) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_voice_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_keyboard_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onVoiceSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding + safeAreaInsetsLeft, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        self.voiceSwitchButton = button;
        textViewFrameX = CGRectGetMaxX(button.frame);
    } else {
        textViewFrameX = safeAreaInsetsLeft;
    }
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要
    if (!configuration.extendButtonHidden) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_extend_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onExtendSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame) - safeAreaInsetsRight, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        rightViewsMinX = CGRectGetMinX(buttonFrame);
        self.extendSwitchButton = button;
    } else {
        rightViewsMinX = CGRectGetWidth(self.bounds) - safeAreaInsetsRight;
    }
    
    // 允许发送表情
    if (!configuration.emotionButtonHidden) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_emoji_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_keyboard_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onEmotionSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFrame = button.frame;
        if (!configuration.extendButtonHidden) {
            buttonFrame.origin = CGPointMake(CGRectGetMinX(self.extendSwitchButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
        } else {
            buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame) - safeAreaInsetsRight, verticalPadding);
        }
        button.frame = buttonFrame;
        [self addSubview:button];
        self.emotionSwitchButton = button;
        
        rightViewsMinX = CGRectGetMinX(buttonFrame);
    } else {
        //不显示表情按钮，rightViewsMinX已经在上面处理好了
    }
    
    // 输入框的宽度
    CGFloat textViewWidth = rightViewsMinX - textViewHorizontalMargin - textViewFrameX - textViewHorizontalMargin;

    // 初始化输入框
    UITextView *textView = nil;
    if ([self.dataSource respondsToSelector:@selector(textViewForInputBarView:)]) {
        //textView 是由vc实现的，本类只设置一下frame
        textView = [self.dataSource textViewForInputBarView:self];
    }
    
    if (!textView){
        //vc没有提供UITextView，我们自己来实现
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.font = [UIFont systemFontOfSize:17];
        textView.returnKeyType = UIReturnKeySend;
        textView.scrollsToTop = NO;
        textView.textAlignment = NSTextAlignmentLeft;
        textView.layer.cornerRadius = 6.0f;
        textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    }
    //本类来控制tv的frame和delegate
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.delegate = self;
    
    //用kvo来监听输入文本的改变，进而改变tv高度和整个bar高度
    [textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:textView];
    textView.frame = CGRectMake(textViewFrameX + textViewHorizontalMargin, (UIInputBarViewMinHeight - UIInputTextViewMinHeight)/2, textViewWidth, UIInputTextViewMinHeight);
    self.inputTextView = textView;
    
    //记录初始化时候的textview高度
    self.previousTextViewContentHeight = [self getTextViewContentHeight];
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
    if (!configuration.voiceButtonHidden) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.inputTextView.frame];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [button setBackgroundImage:[UIImage imageNamed:@"q_white_input_btn" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"q_white_input_press_btn" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
        [button setTitle:@"按住说话" forState:UIControlStateNormal];
        button.alpha = self.voiceSwitchButton.selected;
        [self addSubview:button];
        self.recordButton = button;
    }
    
    self.backgroundColor = configuration.inputBarBackgroundColor;
    _inputTextView.textColor = configuration.textColor;
    _inputTextView.backgroundColor = configuration.textViewBackgroundColor;
    [self.recordButton setTitleColor:configuration.recordButtonTitleColor forState:UIControlStateNormal];

    //输入条的上方添加一行细线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1 / [UIScreen mainScreen].scale)];
    lineView.backgroundColor = configuration.inputBarBoardColor;
    [self addSubview:lineView];
}

#pragma mark - IBAction
// 左边语音\键盘切换按钮点击
- (IBAction)onVoiceSwitchButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.emotionSwitchButton.selected = NO;
    self.extendSwitchButton.selected = NO;
    
    if (sender.selected) {
        self.inputedText = self.inputTextView.text;
        self.inputTextView.text = @"";
        [self.inputTextView resignFirstResponder];
    } else {
        self.inputTextView.text = self.inputedText;
        self.inputedText = nil;
        [self.inputTextView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.recordButton.alpha = sender.selected;
        self.inputTextView.alpha = !sender.selected;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(inputBarView:onVoiceSwitchButtonClick:)]) {
        [self.delegate inputBarView:self onVoiceSwitchButtonClick:sender];
    }
}

// 右边表情\键盘切换按钮点击
- (IBAction)onEmotionSwitchButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.voiceSwitchButton.selected = NO;
    self.extendSwitchButton.selected = NO;
    
    if (!sender.selected) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordButton.alpha = sender.selected;
            self.inputTextView.alpha = !sender.selected;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordButton.alpha = !sender.selected;
            self.inputTextView.alpha = sender.selected;
        } completion:^(BOOL finished) {
            
        }];
    }
    
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

#pragma mark - Public
- (void)resetTextViewHeightBy:(CGFloat)textViewHeightShouldChangeValue {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + textViewHeightShouldChangeValue);
}

// 让textView获取焦点
- (void)textViewBecomeFirstResponder {
    [self.inputTextView becomeFirstResponder];
}

// 让textView失去焦点
- (void)textViewResignFirstResponder {
    [self.inputTextView resignFirstResponder];
}

// 获取textView的内容文本
- (NSString *)textViewInputText {
    return [self.inputTextView text];
}

// 给textView插入表情
- (void)insertEmotion:(NSString *)emotionKey {
    NSMutableAttributedString *content = self.inputTextView.attributedText.mutableCopy;
    // 获得光标所在的位置
    int location = (int)self.inputTextView.selectedRange.location;
    [content insertAttributedString:[[NSAttributedString alloc] initWithString:emotionKey attributes:@{NSFontAttributeName:self.inputTextView.font,NSForegroundColorAttributeName:self.inputTextView.textColor}] atIndex:location];
    // 将调整后的字符串添加到UITextView上面
    self.inputTextView.attributedText = content;
    //重新设置光标位置
    NSRange range;
    range.location = location + emotionKey.length;
    range.length = 0;
    self.inputTextView.selectedRange = range;
}

// textView删除表情
// @return YES 表示刚才成功删除了一个表情；
// @return NO 表示刚才没删掉表情（于是本类就什么都不操作，由外部vc实现删除操作。这样做因为vc的自定义tv可能要实现文字块删除，比如 @人名）
- (BOOL)deleteEmotion {
    //点的是删除按钮，获得光标所在的位置
    int location = (int)self.inputTextView.selectedRange.location;
    if(location == 0){
        return NO;
    }
    // 先获取前半段
    NSString *headresult = [self.inputTextView.text substringToIndex:location];

    if ([headresult hasSuffix:@"]"]) {
        //最后一位是]
        for (int i = (int)[headresult length]; i>=0 ; i--) {
            //往前找，找到"["
            char tempString = [headresult characterAtIndex:(i-1)];
            if (tempString == '[') {
                NSMutableAttributedString *content = self.inputTextView.attributedText.mutableCopy;
                //砍掉[XXX]，重新赋值前半段
                [content deleteCharactersInRange:NSMakeRange(i - 1,location - i + 1)];
                self.inputTextView.attributedText = content;
                //重新设置光标位置
                NSRange range;
                range.location = [headresult length];
                range.length = 0;
                self.inputTextView.selectedRange = range;
                return YES;
            }
        }
    }
    return NO;
}


#pragma mark - Private
/**
 *  获取某个UITextView对象的content高度
 *  @return 返回高度
 */
- (CGFloat)getTextViewContentHeight
{
    return ceilf([_inputTextView sizeThatFits:_inputTextView.frame.size].height);
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputBarView:inputTextViewShouldBeginEditing:)]) {
        [self.delegate inputBarView:self inputTextViewShouldBeginEditing:self.inputTextView];
    }
    self.emotionSwitchButton.selected = NO;
    self.voiceSwitchButton.selected = NO;
    self.extendSwitchButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentHeight];
    if ([self.delegate respondsToSelector:@selector(inputBarView:inputTextViewDidBeginEditing:)]) {
        [self.delegate inputBarView:self inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.keyboardSendEnabled && [text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(inputBarView:onKeyboardSendClick:)]) {
            [self.delegate inputBarView:self onKeyboardSendClick:textView.text];
        }
        return NO;
    }
    return YES;
}


#pragma mark - Key-value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        //当输入的文本发生<折行>的时候会进入这里，这是ios系统判断的折行，<折行>包括新增文本导致的折行，也包括删除文本
        
        UITextView *textView = (UITextView *)object;
        CGFloat newContentHeight = [self getTextViewContentHeight];
        
        //true表示tv行数减少了
        BOOL heightShouldShrink = newContentHeight < self.previousTextViewContentHeight;
        
        //由于内容的输入，tv应该发生高度的变化，这个值就是应该tv改变的高度差
        CGFloat textViewHeightShouldChangeValue = newContentHeight - _previousTextViewContentHeight;
        
        //要根据max和minheight重新计算一下高度变化差
        if (!heightShouldShrink && (self.previousTextViewContentHeight == UIInputTextViewMaxHeight || textView.text.length == 0)) {
            textViewHeightShouldChangeValue = 0;
        } else {
            textViewHeightShouldChangeValue = MIN(textViewHeightShouldChangeValue, UIInputTextViewMaxHeight - self.previousTextViewContentHeight);
        }
        
        if (textViewHeightShouldChangeValue != 0.0f) {
            //textView的高度有所改变
            __weak QInputBarView *weakSelf = self;
            [UIView animateWithDuration:0.25f animations:^{
                
                if (heightShouldShrink) {
                    // 如果需要缩放, 先改变tv的高度，再修改bar的高度
                    [weakSelf resetTextViewHeightBy:textViewHeightShouldChangeValue];
                }
                
                //设置本bar的frame，其实这一步按道理可以放到更上一层的
                CGRect inputViewFrame = weakSelf.frame;
                weakSelf.frame = CGRectMake(inputViewFrame.origin.x,
                                            inputViewFrame.origin.y - textViewHeightShouldChangeValue,
                                            inputViewFrame.size.width,
                                            inputViewFrame.size.height + textViewHeightShouldChangeValue);
                
                if (!heightShouldShrink) {
                    //这句代码，不可以跟上面的合并
                    [weakSelf resetTextViewHeightBy:textViewHeightShouldChangeValue];
                }
                
                //回调给QKeyboardManager
                if ([self.delegate respondsToSelector:@selector(inputBarView:inputTextView:heightDidChange:)]) {
                    [self.delegate inputBarView:self inputTextView:self.inputView heightDidChange:textViewHeightShouldChangeValue];
                }
            }
                             completion:^(BOOL finished) {
            }];
            
            self.previousTextViewContentHeight = MIN(newContentHeight, UIInputTextViewMaxHeight);
        }
        
        // 达到最大高度的时候（无论textView的高度是否有所改变），要更新tv的ContentOffset，让他滚起来
        if (self.previousTextViewContentHeight == UIInputTextViewMaxHeight) {
            double delayInSeconds = 0.01;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime,
                           dispatch_get_main_queue(),
                           ^(void) {
                               CGPoint bottomOffset = CGPointMake(0.0f, newContentHeight - textView.bounds.size.height);
                               [textView setContentOffset:bottomOffset animated:YES];
                           });
        }
    }
}


- (void)dealloc {
    _inputedText = nil;
    [_inputTextView removeObserver:self forKeyPath:@"contentSize"];
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceSwitchButton = nil;
    _extendSwitchButton = nil;
    _emotionSwitchButton = nil;
    _recordButton = nil;
}


@end
