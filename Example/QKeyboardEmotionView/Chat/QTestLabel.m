//
//  QTestLabel.m
//  QKeyboardEmotionView_Example
//
//  Created by DongJin on 2022/3/22.
//  Copyright © 2022 285275534. All rights reserved.
//

#import "QTestLabel.h"

@implementation QTestLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setNeedsLayout {
    NSLog(@"QTestLabel setNeedsLayout");
}

- (void)layoutSubviews {
    NSLog(@"QTestLabel layoutSubviews");
}

- (void)dealloc {
    NSLog(@"QTestLabel dealloc");
}


@end
