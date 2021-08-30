//
//  SubmitViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "SubmitViewController.h"
#import "SubmitToolBarView.h"
#import "FaceManager.h"
#import "QEmotionBoardView.h"
#import "QHolderTextView.h"

@interface SubmitViewController ()<InputBoardDataSource ,InputBoardDelegate ,UITextViewDelegate , QEmotionBoardViewDelegate ,SubmitToolBarViewDelegate>
{
    SubmitToolBarView *_inputView;
    QHolderTextView *_holderTextView;
}
@end

@implementation SubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"发布朋友圈界面";
    self.view.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
    
    _holderTextView = [[QHolderTextView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.translucent ? (UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height) : 0, self.view.frame.size.width, 150)];
    _holderTextView.backgroundColor = [UIColor whiteColor];
    _holderTextView.placeHoldString = @"说点什么吧...";
    _holderTextView.placeHoldTextColor = [UIColor grayColor];
    _holderTextView.delegate = self;
    [self.view addSubview:_holderTextView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"隐藏键盘" style:UIBarButtonItemStylePlain target:self action:@selector(onHideButtonSelect:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 初始化输入工具条，等addBottomInputBarView方法中会重置输入条frame
    _inputView = [[SubmitToolBarView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,56)];
    _inputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    _keyboardManager.delegate = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate
    [_keyboardManager addBottomInputBarView:_inputView belowViewController:YES];

    
    //把输入工具条中的输入框（如果有的话）绑定给管理类
    [_keyboardManager bindTextView:_holderTextView];
}

- (IBAction)onHideButtonSelect:(UIButton *)sender {
    [_keyboardManager hideAllBoardView];
}

#pragma mark - InputBoardDataSource
//@return 点加号按钮弹出的拓展面板View，且无需设置frame
- (UIView *)keyboardManagerExtendBoardView:(QKeyboardManager *)keyboardManager {
    UIView *boardView = [UIView new];
    boardView.backgroundColor = UIColor.blueColor;
    return boardView;
}

//@return 点表情按钮弹出的表情面板View，且无需设置frame
- (UIView *)keyboardManagerEmotionBoardView:(QKeyboardManager *)keyboardManager {
    QEmotionBoardView *emotionView = [[QEmotionBoardView alloc] init];
    FaceManager *faceManager = FACEMANAGER;
    emotionView.emotions = faceManager.emotionArray;
    emotionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        emotionView.backgroundColor = [UIColor colorNamed:@"q_input_extend_bg" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        emotionView.backgroundColor = [UIColor colorWithRed:(246)/255.0f green:(246)/255.0f blue:(246)/255.0f alpha:1];
    }
    return emotionView;
}

//@return 点表情按钮弹出的表情面板View的高度
- (CGFloat)keyboardManagerEmotionBoardHeight:(QKeyboardManager *)keyboardManager {
    return 294;
}

//@return 点加号按钮弹出的拓展面板View的高度
- (CGFloat)keyboardManagerExtendBoardHeight:(QKeyboardManager *)keyboardManager {
    return 174;
}

#pragma mark - InputBoardDelegate
//整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘）
//Warning：这个回调方法的触发已经在animate中了，无需再在本方法里写animate
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    
}

#pragma mark - QEmotionBoardViewDelegate
/**
 *  选中表情时的回调
 *  @param  index   被选中的表情在`emotions`里的索引
 *  @param  emotion 被选中的表情对应的`QMUIEmotion`对象
 */
- (void)emotionView:(QEmotionBoardView *)emotionView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index {
//    [_holderTextView insertEmotion:emotion.displayName isDelete:NO];
}

// 删除按钮的点击事件回调
- (void)emotionViewDidSelectDeleteButton:(QEmotionBoardView *)emotionView {
//    [_holderTextView insertEmotion:nil isDelete:YES];
}

// 发送按钮的点击事件回调
- (void)emotionViewDidSelectSendButton:(QEmotionBoardView *)emotionView {

}


#pragma mark - SubmitToolBarViewDelegate

//点击了系统键盘的发送按钮
- (void)inputBarView:(SubmitToolBarView *)inputBarView onKeyboardSendClick:(NSString *)inputText {

}

//点击+按钮
- (void)inputBarView:(SubmitToolBarView *)inputBarView onExtendButtonClick:(UIButton *)extendSwitchButton {
    [_keyboardManager switchToExtendBoardKeyboard];
}

//点击表情按钮，切换到表情面板
- (void)inputBarView:(SubmitToolBarView *)inputBarView onEmotionButtonClick:(UIButton *)emotionSwitchButton {
    if (emotionSwitchButton.isSelected) {
        [_keyboardManager switchToEmotionBoardKeyboard];
    } else {
        [_holderTextView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    _inputView.emotionSwitchButton.selected = NO;
    _inputView.extendSwitchButton.selected = NO;
    
    [_keyboardManager inputTextViewShouldBeginEditing];
    return YES;
}

- (void)dealloc {
    NSLog(@"VC dealloc");
}

@end
