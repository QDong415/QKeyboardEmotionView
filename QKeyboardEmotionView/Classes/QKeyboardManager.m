//
//  QKeyboardManager.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "QKeyboardManager.h"

typedef NS_ENUM(NSUInteger, InputState) {
    InputStateNormal = 0, //默认状态，没弹出键盘 也没弹出表情 也没弹出extend面板
    InputStateText,//弹出软键盘状态
    InputStateEmotion,//弹出表情状态
    InputStateExtend,//弹出extend面板状态
};

@interface QKeyboardManager()

//true：输入条平时是不显示出来的；false：输入条一直都在vc底部
@property (nonatomic, assign) BOOL inputBarBelowViewController;

//当前的输入状态
@property (nonatomic, assign) InputState currentInputState;

//输入条，由vc传过来，一般情况下，这个输入框是inputBar的子view，但是也可能不是（比如发微博界面）
@property (nonatomic, weak, nullable) UIResponder *inputTextView;

//那一条输入框bar，由vc传过来，包含了左右的按钮
@property (nonatomic, strong, nullable) UIView *inputBarView;

@property (nonatomic, strong, nullable) UIView *emotionBoardView;

@property (nonatomic, strong, nullable) UIView *extendBoardView;

//iPhoneX底部距离
@property (nonatomic, assign) float safeAreaInsetsBottom;

//iPhoneX系列手机上，如果手指快速向上滑动tableView，那么会出现0.1秒的"可以透过inputBar和底部安全区中间看到背景tableView"。为了解决这个细小的问题，我加入了这个
@property (nonatomic, strong, nullable) UIView *belowInputBarXView;

@end

@implementation QKeyboardManager

#pragma mark - public 添加底部输入框View
- (void)addBottomInputBarView:(UIView *)inputBarView belowViewController:(BOOL)belowViewController {
    
    if (@available(iOS 11.0, *)) {
        //如果是x，给底部的34pt添加上背景颜色，颜色和输入条一致
        _safeAreaInsetsBottom = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
        if(_safeAreaInsetsBottom > 0 && !belowViewController){
            //iPhoneX 且 聊天界面VC（即输入条固定在底部）就会进入这里
            //我添加了一个和输入条背景颜色一样的普通View在inputView的底部
            _belowInputBarXView = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewController.view.frame.size.height - _safeAreaInsetsBottom , self.viewController.view.frame.size.width, _safeAreaInsetsBottom)];
            _belowInputBarXView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
            _belowInputBarXView.backgroundColor = inputBarView.backgroundColor;
            [self.viewController.view addSubview:_belowInputBarXView];
            [self.viewController.view bringSubviewToFront:_belowInputBarXView];
        }
    }
    
    //注意这里，系统会自动调整inputBarView的y和width
    inputBarView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    
    // 工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,self.viewController.view.frame.size.height + (belowViewController ? 0 : (- inputBarView.frame.size.height - self.safeAreaInsetsBottom)),
                                   self.viewController.view.frame.size.width,
                                   inputBarView.frame.size.height);
    
    // vc创建的工具条，本类负责设置frame和addSubview
    inputBarView.frame = inputFrame;

    [self.viewController.view addSubview:inputBarView];
    [self.viewController.view bringSubviewToFront:inputBarView];
    
    //因为底部添加了输入条；回调给vc，让vc处理界面的tableview的frame
    [self callBackWholeInputViewHeightDidChange:belowViewController ? 0 : inputBarView.frame.size.height reason:WholeInputViewHeightDidChangeReasonWillAddToSuperView];
    
    self.inputBarView = inputBarView;    
    self.inputBarBelowViewController = belowViewController;
}

//public - 由vc调用该方法，让本manager类拿到textView的引用
- (void)bindTextView:(UIResponder *)inputTextView {
    self.inputTextView = inputTextView;
}

#pragma mark - DataSource - 由ViewController实现表情面板view和拓展面板view
- (UIView * _Nullable)extendBoardView {
    if (!_extendBoardView) {
        if ([self.dataSource respondsToSelector:@selector(keyboardManagerExtendBoardView:)]) {
            _extendBoardView = [self.dataSource keyboardManagerExtendBoardView:self];
            CGFloat extendBoardHeight = 220;//默认高度
            if ([self.dataSource respondsToSelector:@selector(keyboardManagerExtendBoardHeight:)]) {
                extendBoardHeight = [self.dataSource keyboardManagerExtendBoardHeight:self];
            }
            _extendBoardView.frame = CGRectMake(0, CGRectGetHeight(self.viewController.view.bounds), CGRectGetWidth(self.viewController.view.bounds), extendBoardHeight);
            _extendBoardView.alpha = 0.0;
            [self.viewController.view addSubview:_extendBoardView];
            [self.viewController.view bringSubviewToFront:_extendBoardView];
        }
    }
    return _extendBoardView;
}

- (UIView * _Nullable)emotionBoardView {
    if (!_emotionBoardView) {
        if ([self.dataSource respondsToSelector:@selector(keyboardManagerEmotionBoardView:)]) {
            _emotionBoardView = [self.dataSource keyboardManagerEmotionBoardView:self];
            CGFloat emotionBoardHeight = 220;//默认高度
            if ([self.dataSource respondsToSelector:@selector(keyboardManagerEmotionBoardHeight:)]) {
                emotionBoardHeight = [self.dataSource keyboardManagerEmotionBoardHeight:self];
            }
            _emotionBoardView.frame = CGRectMake(0, CGRectGetHeight(self.viewController.view.bounds), CGRectGetWidth(self.viewController.view.bounds), emotionBoardHeight);
            _emotionBoardView.alpha = 0.0;
            [self.viewController.view addSubview:_emotionBoardView];
            [self.viewController.view bringSubviewToFront:_emotionBoardView];
        }
    }
    return _emotionBoardView;
}

#pragma mark - Override Keyboard notifications
//Private 只有通过系统的键盘广播触发到这里
- (void)onKeyboardWillShowOrHideByNotifications:(CGRect)keyboardRect animationOptions:(UIViewAnimationOptions)animationOptions duration:(double)duration showKeyboard:(BOOL)showKeyboard {
    
    if (![self.inputTextView isFirstResponder]) {
        //本次弹出软键盘并不是因为我们的输入框，而是有别的输入框
        return;
    }
    
    //马上要弹出键盘了，先看看当前的状态是哪个BoardView，一会要把它隐藏掉
    InputState previousInputState = self.currentInputState;
    
    if (showKeyboard) {
        //马上要显示软键盘了，设置当前state为Text模式。
        self.currentInputState = InputStateText;
    }
    
    //如果不做下面这个 if == InputStateText判断，会导致表情板（或拓展面板）和键盘切换时候inputbar会晃动
    //Q：为什么会抖动？
    //A：软键盘切换到表情面板时：先调用hideKeyboardAndSwitchToCurrentBoardView方法去做动画，这时候State == InputStateEmotion。但是这时候由于软键盘收到了收起通知，也会进入到这里，这里也做了动画。两个动画冲突了
    //所以加上State == InputStateText，来确保弹出表情板时候不走下面的代码，进而让上述两个动画不会同时执行
    
    //Q：为了避免上述抖动问题，为什么不换成if (showKeyboard)？
    //A：因为如果是单纯的键盘收起其实还是要走下面的代码的；单纯的收起键盘时候showKeyboard为false，State为InputStateText
    
    if (self.currentInputState == InputStateText) {
        
        CGFloat keyboardY = [self.viewController.view convertRect:keyboardRect fromView:nil].origin.y;
                         
        CGRect inputViewFrame = self.inputBarView.frame;
        CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
        
        CGFloat messageViewFrameBottom = self.viewController.view.frame.size.height - inputViewFrame.size.height - self.safeAreaInsetsBottom;
                         
        if (inputViewFrameY > messageViewFrameBottom) {
            inputViewFrameY = messageViewFrameBottom;
        }
        
        CGRect belowInputBarXViewFrame = _belowInputBarXView.frame;
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:animationOptions
                         animations:^{
                                             
            self.inputBarView.frame = CGRectMake(inputViewFrame.origin.x, inputViewFrameY, inputViewFrame.size.width, inputViewFrame.size.height);
                             
            self.belowInputBarXView.frame = CGRectMake(belowInputBarXViewFrame.origin.x, CGRectGetMaxY(self.inputBarView.frame), belowInputBarXViewFrame.size.width, belowInputBarXViewFrame.size.height);
            
            if (showKeyboard){
                //键盘Notifition要willShow软键盘
                switch (previousInputState) {
                    case InputStateEmotion: {
                        [self switchEmotionBoardView:YES];
                        break;
                    }
                    case InputStateExtend: {
                        [self switchExtendBoardView:YES];
                        break;
                    }
                    default:
                        break;
                }
            } else {
                //如果是willHide软键盘，那么hideKeyboardAndSwitchToCurrentBoardView方法里就已经处理好动画了
            }
            
            //回调给ViewController
            [self callBackWholeInputViewHeightDidChange:self.viewController.view.frame.size.height
                              - self.inputBarView.frame.origin.y - self.safeAreaInsetsBottom reason:showKeyboard ? WholeInputViewHeightDidChangeReasonKeyboardWillShow : WholeInputViewHeightDidChangeReasonKeyboardWillHide];
            
        } completion:nil];
    }
}


#pragma mark - private
/**
 * private 切换（或者隐藏）当前面板；如果是切换，调用该方法前需要设置好currentInputState
 * @param allBoardHide yes == 隐藏所有面板，no == 显示currentInputState对应的面板（但是前提是设置好state）
 */
- (void)hideKeyboardAndSwitchToCurrentBoardView:(BOOL)allBoardHide {
    
    //无论是显示某个面板，还是隐藏所有面板，都要先让输入框失去焦点，然后再进行切换动画
    [self.inputTextView resignFirstResponder];
    //初始化一下面板view。如果在下面的动画代码里才初始化，会导致从左上角飘移进入
    [self extendBoardView];
    [self emotionBoardView];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        CGRect currentBoardViewFrame = CGRectZero;
        if (allBoardHide) {
            //表示隐藏掉两个面板
            switch (self.currentInputState) {
                case InputStateEmotion: {
                    currentBoardViewFrame = [self switchEmotionBoardView:allBoardHide];
                    break;
                }
                case InputStateExtend: {
                    currentBoardViewFrame = [self switchExtendBoardView:allBoardHide];
                    break;
                }
                default:
                    break;
            }
        } else {
            //这里需要注意方法的执行顺序
            switch (self.currentInputState) {
                case InputStateEmotion: {
                    // 1、先隐藏和自己无关的View
                    currentBoardViewFrame = [self switchExtendBoardView:!allBoardHide];
                    // 2、再显示和自己相关的View
                    currentBoardViewFrame = [self switchEmotionBoardView:allBoardHide];
                    break;
                }
                case InputStateExtend: {
                    // 1、先隐藏和自己无关的View
                    currentBoardViewFrame = [self switchEmotionBoardView:!allBoardHide];
                    // 2、再显示和自己相关的View
                    currentBoardViewFrame = [self switchExtendBoardView:allBoardHide];
                    break;
                }
                default:
                    break;
            }
        }
        
        //重设InputBarView的frame
        [self layoutInputBarView:CGRectGetMinY(currentBoardViewFrame) boardAllHide:allBoardHide];
  
        //回调给ViewController
        [self callBackWholeInputViewHeightDidChange:self.viewController.view.frame.size.height
         - self.inputBarView.frame.origin.y - self.safeAreaInsetsBottom reason:allBoardHide ? WholeInputViewHeightDidChangeReasonBoardViewDidHide : WholeInputViewHeightDidChangeReasonBoardViewDidShow];
        
    } completion:^(BOOL finished) {
        if (allBoardHide) {
            self.currentInputState = InputStateNormal;
        }
    }];
}

/**
 * private 显示（no）或者 隐藏（yes）表情面板
 * @return 表情面板的Frame
 **/
- (CGRect)switchEmotionBoardView:(BOOL)hide {
    CGRect prevFrame = self.emotionBoardView.frame;
    prevFrame.origin.y = (hide ? CGRectGetHeight(self.viewController.view.frame) : (CGRectGetHeight(self.viewController.view.frame) - CGRectGetHeight(prevFrame)));
    self.emotionBoardView.alpha = !hide;
    self.emotionBoardView.frame = prevFrame;
    return prevFrame;
}

/**
 * private 显示（no）或者 隐藏（yes）拓展面板
 * @return 拓展面板的Frame
 **/
- (CGRect)switchExtendBoardView:(BOOL)hide {
    CGRect prevFrame = self.extendBoardView.frame;
    prevFrame.origin.y = (hide ? CGRectGetHeight(self.viewController.view.frame) : (CGRectGetHeight(self.viewController.view.frame) - CGRectGetHeight(prevFrame)));
    self.extendBoardView.alpha = !hide;
    self.extendBoardView.frame = prevFrame;
    return prevFrame;
}

/**
 * private 依据当前面板切换，来决定输入条view的frame
 * @param currentBoardViewMinY 当前面板的Frame的minY
 * @param boardAllHide yes 表示所有面板都是隐藏的状态，no 但凡有一个面板没隐藏
 **/
- (void)layoutInputBarView:(CGFloat)currentBoardViewMinY boardAllHide:(BOOL)boardAllHide {
    CGRect prevInputViewFrame = self.inputBarView.frame;
    if (boardAllHide) {
        //隐藏掉两个面板
        CGFloat hidedFrameY = CGRectGetHeight(self.viewController.view.bounds);
        if (!self.inputBarBelowViewController){
            hidedFrameY -= CGRectGetHeight(prevInputViewFrame);
            hidedFrameY -= self.safeAreaInsetsBottom;
        }
        prevInputViewFrame.origin.y = hidedFrameY;
    } else {
        prevInputViewFrame.origin.y = currentBoardViewMinY - CGRectGetHeight(prevInputViewFrame);
    }
    self.inputBarView.frame = prevInputViewFrame;
    
    CGRect belowInputBarXViewFrame = self.belowInputBarXView.frame;
    self.belowInputBarXView.frame = CGRectMake(belowInputBarXViewFrame.origin.x, CGRectGetMaxY(self.inputBarView.frame), belowInputBarXViewFrame.size.width, belowInputBarXViewFrame.size.height);
}

//private
- (void)callBackWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    if ([_delegate respondsToSelector:@selector(keyboardManager:onWholeInputViewHeightDidChange:reason:)]){
        [_delegate keyboardManager:self onWholeInputViewHeightDidChange:wholeInputViewHeight reason:reason];
    }
}

#pragma mark - public
// public - 底部的输入框高度发生变化，changeValue 高度变化值
- (void)inputTextViewHeightDidChange:(BOOL)becauseSendText {
    //回调给ViewController
    [self callBackWholeInputViewHeightDidChange: self.viewController.view.frame.size.height
     - self.inputBarView.frame.origin.y - _safeAreaInsetsBottom reason: becauseSendText ? WholeInputViewHeightDidChangeReasonTextDidSend : WholeInputViewHeightDidChangeReasonTextDidChange];
}

// public - 隐藏所有面板，包括表情面板和拓展面板 和 软键盘
- (void)hideAllBoardView {
    if (self.currentInputState != InputStateNormal) {
        //说明当前要么是键盘，要么是表情面板或者拓展面板
        [self hideKeyboardAndSwitchToCurrentBoardView:YES];
    }
}

// public - 切换到表情面板，toEmotionBoardView
- (void)switchToEmotionBoardKeyboard {
    //先设置全局变量State为表情State
    self.currentInputState = InputStateEmotion;
    
    //NO表示是要显示当前面板（即InputStateEmotion）
    [self hideKeyboardAndSwitchToCurrentBoardView:NO];
}

// public - 切换到拓展面板，toExtendBoardView
- (void)switchToExtendBoardKeyboard {
    //先设置全局变量State为拓展State
    self.currentInputState = InputStateExtend;
    
    //NO表示是要显示当前面板（即InputStateExtend）
    [self hideKeyboardAndSwitchToCurrentBoardView: NO];
}

//顺便提一句：切换到软键盘是靠系统的[textView becomeFirstResponder]; 然后会触发键盘的Notification，然后就进入我上面封装的onKeyboardWillShowOrHideByNotifications方法


@end
