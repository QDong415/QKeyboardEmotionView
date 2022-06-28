//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "SendButtonViewController.h"

#import "QEmotionHelper.h"
#import "QEmotionBoardView.h"

#import "QTestLabel.h"

@interface SendButtonViewController ()<InputBoardDataSource ,InputBoardDelegate , QEmotionBoardViewDelegate ,QInputBarViewDelegate>
{
    QTestLabel *_debugLeftBottomView;
}

//iPhoneX底部距离
@property (nonatomic, assign) float safeAreaInsetsBottom;

@end

@implementation SendButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"有发送按钮VC";
    self.view.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"隐藏键盘" style:UIBarButtonItemStylePlain target:self action:@selector(onHideButtonSelect:)];
    self.navigationItem.rightBarButtonItem = rightButton;
        
    //设置右下角“发送”按钮
    QInputBarViewConfiguration *config = [QInputBarViewConfiguration defaultInputBarViewConfiguration];
    
    //frame的xy传0就行，宽高你设置为自己的
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 36)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor blueColor]];
    [sendButton addTarget:self action:@selector(onSendButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    config.rightSendButton = sendButton;
    
    // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView方法会重置输入条frame
    // 如果你想要自定义输入条View，请参考TextFieldViewController代码
    _inputBarView = [[QInputBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, UIInputBarViewMinHeight)];
    [_inputBarView setupWithConfiguration:config];
    _inputBarView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate
    _keyboardManager.delegate = self;
    //将输入条View添加到ViewController；YES表示输入条平时不显示（比如朋友圈）；NO表示平时也显示（比如聊天）
    [_keyboardManager addBottomInputBarView:_inputBarView belowViewController:[self belowViewController]];
    
    //把输入框（如果有的话）绑定给管理类
    [_keyboardManager bindTextView:_inputBarView.inputTextView];
    
    //添加一个演示View
    _debugLeftBottomView = [[QTestLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    _debugLeftBottomView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_debugLeftBottomView];
    
}

#pragma mark - IBAction
- (IBAction)onHideButtonSelect:(UIButton *)sender {
    [_keyboardManager hideAllBoardView];
}

//点击了“发送”按钮
- (IBAction)onSendButtonSelect:(UIButton *)sender {
    //清空文本
    self.inputBarView.inputTextView.text = nil;
    //隐藏键盘
    [_keyboardManager hideAllBoardView];
    //发送给服务器
    [self sendTextMessage:[_inputBarView textViewInputNormalText]];
}

- (BOOL)belowViewController {
    //输入条平时是否在vc下面（NO=平时也显示，YES=平时不显示），子类可以重写
    return NO;
}

- (void)initBodyView {
    //布局vc的控件，子类可以重写
}

- (void)sendTextMessage:(NSString *)inputText {
    //发送事件，子类可以重写
    NSLog(@"%@",inputText);
}

- (CGFloat)navigationBarHeight {
    return self.navigationController.navigationBar.translucent ? 0 : (UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
}


#pragma mark - InputBoardDataSource
//@return 点表情按钮弹出的表情面板View，且无需设置frame
- (UIView *)keyboardManagerEmotionBoardView:(QKeyboardManager *)keyboardManager {
    QEmotionBoardView *emotionView = [[QEmotionBoardView alloc] init];
    QEmotionHelper *faceManager = [QEmotionHelper sharedEmotionHelper];
    emotionView.emotions = faceManager.emotionArray;
    emotionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        NSBundle *bundle = [NSBundle bundleForClass:[QKeyboardBaseManager class]];
        emotionView.backgroundColor = [UIColor colorNamed:@"q_input_extend_bg" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        emotionView.backgroundColor = [UIColor colorWithRed:(246)/255.0f green:(246)/255.0f blue:(246)/255.0f alpha:1];
    }
    return emotionView;
}

//@return 点表情按钮弹出的表情面板View的高度
- (CGFloat)keyboardManagerEmotionBoardHeight:(QKeyboardManager *)keyboardManager {
    return 274;
}

#pragma mark - InputBoardDelegate
//整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘，但是不包含底部安全区高度）
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    
    if (@available(iOS 11.0, *)) {
        //如果是x，给底部的34pt添加上背景颜色，颜色和输入条一致
        _safeAreaInsetsBottom = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    if (reason == WholeInputViewHeightDidChangeReasonWillAddToSuperView) {
        //聊天界面，初始化array后，要滚到底部
        //我是这样实现的滚到底部的，你可以自己更改
        dispatch_async(dispatch_get_main_queue(), ^{
            _debugLeftBottomView.frame = CGRectMake(0, self.view.frame.size.height - wholeInputViewHeight - 100 + [self navigationBarHeight] - _safeAreaInsetsBottom, 200, 100);
        });
    } else {
        _debugLeftBottomView.frame = CGRectMake(0, self.view.frame.size.height - wholeInputViewHeight - 100 + [self navigationBarHeight] - _safeAreaInsetsBottom, 200, 100);
    }
}

#pragma mark - QEmotionBoardViewDelegate
/**
 *  选中表情时的回调
 *  @param  index   被选中的表情在`emotions`里的索引
 *  @param  emotion 被选中的表情对应的`QMUIEmotion`对象
 */
- (void)emotionView:(QEmotionBoardView *)emotionView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index {

    QEmotionHelper *faceManager = [QEmotionHelper sharedEmotionHelper];
    //把😊插入到输入栏
    [_inputBarView insertEmotionAttributedString:[faceManager obtainAttributedStringByImageKey:emotion.displayName font:_inputBarView.inputTextView.font useCache:NO]];
}

// 删除按钮的点击事件回调
- (void)emotionViewDidSelectDeleteButton:(QEmotionBoardView *)emotionView {
    if (![_inputBarView deleteEmotion]){
        //根据当前的光标，这次点击删除按钮并没有删除表情，那么就删除文字
        [_inputBarView.inputTextView deleteBackward];
    }
}

// 发送按钮的点击事件回调
- (void)emotionViewDidSelectSendButton:(QEmotionBoardView *)emotionView {
    [self sendTextMessage:[_inputBarView textViewInputNormalText]];
}

#pragma mark - QInputBarViewDelegate
// 输入框的高度发生了改变（因为输入了内容），注意这里仅仅是TextView输入框的高度发生了变化的回调
- (void)inputBarView:(QInputBarView *)inputBarView inputTextView:(UITextView *)inputTextView heightDidChange:(CGFloat)changeValue becauseSendText:(BOOL)becauseSendText {
    //这里要告知Manager类
    [_keyboardManager inputTextViewHeightDidChange:becauseSendText];
}

//点击了系统键盘的发送按钮
- (void)inputBarView:(QInputBarView *)inputBarView onKeyboardSendClick:(NSString *)inputNormalText {
    [self sendTextMessage:inputNormalText];
}

//点击+按钮
- (void)inputBarView:(QInputBarView *)inputBarView onExtendButtonClick:(UIButton *)extendSwitchButton {
    [_keyboardManager switchToExtendBoardKeyboard];
}

//点击表情按钮，切换到表情面板
- (void)inputBarView:(QInputBarView *)inputBarView onEmotionButtonClick:(UIButton *)emotionSwitchButton {
    if (emotionSwitchButton.isSelected) {
        [_keyboardManager switchToEmotionBoardKeyboard];
    } else {
        [_inputBarView textViewBecomeFirstResponder];
    }
}

@end
