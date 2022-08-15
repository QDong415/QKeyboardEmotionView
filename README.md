# QKeyboardEmotionView

[![CI Status](https://img.shields.io/travis/285275534/QKeyboardEmotionView.svg?style=flat)](https://travis-ci.org/285275534/QKeyboardEmotionView)
[![Version](https://img.shields.io/cocoapods/v/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)
[![License](https://img.shields.io/cocoapods/l/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)
[![Platform](https://img.shields.io/cocoapods/p/QKeyboardEmotionView.svg?style=flat)](https://cocoapods.org/pods/QKeyboardEmotionView)

## 简介：

- 仿微信表情键盘：左->语音按钮，中间->输入条+按住录音，右->表情按钮+拓展按钮；每个按钮都可以隐藏或显示；

- 朋友圈表情键盘：平时不显示底部输入栏，点击cell时候再显示输入栏；

## 基础功能：
- ✅UI仿微信聊天底部输入栏，表情和键盘切换动画平滑，全程60帧
- ✅底部输入栏可以在需要时候再显示，平时隐藏（评论列表场景 或 朋友圈场景 或 发微博场景）
- ✅表情面板+拓展面板+底部输入条+语音条+UITextView，各个模块都不会互相import，完美解耦
- ✅每个模块都可以自定义，且都可以自由替换，也都可以拉出来当做独立的模块
- ✅无内存泄漏。代码清晰明确，注释量比代码都多
- ✅兼容横屏模式，兼容黑夜模式，兼容导航栏半透明或不透明
- ✅兼容Swift，提供Swift Demo
- ✅输入框直接显示表情图片😊，而不是[微笑]

## 进阶功能：
- ✅提供了文本"[微笑]"解析成图片的方法，并在ios15以下采用了缓存机制，加快解析速度
- ✅提供了ios15下，刚进入聊天界面时候tableView需要滚到底部导致导航栏闪现的问题解决方案
- ✅输入文字发生换行时候的动画和”发送“文字时候输入框动画分别采用不同的流程机制，媲美微信


### 效果gif图（Gif图有点卡，实际运行一点都不卡）：
![](https://upload-images.jianshu.io/upload_images/26002059-6161708ed9a717bc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/26002059-0a737b12d3b22686.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)![](https://upload-images.jianshu.io/upload_images/26002059-5edc0185947803a3.gif?imageMogr2/auto-orient/strip)![](https://upload-images.jianshu.io/upload_images/26002059-08b4b9cbaf7bea39.gif?imageMogr2/auto-orient/strip)

## Example

先在终端里搜索 `pod search QKeyboardEmotionView` 

如果搜索不到`2.2`版本，需要更新你电脑的pod仓库，以下是更新步骤：

1、先 `pod repo update`  更新你本地电脑的pod仓库。然后再搜索一次试试看

2、如果还是搜索不到，执行 `rm ~/Library/Caches/CocoaPods/search_index.json` 。再搜索就OK了

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

// 点击键盘右下角的按钮是否是发送，NO表示普通回车换行，YES表示回调Delegate的Send方法
@property (nonatomic, assign) BOOL keyboardSendEnabled; // default is YES

//  输入栏TextView的高度发送变化的动画时长（秒）
@property (nonatomic, assign) NSTimeInterval inputBarHeightChangeAnimationDuration; // default is 0.2
```

## Installation

```ruby
pod 'QKeyboardEmotionView'
```

## Author：DQ  

285275534, 285275534@qq.com

我的其他开源库，给个Star鼓励我写更多好库：

[IOS Swift项目框架模版Demo，教科书级标准。轻量、规范、易懂、易移植、解耦](https://github.com/QDong415/QSwift)

[IOS 1:1完美仿微信聊天表情键盘](https://github.com/QDong415/QKeyboardEmotionView)

[IOS 自定义UIAlertController，支持弹出约束XibView、弹出ViewController](https://github.com/QDong415/QUIAlertController)

[IOS 封装每条Cell样式都不一致的UITableView，告别复杂的UITableViewDataSource](https://github.com/QDong415/QTableKit)

[IOS 仿快手直播界面加载中，顶部的滚动条状LoadingView](https://github.com/QDong415/QStripeAnimationLayer)

[IOS 基于个推+华为push的一整套完善的 IM聊天系统](https://github.com/QDong415/iTopicOCChat)

[Android 朋友圈列表Feed流的最优化方案，让你的RecyclerView从49帧 -> 57帧](https://github.com/QDong415/QFeed)

[Android 仿大众点评、仿小红书 下拉拖拽关闭Activity](https://github.com/QDong415/QDragClose)

[Android 仿快手直播间手画礼物，手绘礼物](https://github.com/QDong415/QDrawGift)

[Android 直播间聊天消息列表RecyclerView。一秒内收到几百条消息依然不卡顿](https://github.com/QDong415/QLiveMessageHelper)

[Android 仿快手直播界面加载中，顶部的滚动条状LoadingView](https://github.com/QDong415/QStripeView)

[Android Kotlin MVVM框架，全世界最优化的分页加载接口、最接地气的封装](https://github.com/QDong415/QKotlin)

[Android 基于个推+华为push的一整套完善的android IM聊天系统](https://github.com/QDong415/iTopicChat)

## License

QKeyboardEmotionView is available under the MIT license. See the LICENSE file for more info.
