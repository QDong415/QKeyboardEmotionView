//
//  ChatSwiftCell.swift
//  QKeyboardEmotionView_Example
//
//  Created by DongJin on 2022/3/27.
//  Copyright © 2022 285275534. All rights reserved.
//

import UIKit

class ChatSwiftCell: UITableViewCell {

    var avatarImageView: UIImageView!
    var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screenWidth = Int(UIScreen.main.bounds.size.width)

        avatarImageView = UIImageView()
        avatarImageView.frame = CGRect(x: 12, y: 12, width: 46, height: 46)
        contentView.addSubview(avatarImageView)

        nameLabel = UILabel()
        let nameOriginX = Int(avatarImageView.frame.maxX + 15)
        nameLabel.frame = CGRect(x: CGFloat(nameOriginX), y: 15, width: CGFloat(screenWidth - nameOriginX - 15), height: 18)
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = UIColor.red //[UIColor blackColor];
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
    }
    
    //根据AttributedString，结合label的宽度，计算String高度
    func height(forContent contentAttributed: NSAttributedString?) -> CGFloat {
        let frame = contentAttributed?.boundingRect(with: CGSize(width: nameLabel.frame.size.width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return frame?.size.height ?? 0.0
    }

    func resetContentLabelFrame(_ height: CGFloat) {
        let orgFrame = nameLabel.frame
        nameLabel.frame = CGRect(x: orgFrame.origin.x, y: orgFrame.origin.y, width: orgFrame.size.width, height: height)
    }

}
