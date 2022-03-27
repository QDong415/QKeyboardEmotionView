//
//  ChatViewController.swift
//  QSwift
//
//  Created by DongJin on 2021/8/30.
//

import Foundation
import UIKit
import QKeyboardEmotionView

@available(iOS 13.0, *)
class ChatSwiftViewController : CommonKeyboardViewController {
    
    private var tableView: UITableView!
    
    private lazy var mainArray: [String] = {
        return [String]()
    }()
    
    private var lastAppearance: UINavigationBarAppearance?;
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Swift聊天Demo"
        view.backgroundColor = UIColor(red: (237) / 255.0, green: (237) / 255.0, blue: (237) / 255.0, alpha: 1)
        
        for index in 0...0 {
            mainArray.append(String.init(format: "聊天消息--%d", index))
        }
        
        self.tableView.register(ChatSwiftCell.self, forCellReuseIdentifier: "ChatSwiftCell");
        self.tableView.separatorStyle = .none;
        
        
        //因为聊天界面一打开就要滚到底部。在ios15上如果你用系统的导航栏，tableView立即滚到底部会导致导航栏闪现
        //想彻底解决这个问题，目前DQ只想到两个方案：
        //1 在viewDidLoad里用 += 计算Cell的总高度，一旦高于tableView.height，就设置scrollEdgeAppearance，然后滚到底部再把scrollEdgeAppearance设置回去
        //2 用kvo监听tableView的contentSize，如果大于tableView.height，就设置scrollEdgeAppearance。这种方法的前提是需要你去实现estimatedHeightForRowAtIndexPath
        //以上两种方案都需要你自己做好Cell的高度缓存，并解耦Cell高度计算方法。本文就不展示了，毕竟本文只是个键盘类。
        
        //本文只是粗糙的判断一下data是否大于1，这样的话，会出现的问题是：如果cell数量大于2且小于tableView可滚动的数量时导航栏的那根线会显示有个消失动画
        if #available(iOS 15, *) {
            self.lastAppearance = self.navigationController?.navigationBar.scrollEdgeAppearance;
            if (mainArray.count > 1){
                //移除ios15的导航栏的渐变特性
                let appearance = UINavigationBarAppearance();
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance;
            }
        }
        
        //按住说话功能 由你自己实现
    //    self.inputView.recordButton addTarget:
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let shouldChangeTableViewFrame: Bool = !self.view.bounds.equalTo(tableView.frame);
        if (shouldChangeTableViewFrame) {
            tableView.frame = self.view.bounds;
        }
    }
    
    // MARK: - Override
    override func initBodyView(){
        tableView = UITableView.init(frame: view.bounds, style: UITableView.Style.plain)
        
        //移除底部多余的separator
        if(tableView.style == UITableView.Style.plain){
            let footerView: UIView = UIView();
            tableView.tableFooterView = footerView;
        }
                
        tableView.backgroundColor = UIColor(red: (237) / 255.0, green: (237) / 255.0, blue: (237) / 255.0, alpha: 1)
        
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView)
    }
    
    //整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘，但是不包含底部安全区高度）
    override func keyboardManager(_ keyboardManager: QKeyboardManager!, onWholeInputViewHeightDidChange wholeInputViewHeight: CGFloat, reason: WholeInputViewHeightDidChangeReason) {
        
        let alreadyAtBottom :Bool = self.alreadyAtBottom()

        //注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考DiscussViewController
        var insets: UIEdgeInsets = .zero
        insets.top = 0
        insets.bottom = wholeInputViewHeight + navigationBarHeight()
        //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets

        if reason == WholeInputViewHeightDidChangeReason.willAddToSuperView {
            //聊天界面，初始化array后，要滚到底部
            DispatchQueue.main.async(execute: { [self] in
                //滚到底部
                scrollToBottom(animated: false)
                
                if #available(iOS 15, *) {
                    self.navigationController?.navigationBar.scrollEdgeAppearance = self.lastAppearance
                    //释放掉
                    self.lastAppearance = nil
                }
            })
            return
        }

        if (reason == WholeInputViewHeightDidChangeReason.textDidSend) {
            //因为点“发送”按钮所以清空了文本框，这种情况下，sendTextMessage已经调用scrollToBottom了，无需再多余动画
            return
        }
        
        //如果你有更好的处理tableview的滚到底部的动画方法，请告诉我
        if alreadyAtBottom {
            //用自己的animations，问题就是会闪屏，尤其是tableview滚在上方时候 闪的越狠；好处是tableview在切换时候很跟手
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [self] in
                scrollToBottom(animated: false)
            })
        } else {
            //用系统的scroll的Animated，不会闪屏，但是问题是tableview在切换时候不那么跟手
            scrollToBottom(animated: true)
        }
    }
    
    override func sendTextMessage(inputText :String){
        //发送事件
        mainArray.append(inputText)
        
        //请不要用inputTextView.text = nil来清空文本，具体原因看方法注释
        //@return 0：当前inputText只有一行；非0：动画时长
        let animationDuration: TimeInterval = bottomInputView.clearInputTextBySend()

        if (animationDuration == 0){
            //如果textView的文本只有一行，那么清空输入框的时候，不会走onWholeInputViewHeightDidChange回调，也不会重新设置tableView的contentInset。所以就无需延时reloadData
            reloadDataAndScrollToBottom(animated: true)
        } else {
            
            //textView的文本大于一行，那么清空输入框的时候，会重设tableView的contentInset（并且我还是在0.2秒的动画里重设的），如果这时候reloadData，在低性能设备上会出现tableView来回上下移动的问题
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationDuration, execute: { [self] in

                reloadDataAndScrollToBottom(animated: true)
            })
        }
    }
    
    //注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考ChatXibViewController
    // MARK: - NeedOverride
    func navigationBarHeight() -> CGFloat {
        return navigationController?.navigationBar.isTranslucent ?? false ? 0 : (UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height ?? 0.0))
    }
    
    // MARK: - Private
    private func scrollToBottom(animated: Bool) {
        let rows = tableView.numberOfRows(inSection: 0)
        if rows > 0 {
            tableView.scrollToRow(
                at: IndexPath(row: rows - 1, section: 0),
                at: .bottom,
                animated: animated)
        }
    }

    //reloadData并滚到底部
    private func reloadDataAndScrollToBottom(animated: Bool) {

        tableView.reloadData()

        var resultAnimated = animated
        if #available(iOS 13.0, *) {
        } else {
            //在ios12中，滚到底部再animal总是会出现最后一个Cell滚动异常，所以我干脆禁止了ios12的动画
            resultAnimated = false
        }
        // ios 13、15都是ok的
        scrollToBottom(animated: resultAnimated)
    }

    private func alreadyAtBottom() -> Bool {
        if CGFloat((Int(tableView.contentOffset.y))) == (CGFloat(Int(tableView.contentSize.height)) + scrollviewContentInset().bottom - tableView.bounds.height) {
            return true
        }

        return false
    }

    private func scrollviewContentInset() -> UIEdgeInsets {
        if #available(iOS 11, *) {
            return tableView.adjustedContentInset
        } else {
            return tableView.contentInset
        }
    }
}

@available(iOS 13.0, *)
extension ChatSwiftViewController : UITableViewDataSource ,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSwiftCell") as? ChatSwiftCell

        guard let cell = cell else { return UITableViewCell() }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        if indexPath.row % 2 == 1 {
            cell.avatarImageView.image = UIImage(named: "user_photo")
        } else {
            cell.avatarImageView.image = UIImage(named: "user_photo2")
        }

        let faceManager = QEmotionHelper.shared()
        cell.nameLabel.attributedText = faceManager!.attributedString(byText: mainArray[indexPath.row], font: cell.nameLabel.font)

        cell.resetContentLabelFrame(cell.height(forContent: cell.nameLabel.attributedText))
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
        return tableView.style == UITableView.Style.plain ? 0 : CGFloat.leastNormalMagnitude;
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
        return tableView.style == UITableView.Style.plain ? 0 : 8;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //这里应该做高度缓存的，我这里只是demo就省略了，你自己做高度缓存
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSwiftCell") as! ChatSwiftCell
        let faceManager = QEmotionHelper.shared()
        //    46是头像的高度； + 12 + 12是padding
        return max(46, cell.height(forContent: faceManager?.attributedString(byText: mainArray[indexPath.row], font: cell.nameLabel.font))) + 12 + 12
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        keyboardManager.hideAllBoardView()
    }
    
}

