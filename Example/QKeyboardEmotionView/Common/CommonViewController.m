//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "CommonViewController.h"

#import "FaceManager.h"
#import "QEmotionBoardView.h"
#import "QExtendBoardView.h"

@interface CommonViewController ()<InputBoardDataSource ,InputBoardDelegate , QEmotionBoardViewDelegate ,QInputBarViewDelegate ,QExtendBoardViewDelegate>
{

}
@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"通用的VC";
    self.view.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"隐藏键盘" style:UIBarButtonItemStylePlain target:self action:@selector(onHideButtonSelect:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self initBodyView];
    
    // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView方法会重置输入条frame
    // 如果你想要自定义输入条View，请参考TextFieldViewController代码
    _inputView = [[QInputBarView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,UIInputBarViewMinHeight)];
    [_inputView setupWithConfiguration:[self inputBarViewConfiguration]];
    _inputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate
    _keyboardManager.delegate = self;
    //将输入条View添加到ViewController；YES表示输入条平时不显示（比如朋友圈）；NO表示平时也显示（比如聊天）
    [_keyboardManager addBottomInputBarView:_inputView belowViewController:[self belowViewController]];
    
    //把输入框（如果有的话）绑定给管理类
    [_keyboardManager bindTextView:_inputView.inputTextView];
}

#pragma mark - IBAction
- (IBAction)onHideButtonSelect:(UIButton *)sender {
    [_keyboardManager hideAllBoardView];
}

#pragma mark - NeedOverride
- (QInputBarViewConfiguration *)inputBarViewConfiguration {
    //输入条配置，子类可以重写
    return [QInputBarViewConfiguration defaultInputBarViewConfiguration];
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
}


#pragma mark - InputBoardDataSource
//@return 点加号按钮弹出的拓展面板View，且无需设置frame
- (UIView *)keyboardManagerExtendBoardView:(QKeyboardManager *)keyboardManager {
    QExtendBoardView *boardView = [[QExtendBoardView alloc] init];
    boardView.delegate = self;
    if (@available(iOS 11.0, *)) {
        NSBundle *bundle = [NSBundle bundleForClass:[QKeyboardBaseManager class]];
        boardView.backgroundColor = [UIColor colorNamed:@"q_input_extend_bg" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        boardView.backgroundColor = [UIColor colorWithRed:(246)/255.0f green:(246)/255.0f blue:(246)/255.0f alpha:1];
    }
    
    QExtendBoardItemModel *photoItem = [[QExtendBoardItemModel alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_pic"] title:@"图片"];
    
    QExtendBoardItemModel *audioItem = [[QExtendBoardItemModel alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_groupluckybag"] title:@"红包"];
    
    QExtendBoardItemModel *videoItem = [[QExtendBoardItemModel alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_poi"] title:@"位置"];
    
    boardView.extendBoardItems = @[photoItem, audioItem, videoItem];
    return boardView;
}

//@return 点表情按钮弹出的表情面板View，且无需设置frame
- (UIView *)keyboardManagerEmotionBoardView:(QKeyboardManager *)keyboardManager {
    QEmotionBoardView *emotionView = [[QEmotionBoardView alloc] init];
    FaceManager *faceManager = FACEMANAGER;
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

//@return 点加号按钮弹出的拓展面板View的高度
- (CGFloat)keyboardManagerExtendBoardHeight:(QKeyboardManager *)keyboardManager {
    return 174;
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
