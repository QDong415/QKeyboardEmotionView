//
//  QInputBarView.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

//整个Bar的最小高度（即文字只有1行时候的整条Bar的高度）
const int UIInputBarViewMinHeight = 58;

//Bar里面的UITextView的最小高度（即文字只有1行时候的UITextView高度）
const int UIInputTextViewMinHeight = 42;

//Bar里面的UITextView的最大高度（即文字有超多行时候的高度）
const int UIInputTextViewMaxHeight = 147;

// 最左最右的距离屏幕边缘距离
const int UIHorizontalPadding = 6;

// 两个item之间的水平间隔
const int UIItemHorizontalSpace = 6;

#import "QInputBarView.h"
#import "UITextView+QEmotion.h"

//默认的输入bar，包含了：左侧的语音切换按钮，中间的textview和按住录音按钮，右侧的表情和拓展按钮，（总之，仿微信的输入条）
//上述按钮都可以设置隐藏，如果还是无法满足你的需求，请自定义UIView，参考TextFieldViewController
@interface QInputBarView () <UITextViewDelegate>
{
}
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong, nullable) UIButton *voiceSwitchButton;
@property (nonatomic, strong, nullable) UIButton *emotionSwitchButton;
@property (nonatomic, strong, nullable) UIButton *extendSwitchButton;
@property (nonatomic, strong, nullable) UIButton *rightSendButton;
@property (nonatomic, strong, nullable) UIButton *recordButton; //按住不松录音的长条按钮
@property (nonatomic, strong, nullable) UIView *replyView; //回复View

///  输入栏TextView的高度发生变化的动画时长（秒）
@property (nonatomic, assign) NSTimeInterval inputBarHeightChangeAnimationDuration; // default is 0.2

///  点击“发送”按钮时候会清空输入栏，进而导致TextView的高度变化的动画时长（秒）
@property (nonatomic, assign) NSTimeInterval inputBarHeightChangeAnimationWhenSendDuration; //0.1

// 点击键盘右下角的按钮是否是发送，NO表示普通回车换行，YES表示回调Delegate的Send方法
@property (nonatomic, assign) BOOL keyboardSendEnabled; // default is YES

//在切换语音和文本消息的时候，需要保存原本已经输入的文本
@property (nonatomic, strong) NSString *inputedText;

//记录旧的textView Heigth
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;

//刚才清空文本框是因为点击了”发送“按钮。加入这个全局变量是为了Delegate的heightDidChange方法可以回调特殊的返回值
@property (nonatomic, assign) BOOL clearInputTextBySendSoon;

@property (nonatomic, assign) CGFloat verticalPadding; // 垂直间隔

@end

@implementation QInputBarView

#pragma mark - Init
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupWithConfiguration:(QInputBarViewConfiguration *)configuration
{
    self.keyboardSendEnabled = configuration.keyboardSendEnabled;
    
    const int UISwitchButtonWidth = 40; // 3个按钮固定宽高
//    const int horizontalPadding = UIHorizontalPadding; // 水平间隔
    const CGFloat verticalPadding = (UIInputBarViewMinHeight - UISwitchButtonWidth )/2;// 垂直间隔
    self.verticalPadding = verticalPadding;
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
        buttonFrame.origin = CGPointMake(UIHorizontalPadding + safeAreaInsetsLeft, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        self.voiceSwitchButton = button;
        textViewFrameX = CGRectGetMaxX(button.frame);
    } else {
        //如果没有左边的语音按钮，输入条太贴左边了，+8提高一些marginLeft，这个8和textViewHorizontalMargin同时存在
        textViewFrameX = safeAreaInsetsLeft + 8;
    }
    
    //是否显示最右侧按钮（最右侧按钮可能是+，也可能是“发送”）
    BOOL rightButtonShowed = NO;
    
    //右边是发送按钮
    if (configuration.rightSendButton) {
        UIButton *button = configuration.rightSendButton;
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - UIHorizontalPadding - CGRectGetWidth(buttonFrame) - safeAreaInsetsRight, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        rightViewsMinX = CGRectGetMinX(buttonFrame);
        self.rightSendButton = button;
        rightButtonShowed = YES;
    }
    
    if (!configuration.extendButtonHidden) {
        // 允许发送多媒体消息。为什么不是先放表情按钮呢？因为布局的需要
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UISwitchButtonWidth, UISwitchButtonWidth)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"q_chat_extend_black_normal" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onExtendSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - UIHorizontalPadding - CGRectGetWidth(buttonFrame) - safeAreaInsetsRight, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        rightViewsMinX = CGRectGetMinX(buttonFrame);
        self.extendSwitchButton = button;
        rightButtonShowed = YES;
        
        _rightSendButton.hidden = YES;
    }
    
    if (rightViewsMinX == 0) {
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
        if (rightButtonShowed) {
            buttonFrame.origin = CGPointMake(rightViewsMinX - CGRectGetWidth(buttonFrame) - UIItemHorizontalSpace, verticalPadding);
        } else {
            buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - UIHorizontalPadding - CGRectGetWidth(buttonFrame) - safeAreaInsetsRight, verticalPadding);
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
    UITextView *textView = configuration.customTextView;
    
    if (!textView){
        //vc没有提供UITextView，我们自己来实现
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.font = [UIFont systemFontOfSize:17.5];
        textView.returnKeyType = UIReturnKeySend;
        textView.scrollsToTop = NO;
        textView.textAlignment = NSTextAlignmentLeft;
        textView.layer.cornerRadius = 6.0f;
        //top, left, bottom, right
        textView.textContainerInset = UIEdgeInsetsMake(10.0f, 8.0f, 10.0f, 8.0f);
        //如果我设置了left边距，换行的时候，xcode会弹出提示：requesting caretRectForPosition: while the NSTextStorage has oustanding changes . 但是实际运行没任何影响
        //如果把left（第2、4个参数）设置为0，就不会有警告。原因不明
        
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
        [button setTitle:configuration.speakButtonTitle?:@"按住说话" forState:UIControlStateNormal];
        button.alpha = self.voiceSwitchButton.selected;
        [self addSubview:button];
        self.recordButton = button;
    }
    
    //各种颜色
    self.backgroundColor = configuration.inputBarBackgroundColor;
    _inputTextView.textColor = configuration.textColor;
    _inputTextView.backgroundColor = configuration.textViewBackgroundColor;
    [self.recordButton setTitleColor:configuration.recordButtonTitleColor forState:UIControlStateNormal];

    //两个动画时长
    self.inputBarHeightChangeAnimationDuration = configuration.inputBarHeightChangeAnimationDuration == 0 ? 0.2 : configuration.inputBarHeightChangeAnimationDuration;
    self.inputBarHeightChangeAnimationWhenSendDuration = 0.1;
    
    //输入条的上方添加一行细线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1 / [UIScreen mainScreen].scale)];
    topLineView.backgroundColor = configuration.inputBarBoardColor;
    [self addSubview:topLineView];
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
        self.inputTextView.text = nil;
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

// 右边“+”切换按钮点击
- (IBAction)onExtendSwitchButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.emotionSwitchButton.selected = NO;
    
    if (self.voiceSwitchButton.selected) {
        //当前是按住说话的状态，需要切回输入框
        self.voiceSwitchButton.selected = NO;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordButton.alpha = !sender.selected;
            self.inputTextView.alpha = sender.selected;
        } completion:^(BOOL finished) {
            
        }];
    }

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
- (NSString *)textViewInputNormalText {
    return [self.inputTextView normalText];
}

// 给textView插入表情图片，比如😊
- (void)insertEmotionAttributedString:(NSAttributedString *)emotionAttributedString {
    [self.inputTextView insertEmotionAttributedString: emotionAttributedString];
}

// 给textView插入表情的文本，比如[微笑]
- (void)insertEmotion:(NSString *)emotionKey {
    [self.inputTextView insertEmotion: emotionKey];
}

// textView删除表情
// @return YES 表示刚才成功删除了一个表情；
// @return NO 表示刚才没删掉表情（于是本类就什么都不操作，由外部vc实现删除操作。这样做因为vc的自定义tv可能要实现文字块删除，比如 @人名）
- (BOOL)deleteEmotion {
    //点的是删除按钮，获得光标所在的位置
    return [self.inputTextView deleteEmotion];
}

// 清除输入的文本。不建议你自己用inputTextView.text = nil来情况文本。因为那样的话如果输入栏的文字>1行，你调用tableView.reload再scrollToBottom会出现tableView滚动不流畅
//之所以不流畅是因为tableView的scrollToBottom动画和onWholeInputViewHeightDidChange里的动画同时被调用
- (NSTimeInterval)clearInputTextBySend {
    
    //YES:当前inputText只有一行；NO：大于一行
    BOOL currentIsOneLine = self.inputTextView.frame.size.height == UIInputTextViewMinHeight;
    
    //临时改成yes，等回调了delegate要立刻设NO
    self.clearInputTextBySendSoon = YES;
    
    //清空输入栏，如果当前输入栏里的文字行数>1会立即触发KVO
    self.inputTextView.text = nil;
    
    //等走完KVO和KVO里的的delegate，再关掉
    self.clearInputTextBySendSoon = NO;
    
    //@return YES：当前inputText只有一行；NO：大于一行
    return currentIsOneLine ? 0 : _inputBarHeightChangeAnimationWhenSendDuration;
}

//在输入框的上方显示“回复View”请提前设置好frame
- (void)showReplyView:(UIView *)replyView marginTop:(CGFloat)marginTop marginBottom:(CGFloat)marginBottom {
    CGFloat beforeReplyViewTotalHeight = 0; //现在的replyView的总高度（加上marginTopBottom）
    if (self.replyView) {
        CGFloat inputViewShouldOriginY = (UIInputBarViewMinHeight - UIInputTextViewMinHeight)/2;
        beforeReplyViewTotalHeight = _inputTextView.frame.origin.y - inputViewShouldOriginY;
        [self.replyView removeFromSuperview];
    }
    replyView.frame = CGRectMake(UIHorizontalPadding, marginTop, self.frame.size.width - UIHorizontalPadding - UIHorizontalPadding, replyView.frame.size.height);
    self.replyView = replyView;
    [self addSubview:replyView];
    
    CGFloat replyViewTotalHeight = CGRectGetMaxY(replyView.frame) + marginBottom;
    if (replyViewTotalHeight == beforeReplyViewTotalHeight) {
        return; //跟之前的ReplyView高度一样
    }
    
    [UIView animateWithDuration:_inputBarHeightChangeAnimationDuration animations:^{
        
        CGFloat itemsOriginY = replyViewTotalHeight + self.verticalPadding;
        [self originYMoveTo:itemsOriginY view:self.voiceSwitchButton];
        [self originYMoveTo:itemsOriginY view:self.emotionSwitchButton];
        [self originYMoveTo:itemsOriginY view:self.extendSwitchButton];
        [self originYMoveTo:itemsOriginY view:self.rightSendButton];
        [self originYMoveTo:(UIInputBarViewMinHeight - UIInputTextViewMinHeight)/2 + replyViewTotalHeight view:self.inputTextView];
        
        CGFloat replyViewTotalHeightDiff = replyViewTotalHeight - beforeReplyViewTotalHeight;
        
        CGRect inputViewFrame = self.frame;
        self.frame = CGRectMake(inputViewFrame.origin.x,
                                    inputViewFrame.origin.y - replyViewTotalHeightDiff,
                                    inputViewFrame.size.width,
                                    inputViewFrame.size.height + replyViewTotalHeightDiff);
        
        //回调给QKeyboardManager
        if ([self.delegate respondsToSelector:@selector(inputBarView:heightDidChangeBecauseReply:showReplyView:)]) {
            [self.delegate inputBarView:self heightDidChangeBecauseReply:replyViewTotalHeightDiff showReplyView:YES];
        }

    } completion:^(BOOL finished) {
    }];
}

- (void)hideReplyView {
    if (self.replyView) {
        [self.replyView removeFromSuperview];
        self.replyView = nil;
        
        CGFloat inputViewShouldOriginY = (UIInputBarViewMinHeight - UIInputTextViewMinHeight)/2;
        CGFloat replyViewTotalHeight = _inputTextView.frame.origin.y - inputViewShouldOriginY;

        [UIView animateWithDuration:_inputBarHeightChangeAnimationDuration animations:^{
            
            CGFloat itemsOriginY = self.verticalPadding;
            [self originYMoveTo:itemsOriginY view:self.voiceSwitchButton];
            [self originYMoveTo:itemsOriginY view:self.emotionSwitchButton];
            [self originYMoveTo:itemsOriginY view:self.extendSwitchButton];
            [self originYMoveTo:itemsOriginY view:self.rightSendButton];
            [self originYMoveTo:inputViewShouldOriginY view:self.inputTextView];
            
            CGRect inputViewFrame = self.frame;
            self.frame = CGRectMake(inputViewFrame.origin.x,
                                        inputViewFrame.origin.y + replyViewTotalHeight,
                                        inputViewFrame.size.width,
                                        inputViewFrame.size.height - replyViewTotalHeight);
            
            
            //回调给QKeyboardManager
            if ([self.delegate respondsToSelector:@selector(inputBarView:heightDidChangeBecauseReply:showReplyView:)]) {
                [self.delegate inputBarView:self heightDidChangeBecauseReply:-replyViewTotalHeight showReplyView:YES];
            }
        } completion:^(BOOL finished) {
        }];
    }
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

- (void)originYMoveTo:(CGFloat)moveToY view:(UIView *)view {
    if (view) {
        view.frame = CGRectMake(view.frame.origin.x, moveToY, view.frame.size.width, view.frame.size.height);
    }
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

- (void)textViewDidChange:(UITextView *)textView {
    if (_rightSendButton && _extendSwitchButton) {
        //同时包含 “+” 和 “发送”按钮
        BOOL isEmpty = [textView.text length] == 0;
        _rightSendButton.hidden = isEmpty;
        _extendSwitchButton.hidden = !isEmpty;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarView:textViewDidChange:)]) {
        [self.delegate inputBarView:self textViewDidChange:self.inputTextView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.keyboardSendEnabled && [text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(inputBarView:onKeyboardSendClick:)]) {
            [self.delegate inputBarView:self onKeyboardSendClick:[textView normalText]];
        }
        return NO;
    }
    return YES;
}

//只有在发生换行时候才会触发这里
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
            [UIView animateWithDuration:_clearInputTextBySendSoon ? _inputBarHeightChangeAnimationWhenSendDuration : _inputBarHeightChangeAnimationDuration animations:^{
                
                if (heightShouldShrink) {
                    // 如果需要缩放, 先改变tv的高度，再修改bar的高度
                    [weakSelf resetTextViewHeightBy:textViewHeightShouldChangeValue];
                }
                
                //设置本bar的frame
                CGRect inputViewFrame = weakSelf.frame;
                weakSelf.frame = CGRectMake(inputViewFrame.origin.x,
                                            inputViewFrame.origin.y - textViewHeightShouldChangeValue,
                                            inputViewFrame.size.width,
                                            inputViewFrame.size.height + textViewHeightShouldChangeValue);
                
                if (!heightShouldShrink) {
                    //为了兼容低版本ios系统，所以这句代码，不可以跟上面的合并
                    [weakSelf resetTextViewHeightBy:textViewHeightShouldChangeValue];
                }
                
                //回调给QKeyboardManager
                if ([self.delegate respondsToSelector:@selector(inputBarView:inputTextView:heightDidChange:becauseSendText:)]) {
                    [self.delegate inputBarView:self inputTextView:self.inputView heightDidChange:textViewHeightShouldChangeValue becauseSendText:self.clearInputTextBySendSoon];
                }

            } completion:^(BOOL finished) {
            }];
            
            self.previousTextViewContentHeight = MIN(newContentHeight, UIInputTextViewMaxHeight);
        }
        
        //这一句可以不写，为了保险还是写了
        self.clearInputTextBySendSoon = NO;
        
        // 达到最大高度的时候（无论textView的高度是否有所改变），要更新tv的ContentOffset，让他滚起来
        if (self.previousTextViewContentHeight == UIInputTextViewMaxHeight) {
            double delayInSeconds = 0.01;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(),
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
