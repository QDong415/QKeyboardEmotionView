//
//  CommonKeyboardViewController.swift
//  QSwift
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import Foundation
import QKeyboardEmotionView

class CommonKeyboardViewController : UIViewController {
    
    var keyboardManager: QKeyboardManager!

    var bottomInputView: QInputBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBodyView()
        
        // 初始化输入工具条，frame可以先这样临时设置，下面的addBottomInputBarView方法会重置输入条frame
        // 如果你想要自定义输入条View，请参考TextFieldViewController代码
        bottomInputView = QInputBarView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: CGFloat(UIInputBarViewMinHeight)))
        bottomInputView.setup(with: inputBarViewConfiguration())
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.viewControllerWillDisappear = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 避免手势返回的时候输入框往下掉
        keyboardManager.viewControllerWillDisappear = true
    }
    
    // MARK: NeedOverride
    func inputBarViewConfiguration() -> QInputBarViewConfiguration {
        //输入条配置，子类可以重写
        return QInputBarViewConfiguration.default();
    }
    
    func belowViewController() -> Bool {
        //YES表示输入框平时不显示（比如朋友圈）；NO表示平时也显示（比如聊天），子类可以重写
        return false;
    }
    
    func initBodyView(){
    }
    
    func sendTextMessage(inputText :String){
        //发送事件，子类可以重写
    }
}

//输入条的Delegate回调
extension CommonKeyboardViewController: QInputBarViewDelegate {
    
    //点击了系统键盘的发送按钮
    func inputBarView(_ inputBarView: QInputBarView!, onKeyboardSendClick inputText: String!) {
        sendTextMessage(inputText: inputText)
    }
    
    //点击+按钮
    func inputBarView(_ inputBarView: QInputBarView!, onExtendButtonClick extendSwitchButton: UIButton!) {
        keyboardManager.switchToExtendBoardKeyboard()
    }
    
    //点击表情按钮，切换到表情面板
    func inputBarView(_ inputBarView: QInputBarView!, onEmotionButtonClick emotionSwitchButton: UIButton!) {
        if (emotionSwitchButton.isSelected) {
            keyboardManager.switchToEmotionBoardKeyboard()
        } else {
            bottomInputView.textViewBecomeFirstResponder();
        }
    }
    
    //在发送文本和语音之间发送改变，voiceSwitchButton.isSelected表示切换到了语音输入模式
    func inputBarView(_ inputBarView: QInputBarView!, onVoiceSwitchButtonClick voiceSwitchButton: UIButton!) {
        if (voiceSwitchButton.isSelected) {
            //切换到了语音输入模式
            keyboardManager.hideAllBoardView()
        }
    }

    // 输入框的高度发生了改变（因为输入框里的文字行数变化了），注意这里仅仅是TextView输入框的高度发生了变化的回调；becauseSendText：YES表示是因为调用了clearInputTextBySend去发送文本
    func inputBarView(_ inputBarView: QInputBarView!, inputTextView: UITextView!, heightDidChange changeValue: CGFloat, becauseSendText: Bool) {
        //这里要告知Manager类
        keyboardManager.inputTextViewHeightDidChange(becauseSendText)
    }
}

//整个BoardView的Delegate回调
extension CommonKeyboardViewController: InputBoardDelegate {
    
    //整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘，但是不包含底部安全区高度）
    func keyboardManager(_ keyboardManager: QKeyboardManager!, onWholeInputViewHeightDidChange wholeInputViewHeight: CGFloat, reason: WholeInputViewHeightDidChangeReason) {
        
    }
}

//整个BoardView的DataSource
extension CommonKeyboardViewController: InputBoardDataSource {
    
    //@return 点加号按钮弹出的拓展面板View，且无需设置frame
    func keyboardManagerExtendBoardView(_ keyboardManager: QKeyboardManager!) -> UIView! {
        let boardView = QExtendBoardView()
//        boardView.delegate = self
        if #available(iOS 11.0, *) {
            let bundle = Bundle(for: QKeyboardBaseManager.self)
            boardView.backgroundColor = UIColor(named: "q_input_extend_bg", in: bundle, compatibleWith: nil)
        } else {
            boardView.backgroundColor = UIColor(red: (246) / 255.0, green: (246) / 255.0, blue: (246) / 255.0, alpha: 1)
        }

        let photoItem = QExtendBoardItemModel(normalIconImage: UIImage(named: "message_more_pic"), title: "图片")
        let redItem = QExtendBoardItemModel(normalIconImage: UIImage(named: "message_more_groupluckybag"), title: "红包")
        let locationItem = QExtendBoardItemModel(normalIconImage: UIImage(named: "message_more_poi"), title: "位置")
        boardView.extendBoardItems = [photoItem!, redItem!, locationItem!]
        return boardView
    }
    
    //@return 点表情按钮弹出的表情面板View，且无需设置frame
    func keyboardManagerEmotionBoardView(_ keyboardManager: QKeyboardManager!) -> UIView! {
        let emotionView = QEmotionBoardView()
        emotionView.emotions = QEmotionHelper.shared()!.emotionArray;
        emotionView.delegate = self
        if #available(iOS 11.0, *) {
            let bundle = Bundle(for: QKeyboardBaseManager.self)
            emotionView.backgroundColor = UIColor(named: "q_input_extend_bg", in: bundle, compatibleWith: nil)
        } else {
            emotionView.backgroundColor = UIColor(red: (246) / 255.0, green: (246) / 255.0, blue: (246) / 255.0, alpha: 1)
        }
        return emotionView
    }
    
    func keyboardManagerEmotionBoardHeight(_ keyboardManager: QKeyboardManager!) -> CGFloat {
        return 274;
    }
    
    func keyboardManagerExtendBoardHeight(_ keyboardManager: QKeyboardManager!) -> CGFloat {
        return 174;
    }
}

//整个BoardView的DataSource
extension CommonKeyboardViewController: QEmotionBoardViewDelegate {
    
    /**
     *  选中表情时的回调
     *  @param  index   被选中的表情在`emotions`里的索引
     *  @param  emotion 被选中的表情对应的`QMUIEmotion`对象
     */
    func emotionView(_ emotionView: QEmotionBoardView!, didSelect emotion: QEmotion!, at index: Int) {
        let faceManager = QEmotionHelper.shared()
        //把😊插入到输入栏
        bottomInputView.insertEmotionAttributedString(faceManager?.obtainAttributedString(byImageKey: emotion.displayName, font: bottomInputView.inputTextView.font, useCache: false))
    }
    
    // 删除按钮的点击事件回调
    func emotionViewDidSelectDeleteButton(_ emotionView: QEmotionBoardView!) {
        if (!bottomInputView.deleteEmotion()){
            //根据当前的光标，这次点击删除按钮并没有删除表情，那么就删除文字
            bottomInputView.inputTextView.deleteBackward();
        }
    }
    
    // 发送按钮的点击事件回调
    func emotionViewDidSelectSendButton(_ emotionView: QEmotionBoardView!) {
        sendTextMessage(inputText: bottomInputView.textViewInputNormalText())
    }
}
