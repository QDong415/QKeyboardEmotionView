//
//  ChatCell.m
//  QKeyboardEmotionView_Example
//
//  Created by mac on 2022/3/25.
//  Copyright © 2022 285275534. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int screenWidth = [[UIScreen mainScreen]bounds].size.width;
        
        self.avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.frame = CGRectMake(12, 12, 46, 46);
        [self.contentView addSubview:_avatarImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        int nameOriginX = CGRectGetMaxX(_avatarImageView.frame) + 15;
        _nameLabel.frame = CGRectMake(nameOriginX, 15 , screenWidth - nameOriginX - 15 , 18);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
        [self.contentView addSubview:_nameLabel];
        
    }
    
    return self;
}

//根据AttributedString，结合label的宽度，计算String高度
- (CGFloat)heightForContent:(NSAttributedString *)contentAttributed {
    CGRect frame = [contentAttributed boundingRectWithSize:CGSizeMake(_nameLabel.frame.size.width, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return frame.size.height;
}

- (void)resetContentLabelFrame:(CGFloat)height {
    CGRect orgFrame = _nameLabel.frame;
    _nameLabel.frame = CGRectMake(orgFrame.origin.x, orgFrame.origin.y , orgFrame.size.width, height);
}

@end
