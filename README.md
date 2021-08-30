# QKeyboardEmotionView

[![CI Status](https://img.shields.io/travis/285275534/QKeyboardEmotionView.svg?style=flat)](https://travis-ci.org/285275534/QKeyboardEmotionView)
[![Version](https://img.shields.io/cocoapods/v/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)
[![License](https://img.shields.io/cocoapods/l/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)
[![Platform](https://img.shields.io/cocoapods/p/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)

## 简介：

- 仿微信表情键盘：包含功能：左->语音按钮，中间->输入条+按住录音，右->表情按钮+拓展按钮；每个按钮都可以隐藏或显示；

- 朋友圈表情键盘：平时不显示输入栏，点击cell时候再显示；

## 功能：
- ✅UI仿微信聊天底部输入栏，表情和键盘切换平滑自然，全程60帧
- ✅底部输入栏可以在需要时候再显示，平时隐藏（评论列表场景 或 发微博场景）
- ✅表情面板+拓展面板+底部输入条 +语音条+UITextView，各个模块都不会互相import，完美解耦
- ✅每个模块都可以自定义，都可以自由替换，也都可以拉出来当做独立的模块
- ✅完全不存在内存泄漏，占用内存非常少
- ✅兼容横屏模式，兼容黑夜模式
- ✅兼容Swift，提供Swift Demo

### 效果gif图：
Gif图可能有点卡顿，实际运行一点都不卡
![](http://qiniu.itopic.com.cn/keyboard1.png)
![](http://qiniu.itopic.com.cn/keyboard2.gif)![](http://qiniu.itopic.com.cn/keyboard3.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

OC 调用方式：
```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView方法会重置输入条frame
    // 如果你想要自定义输入条View，请参考TextFieldViewController代码
    _inputView = [[QInputBarView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,UIInputBarViewMinHeight)];
    _inputView.dataSource = self;
    _inputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    _keyboardManager = [[QKeyboardManager alloc] initWithViewController:self];
    _keyboardManager.dataSource = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate
    _keyboardManager.delegate = self;
    //将输入条View添加到ViewController；YES表示输入条平时不显示（比如朋友圈）；NO表示平时也显示（比如聊天）
    [_keyboardManager addBottomInputBarView:_inputView belowViewController:NO];
    
    //把输入框（如果有的话）绑定给管理类
    [_keyboardManager bindTextView:_inputView.inputTextView];
}
```

Swift 调用方式：
```Swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView方法会重置输入条frame
    // 如果你想要自定义输入条View，请参考TextFieldViewController代码
    bottomInputView = QInputBarView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: CGFloat(UIInputBarViewMinHeight)))
    bottomInputView.delegate = self;
    
    //keyboard管理类，用来管理键盘，各大面板的切换
    keyboardManager = QKeyboardManager(viewController: self);
    keyboardManager.dataSource = self;
    //因为addBottomInputBarView方法会立刻触发delegate，所以这里需要先设置delegate，再addBottomInputBarView
    keyboardManager.delegate = self;
    //将输入条View添加到ViewController；YES表示输入条平时不显示（比如朋友圈）；NO表示平时也显示（比如聊天）
    keyboardManager.addBottomInputBarView(bottomInputView, belowViewController: belowViewController())
    
    //把输入框（如果有的话）绑定给管理类
    keyboardManager.bindTextView(bottomInputView.inputTextView)
}
```

参数配置
```Objective-C
@property (nonatomic, strong) UIColor *inputBarBackgroundColor;//输入条颜色，默认仿微信的灰色
@property (nonatomic, strong) UIColor *inputBarBoardColor;//输入条上方的的那一条细横线的颜色
@property (nonatomic, strong) UIColor *textColor;//输入栏textview的颜色
@property (nonatomic, strong) UIColor *textViewBackgroundColor;//输入栏textview的背景颜色，默认白色
@property (nonatomic, strong) UIColor *recordButtonTitleColor;//按住说话按钮的字体颜色
@property (nonatomic, assign) BOOL voiceButtonHidden; //是否隐藏发送语音 default is NO
@property (nonatomic, assign) BOOL extendButtonHidden; //是否隐藏发送多媒体 default is NO
@property (nonatomic, assign) BOOL emotionButtonHidden; //是否隐藏发送表情 default is NO

/// 点击键盘右下角的按钮是否是发送，NO表示普通回车换行，YES表示回调Delegate的Send方法
@property (nonatomic, assign) BOOL keyboardSendEnabled; // default is YES
```

## Requirements

## Installation

QKeyboardEmotionView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QKeyboardEmotionView'
```

## Author

285275534, 285275534@qq.com

## License

QKeyboardEmotionView is available under the MIT license. See the LICENSE file for more info.
