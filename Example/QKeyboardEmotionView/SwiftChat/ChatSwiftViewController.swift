//
//  ChatViewController.swift
//  QSwift
//
//  Created by DongJin on 2021/8/30.
//

import Foundation
import UIKit
import QKeyboardEmotionView

class ChatSwiftViewController : CommonKeyboardViewController {
    
    private var tableView: UITableView!
    
    private lazy var mainArray: [String] = {
        return [String]()
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Swift聊天Demo"
        
        for index in 0...20 {
            mainArray.append(String.init(format: "聊天消息--%d", index))
        }
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
        
        //为了适配ios11的黑夜模式
        if #available(iOS 11, *) {
            tableView.backgroundColor = UIColor.init(named: "background");
            tableView.separatorColor = UIColor.init(named: "separator");
        } else {
            tableView.backgroundColor = UIColor(red: (248)/255.0, green: (248)/255.0, blue: (246)/255.0, alpha: 1)
        }
        
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView)
    }
    
    //整个“输入View”的高度发生变化（整个View包含bar和表情栏或者键盘）
    override func keyboardManager(_ keyboardManager: QKeyboardManager!, onWholeInputViewHeightDidChange wholeInputViewHeight: CGFloat, reason: WholeInputViewHeightDidChangeReason) {
        
        let alreadyAtBottom :Bool = self.alreadyAtBottom()

        //注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考DiscussViewController
        var insets: UIEdgeInsets = .zero
        insets.top = 0
        insets.bottom = wholeInputViewHeight + tableViewBottomEdgeInsets()
        //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets

        if reason == WholeInputViewHeightDidChangeReason.willAddToSuperView {
            //聊天界面，初始化array后，要滚到底部
            //我是这样实现的滚到底部的，你可以自己更改
            DispatchQueue.main.async(execute: { [self] in
                scrollToBottom(animated: false)
            })
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
        bottomInputView.inputTextView.text = nil;
        
        tableView.reloadData()
        scrollToBottom(animated: true)
    }
    
    //注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考ChatXibViewController
    // MARK: - NeedOverride
    func tableViewBottomEdgeInsets() -> CGFloat {
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

    private func resetUIEdgeInsets(_ wholeInputViewHeight: CGFloat) {
        var insets: UIEdgeInsets = .zero
        insets.top = 0
        insets.bottom = wholeInputViewHeight
        //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
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

extension ChatSwiftViewController : UITableViewDataSource ,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
//        cell.selectionStyle = UITableViewCell.SelectionStyleNone;
        
        if (indexPath.row % 2 == 1) {
            cell.imageView!.image = UIImage.init(named: "user_photo");
        } else {
            cell.imageView!.image = UIImage.init(named: "user_photo2");
        }
         
        cell.textLabel!.text = mainArray[indexPath.row];
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
        return 80
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        keyboardManager.hideAllBoardView()
    }
    
}

