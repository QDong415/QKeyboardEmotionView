//
//  SubmitViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//

#import "TextFieldViewController.h"
#import "CustomBarView.h"
#import "FaceManager.h"
#import "QKeyboardManager.h"
#import "QEmotionBoardView.h"
#import "QHolderTextView.h"

@interface TextFieldViewController ()<InputBoardDataSource , QEmotionBoardViewDelegate,CustomBarViewDelegate ,UITextFieldDelegate>
{
    CustomBarView *_inputView;
    QHolderTextView *_holderTextView;
}

@property(nonatomic,strong)IBOutlet UITextField *textField;
@property(nonatomic,strong)QKeyboardManager *keyboardManager;
@end

@implementation TextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"弹框界面";
    self.view.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
   
    _textField.delegate = self;
    
    // 初始化输入工具条，等addBottomInputBarView代码中会重置输入条frame
    _inputView = [[CustomBarView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,56)];
    _inputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    [_keyboardManager addBottomInputBarView:_inputView belowViewController:YES];
    
    [_keyboardManager bindTextView:_textField];
}

- (IBAction)onHideButtonSelect:(UIButton *)sender {
    [_keyboardManager hideAllBoardView];
}

#pragma mark - InputBoardDataSource
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


#pragma mark - InputBoardDelegate
//整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘）
//Warning：这个回调方法的触发已经在animate中了，无需再在本方法里写animate
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    
}

#pragma mark - QUIEmotionViewDelegate
/**
 *  选中表情时的回调
 *  @param  index   被选中的表情在`emotions`里的索引
 *  @param  emotion 被选中的表情对应的`QMUIEmotion`对象
 */
- (void)emotionView:(QEmotionBoardView *)emotionView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index {
    [_textField insertText:emotion.displayName];
}

// 删除按钮的点击事件回调
- (void)emotionViewDidSelectDeleteButton:(QEmotionBoardView *)emotionView {

}

// 发送按钮的点击事件回调
- (void)emotionViewDidSelectSendButton:(QEmotionBoardView *)emotionView {

}

#pragma mark - CustomBarViewDelegate
//点击了系统键盘的发送按钮
- (void)inputBarView:(CustomBarView *)inputBarView onKeyboardSendClick:(NSString *)inputText {

}

//点击表情按钮，切换到表情面板
- (void)inputBarView:(CustomBarView *)inputBarView onEmotionButtonClick:(UIButton *)emotionSwitchButton {
    if (emotionSwitchButton.isSelected) {
        [_keyboardManager switchToEmotionBoardKeyboard];
    } else {
        [_textField becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textView {
    _inputView.emotionSwitchButton.selected = NO;
    [_keyboardManager inputTextViewShouldBeginEditing];
    return YES;
}


- (void)dealloc {
    NSLog(@"VC dealloc");
}


@end
