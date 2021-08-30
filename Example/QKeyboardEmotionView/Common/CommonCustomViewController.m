//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "CommonCustomViewController.h"

#import "QKeyboardManager.h"
#import "QInputBarView.h"
#import "QEmotionBoardView.h"
#import "QExtendBoardView.h"
#import "QHolderTextView.h"

@interface CommonCustomViewController ()<InputBoardDataSource ,InputBoardDelegate , QEmotionBoardViewDelegate ,QInputBarViewDelegate ,QExtendBoardViewDelegate, QInputBarViewDataSource>
{

}

@property(nonatomic,strong)QKeyboardManager *keyboardManager;

@property(nonatomic,strong)QInputBarView *inputView;

@end

@implementation CommonCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自定义的VC";
    self.view.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
    
    [self initBodyView];
    
    // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView代码会重置输入条frame
    _inputView = [[QInputBarView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,UIInputBarViewMinHeight)];
    [_inputView setupWithConfiguration:[self inputBarViewConfiguration]];
    _inputView.dataSource = self;
    _inputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    _keyboardManager.delegate = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate
    [_keyboardManager addBottomInputBarView:_inputView belowViewController:NO];
    
    //把输入框（如果有的话）绑定给管理类
    [_keyboardManager bindTextView:_inputView.inputTextView];
}

#pragma mark - NeedOverride
- (QInputBarViewConfiguration *)inputBarViewConfiguration {
    //输入条配置，子类可以重写
    QInputBarViewConfiguration *config = [QInputBarViewConfiguration defaultInputBarViewConfiguration];
    config.voiceButtonHidden = YES;
    return config;
}

- (void)initBodyView {
    //布局vc的控件，子类可以重写
}

- (void)sendTextMessage:(NSString *)inputText {
    //发送事件，子类可以重写

}

#pragma mark - InputBoardDataSource
//@return 点加号按钮弹出的拓展面板View，且无需设置frame
- (UIView *)keyboardManagerExtendBoardView:(QKeyboardManager *)keyboardManager {
    UIView *boardView = [[UIView alloc] init];
    boardView.backgroundColor = [UIColor greenColor];
    return boardView;
}

//@return 点表情按钮弹出的表情面板View，且无需设置frame
- (UIView *)keyboardManagerEmotionBoardView:(QKeyboardManager *)keyboardManager {
    UIView *emotionView = [[UIView alloc] init];
    emotionView.backgroundColor = [UIColor systemOrangeColor];
    return emotionView;
}

//@return 点表情按钮弹出的表情面板View的高度
- (CGFloat)keyboardManagerEmotionBoardHeight:(QKeyboardManager *)keyboardManager {
    return 220;
}

//@return 点加号按钮弹出的拓展面板View的高度
- (CGFloat)keyboardManagerExtendBoardHeight:(QKeyboardManager *)keyboardManager {
    return 220;
}

#pragma mark - InputBoardDelegate
//整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘）
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    
}

#pragma mark - QEmotionBoardViewDelegate
/**
 *  选中表情时的回调
 *  @param  index   被选中的表情在`emotions`里的索引
 *  @param  emotion 被选中的表情对应的`QMUIEmotion`对象
 */
- (void)emotionView:(QEmotionBoardView *)emotionView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index {
    [_inputView insertEmotion:emotion.displayName];
}

// 删除按钮的点击事件回调
- (void)emotionViewDidSelectDeleteButton:(QEmotionBoardView *)emotionView {
    if (![_inputView deleteEmotion]){
        //根据当前的光标，这次点击删除按钮并没有删除表情，那么就删除文字
        [_inputView.inputTextView deleteBackward];
    }
}

// 发送按钮的点击事件回调
- (void)emotionViewDidSelectSendButton:(QEmotionBoardView *)emotionView {
    [self sendTextMessage:[_inputView textViewInputText]];
}

#pragma mark - QExtendBoardViewDelegate
//点击拓展面板的cell
- (void)didSelectExtendBoardItem:(QExtendBoardItemModel *)shareMenuItem atIndex:(NSInteger)index {
    
}

#pragma mark - QInputBarViewDataSource
//@return 输入条上的UITextView，返回你自定义的UITextView
- (UITextView *)textViewForInputBarView:(QInputBarView *)inputBarView {
    QHolderTextView *tv = [[QHolderTextView alloc] init];
    tv.placeHoldString = @"自定义TextView";
    return tv;
}

#pragma mark - QInputBarViewDelegate
// 输入框将要开始编辑
- (void)inputBarView:(QInputBarView *)inputBarView inputTextViewShouldBeginEditing:(UITextView *)messageInputTextView {
    //这里要告知Manager类
    [_keyboardManager inputTextViewShouldBeginEditing];
}

// 输入框的高度发生了改变（因为输入了内容），注意这里仅仅是TextView输入框的高度发送了变化的回调
- (void)inputBarView:(QInputBarView *)inputBarView inputTextView:(UITextView *)inputTextView heightDidChange:(CGFloat)changeValue {
    //这里要告知Manager类
    [_keyboardManager inputTextViewHeightDidChange];
}

//在发送文本和语音之间发送改变，voiceSwitchButton.isSelected表示切换到了语音输入模式
- (void)inputBarView:(QInputBarView *)inputBarView onVoiceSwitchButtonClick:(UIButton *)voiceSwitchButton {
    if (voiceSwitchButton.isSelected) {
        //切换到了语音输入模式
        [_keyboardManager hideAllBoardView];
    }
}

//点击了系统键盘的发送按钮
- (void)inputBarView:(QInputBarView *)inputBarView onKeyboardSendClick:(NSString *)inputText {
    [self sendTextMessage:inputText];
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
        [_inputView textViewBecomeFirstResponder];
    }
}

- (void)dealloc {
    NSLog(@"VC dealloc");
}

@end
