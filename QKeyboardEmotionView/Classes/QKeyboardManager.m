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

@end

@implementation QKeyboardManager

#pragma mark - public 添加底部输入框View
- (void)addBottomInputBarView:(UIView *)inputBarView belowViewController:(BOOL)belowViewController {
    
    if (@available(iOS 11.0, *)) {
        //如果是x，给底部的34pt添加上背景颜色，颜色和输入条一致
        _safeAreaInsetsBottom = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
        if(_safeAreaInsetsBottom > 0 && !belowViewController){
            UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.viewController.view.frame.size.height - _safeAreaInsetsBottom , self.viewController.view.frame.size.width, _safeAreaInsetsBottom)];
            bottomView.backgroundColor = inputBarView.backgroundColor;
            [self.viewController.view addSubview:bottomView];
            [self.viewController.view bringSubviewToFront:bottomView];
            bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
    }
    
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
- (void)onKeyboardDidShowNotification:(NSNotification *)notification {
    if ([self.inputTextView isFirstResponder]) {
        if (self.currentInputState == InputStateText) {
            self.extendBoardView.alpha = 0.0;
            self.emotionBoardView.alpha = 0.0;
        }
    }
}

#pragma mark - Override
//通过系统的键盘广播触发到这里
- (void)onKeyboardWillShowOrHide:(CGRect)keyboardRect animationOptions:(UIViewAnimationOptions)animationOptions duration:(double)duration showKeyboard:(BOOL)showKeyboard {
    if (self.currentInputState == InputStateText) {//如果不做这个判断，表情和键盘切换时候inputbar会晃动
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:animationOptions
                         animations:^{
                             CGFloat keyboardY = [self.viewController.view convertRect:keyboardRect fromView:nil].origin.y;
                             CGRect inputViewFrame = self.inputBarView.frame;
                             CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
            
                             CGFloat messageViewFrameBottom = self.viewController.view.frame.size.height - inputViewFrame.size.height - self.safeAreaInsetsBottom;
                             if (inputViewFrameY > messageViewFrameBottom)
                                 inputViewFrameY = messageViewFrameBottom;
                             
                            self.inputBarView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                          inputViewFrameY,
                                                                          inputViewFrame.size.width,
                                                                          inputViewFrame.size.height);
                             [self callBackWholeInputViewHeightDidChange:self.viewController.view.frame.size.height
                              - self.inputBarView.frame.origin.y - self.safeAreaInsetsBottom reason:showKeyboard ? WholeInputViewHeightDidChangeReasonKeyboardWillShow : WholeInputViewHeightDidChangeReasonKeyboardWillHide];
                         }
                         completion:nil];
    }
}


#pragma mark - private
/**
 * private 切换（或者隐藏）当前面板；如果是切换，调用该方法前需要设置好currentInputState
 * @param allBoardHide yes == 隐藏所有面板，no == 显示currentInputState对应的面板（但是前提是设置好state）
 */
- (void)switchCurrentBoardView:(BOOL)allBoardHide {
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
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
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
        
        [self layoutInputBarView:CGRectGetMinY(currentBoardViewFrame) boardAllHide:allBoardHide];
  
        [self callBackWholeInputViewHeightDidChange:self.viewController.view.frame.size.height
         - self.inputBarView.frame.origin.y - self.safeAreaInsetsBottom reason:allBoardHide ? WholeInputViewHeightDidChangeReasonBoardViewDidHide : WholeInputViewHeightDidChangeReasonBoardViewDidShow];
        
        //临时测试
//        ChatViewController *vc = self.viewController;
//        [vc resetUIEdgeInsets:self.viewController.view.frame.size.height - self.inputBarView.frame.origin.y - self.safeAreaInsetsBottom];
//        [vc scrollToBottomAnimated:NO];
        
        
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
}

//private
- (void)callBackWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {
    if ([_delegate respondsToSelector:@selector(keyboardManager:onWholeInputViewHeightDidChange:reason:)]){
        [_delegate keyboardManager:self onWholeInputViewHeightDidChange:wholeInputViewHeight reason:reason];
    }
}

#pragma mark - public
// public - 底部的输入框开始编辑（由vc的tv的delegate触发之后，再主动调用这里）
- (void)inputTextViewShouldBeginEditing {
    self.currentInputState = InputStateText;
}

// public - 底部的输入框高度发生变化，changeValue 高度变化值
- (void)inputTextViewHeightDidChange {
    
    [self callBackWholeInputViewHeightDidChange: self.viewController.view.frame.size.height
     - self.inputBarView.frame.origin.y - _safeAreaInsetsBottom reason:WholeInputViewHeightDidChangeReasonTextDidChange];
}

// public - 隐藏所有面板，包括表情面板和拓展面板
- (void)hideAllBoardView {
    if (self.currentInputState != InputStateNormal) {
        //说明当前要么是键盘，要么是表情面板或者拓展面板
        [self switchCurrentBoardView:YES];
    }
}

// public - 表情面板和键盘之间的切换，toEmotionBoard true表示切换成表情面板 false表示切换成键盘
- (void)switchToEmotionBoardKeyboard {
    self.currentInputState = InputStateEmotion;
    [self switchCurrentBoardView:NO];
}

// public - 拓展面板和键盘之间的切换，toExtendBoard true表示切换成拓展面板
- (void)switchToExtendBoardKeyboard {
    self.currentInputState = InputStateExtend;
    [self switchCurrentBoardView: NO];
}

- (void)dealloc {
    NSLog(@"QKeyM dealloc");
}


@end
