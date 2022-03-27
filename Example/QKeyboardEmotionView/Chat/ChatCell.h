//
//  ChatCell.h
//  QKeyboardEmotionView_Example
//
//  Created by mac on 2022/3/25.
//  Copyright © 2022 285275534. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatCell : UITableViewCell

@property (nonatomic,strong) UIImageView *avatarImageView;
@property (nonatomic,strong) UILabel *nameLabel;

//根据AttributedString，结合label的宽度，计算String高度
- (CGFloat)heightForContent:(NSAttributedString *)contentAttributed;

- (void)resetContentLabelFrame:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
