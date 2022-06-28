//
//  QEmotionView.m
//  qmui
//
//  Created by QMUI Team on 16/9/6.
//  作者DQ：这里的代码我是从QMUI里摘抄出来再做了删减。然后我修改了修复QMUI的两个BUG，1：半透明表情的Rect计算方式有问题，2：重新优化点击后的灰色背景的大小改为计算，而不是设置死，3：添加了顶部的一条细线
//

#import "QEmotionBoardView.h"


@class UIEmotionPageView;

@protocol UIEmotionPageViewDelegate <NSObject>

@optional
- (void)emotionPageView:(UIEmotionPageView *)emotionPageView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index;
- (void)emotionPageViewDidLayoutEmotions:(UIEmotionPageView *)emotionPageView;
@end

/// 表情面板每一页的cell，在drawRect里将所有表情绘制上去，同时自带一个末尾的删除按钮
@interface UIEmotionPageView : UIView

@property(nonatomic, weak) QEmotionBoardView<UIEmotionPageViewDelegate> *delegate;

/// 表情被点击时盖在表情上方用于表示选中的遮罩
@property(nonatomic, strong) UIView *emotionSelectedBackgroundView;

/// 表情面板右下角的删除按钮
@property(nonatomic, weak) UIButton *deleteButton;

/// 删除按钮位置的 (x,y) 的偏移
@property(nonatomic, assign) CGPoint deleteButtonOffset;

/// 所有表情的 Layer
@property(nonatomic, strong) NSMutableArray<CALayer *> *emotionLayers;

/// 分配给当前pageView的所有表情
@property(nonatomic, copy) NSArray<QEmotion *> *emotions;

/// 记录当前pageView里所有表情的可点击区域的rect，在drawRect:里更新，在tap事件里使用
@property(nonatomic, strong) NSMutableArray<NSValue *> *emotionHittingRects;

/// 负责实现表情的点击
@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

/// 整个pageView内部的padding
@property(nonatomic, assign) UIEdgeInsets padding;

/// 每个pageView能展示表情的行数
@property(nonatomic, assign) NSInteger numberOfRows;

/// 每个表情的绘制区域大小，表情图片最终会以UIViewContentModeScaleAspectFit的方式撑满这个大小。表情计算布局时也是基于这个大小来算的。
@property(nonatomic, assign) CGSize emotionSize;

/// 点击表情时出现的遮罩要在表情所在的矩形位置拓展多少空间，负值表示遮罩比emotionSize更大，正值表示遮罩比emotionSize更小。最终判断表情点击区域时也是以拓展后的区域来判定的
@property(nonatomic, assign) UIEdgeInsets emotionSelectedBackgroundExtension;

/// 表情与表情之间的水平间距的最小值，实际值可能比这个要大一点（pageView会把剩余空间分配到表情的水平间距里）
@property(nonatomic, assign) CGFloat minimumEmotionHorizontalSpacing;

/// debug模式会把表情的绘制矩形显示出来
@property(nonatomic, assign) BOOL debug;

@property(nonatomic, assign, readonly) BOOL needsLayoutEmotions;

@property(nonatomic, assign) CGRect previousLayoutFrame;

@end

@implementation UIEmotionPageView

//发送按钮，删除按钮的宽高
const int UISendButtonWidth = 52;
const int UISendButtonHeight = 41;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.emotionSelectedBackgroundView = [[UIView alloc] init];
        self.emotionSelectedBackgroundView.userInteractionEnabled = NO;
        self.emotionSelectedBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.16];
        self.emotionSelectedBackgroundView.layer.cornerRadius = 3;
        self.emotionSelectedBackgroundView.alpha = 0;
        [self addSubview:self.emotionSelectedBackgroundView];
        
        self.emotionHittingRects = [[NSMutableArray alloc] init];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
    return self;
}

- (CGRect)frameForDeleteButton:(__kindof UIView *)deleteButton {
    CGRect rect = deleteButton.frame;
    CGFloat x = CGRectGetWidth(self.bounds) - self.padding.right - CGRectGetWidth(deleteButton.frame) - (self.emotionSize.width - CGRectGetWidth(deleteButton.frame)) / 2.0 + self.deleteButtonOffset.x;
    CGFloat y = CGRectGetHeight(self.bounds) - self.padding.bottom - CGRectGetHeight(deleteButton.frame) - (self.emotionSize.height - CGRectGetHeight(deleteButton.frame)) / 2.0 + self.deleteButtonOffset.y;
    rect.origin.x = x;
    rect.origin.y = y;
    return rect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.deleteButton.superview == self) {
        // 删除按钮必定布局到最后一个表情的位置，且与表情上下左右居中
        self.deleteButton.frame = [self frameForDeleteButton:self.deleteButton];
    }
    BOOL isSizeChanged = !CGSizeEqualToSize(self.previousLayoutFrame.size, self.frame.size);
    self.previousLayoutFrame = self.frame;
    if (isSizeChanged) {
        [self setNeedsLayoutEmotions];
    }
    [self layoutEmotionsIfNeeded];
}

- (void)setNeedsLayoutEmotions {
    _needsLayoutEmotions = YES;
}

- (void)setEmotions:(NSArray<QEmotion *> *)emotions {
    if ([_emotions isEqualToArray:emotions]) return;
    _emotions = emotions;
    [self setNeedsLayoutEmotions];
    [self setNeedsLayout];
}

- (void)layoutEmotionsIfNeeded {
    if (!self.needsLayoutEmotions) return;
    _needsLayoutEmotions = NO;
    [self.emotionHittingRects removeAllObjects];
    
    CGSize contentSize = UIEdgeInsetsInsetRect(self.bounds, self.padding).size;
    //根据小表情的自身大小+水平最小间距，算出来一行有多少个表情
    NSInteger emotionCountPerRow = (contentSize.width + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
    //最后算出来的 实际表情之间的水平间距
    CGFloat emotionHorizontalSpacing = (contentSize.width - emotionCountPerRow * self.emotionSize.width) / (emotionCountPerRow - 1);
    //最后算出来的 实际表情之间的垂直间距
    CGFloat emotionVerticalSpacing = (contentSize.height - self.numberOfRows * self.emotionSize.height) / (self.numberOfRows - 1);
    //最后计算出来，点击表情的扩展点击范围 ；dqdebug
    self.emotionSelectedBackgroundExtension = UIEdgeInsetsMake(-emotionVerticalSpacing/2, -emotionHorizontalSpacing/2, -emotionVerticalSpacing/2, -emotionHorizontalSpacing/2);
    CGPoint emotionOrigin = CGPointZero;
    NSInteger emotionCount = self.emotions.count;
    if (!self.emotionLayers) {
        self.emotionLayers = [NSMutableArray arrayWithCapacity:emotionCount];
    }
    for (NSInteger i = 0; i < emotionCount; i++) {
        CALayer *emotionlayer = nil;
        if (i < self.emotionLayers.count) {
            emotionlayer = self.emotionLayers[i];
        } else {
            emotionlayer = [CALayer layer];
            emotionlayer.contentsScale = [[UIScreen mainScreen] scale];
            [self.emotionLayers addObject:emotionlayer];
            [self.layer addSublayer:emotionlayer];
        }
        
        emotionlayer.contents = (__bridge id)(self.emotions[i].image.CGImage);//使用layer效率更高
        NSInteger row = i / emotionCountPerRow;
        emotionOrigin.x = self.padding.left + (self.emotionSize.width + emotionHorizontalSpacing) * (i % emotionCountPerRow);
        emotionOrigin.y = self.padding.top + (self.emotionSize.height + emotionVerticalSpacing) * row;
        CGRect emotionRect = CGRectMake(emotionOrigin.x, emotionOrigin.y, self.emotionSize.width, self.emotionSize.height);
        CGRect emotionHittingRect = UIEdgeInsetsInsetRect(emotionRect, self.emotionSelectedBackgroundExtension);
        [self.emotionHittingRects addObject:[NSValue valueWithCGRect:emotionHittingRect]];
        emotionlayer.frame = emotionRect;
        emotionlayer.hidden = NO;
    }
    
    if (self.emotionLayers.count > emotionCount) {
        for (NSInteger i = self.emotionLayers.count - emotionCount - 1; i < self.emotionLayers.count; i++) {
            self.emotionLayers[i].hidden = YES;
        }
    }
    if ([self.delegate respondsToSelector:@selector(emotionPageViewDidLayoutEmotions:)]) {
        [self.delegate emotionPageViewDidLayoutEmotions:self];
    }
}

//监听整个大面板的点击事件，然后找到具体的某个表情
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    for (NSInteger i = 0; i < self.emotionHittingRects.count; i ++) {
        CGRect rect = [self.emotionHittingRects[i] CGRectValue];
        if (CGRectContainsPoint(rect, location)) {
            CALayer *layer = self.emotionLayers[i];
            if (layer.opacity < 0.2) return;
            QEmotion *emotion = self.emotions[i];
            self.emotionSelectedBackgroundView.frame = rect;
            [UIView animateWithDuration:.08 animations:^{
                self.emotionSelectedBackgroundView.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.08 animations:^{
                    self.emotionSelectedBackgroundView.alpha = 0;
                } completion:nil];
            }];
            if ([self.delegate respondsToSelector:@selector(emotionPageView:didSelectEmotion:atIndex:)]) {
                [self.delegate emotionPageView:self didSelectEmotion:emotion atIndex:i];
            }
            if (self.debug) {
//                QMUILog(NSStringFromClass(self.class), @"点击的是当前页里的第 %@ 个表情，%@", @(i), emotion);
            }
            return;
        }
    }
}

- (CGSize)verticalSizeThatFits:(CGSize)size emotionVerticalSpacing:(CGFloat)emotionVerticalSpacing {
    CGSize contentSize = UIEdgeInsetsInsetRect(CGRectMake(0, 0, size.width, size.height), self.padding).size;
    NSInteger emotionCountPerRow = (contentSize.width + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
    NSInteger row = ceil(self.emotions.count / (emotionCountPerRow * 1.0));
    CGFloat height = (self.emotionSize.height + emotionVerticalSpacing) * row - emotionVerticalSpacing + ( self.padding.top + self.padding.bottom);
    return CGSizeMake(size.width, height);
}

- (void)updateDeleteButton:(UIButton *)deleteButton {
    _deleteButton = deleteButton;
    [self addSubview:deleteButton];
}

- (void)setDeleteButtonOffset:(CGPoint)deleteButtonOffset {
    _deleteButtonOffset = deleteButtonOffset;
    [self setNeedsLayout];
}


@end

@interface UIEmotionVerticalScrollView : UIScrollView
@property(nonatomic, strong) UIEmotionPageView *pageView;
@end

@implementation UIEmotionVerticalScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _pageView = [[UIEmotionPageView alloc] init];
        self.pageView.deleteButton.hidden = YES;
        [self addSubview:self.pageView];
    }
    return self;
}

- (void)setEmotions:(NSArray<QEmotion *> *)emotions
                          emotionSize:(CGSize)emotionSize
      minimumEmotionHorizontalSpacing:(CGFloat)minimumEmotionHorizontalSpacing
               emotionVerticalSpacing:(CGFloat)emotionVerticalSpacing
   emotionSelectedBackgroundExtension:(UIEdgeInsets)emotionSelectedBackgroundExtension
                        paddingInPage:(UIEdgeInsets)paddingInPage {
    UIEmotionPageView *pageView = self.pageView;
    pageView.emotions = emotions;
    pageView.padding = paddingInPage;
    CGSize contentSize = CGSizeMake(self.bounds.size.width - [self edgeInsetsGetHorizontalValue:paddingInPage], self.bounds.size.height - [self edgeInsetsGetVerticalValue:paddingInPage]);
    NSInteger emotionCountPerRow = (contentSize.width + minimumEmotionHorizontalSpacing) / (emotionSize.width + minimumEmotionHorizontalSpacing);
    pageView.numberOfRows = ceil(emotions.count / (CGFloat)emotionCountPerRow);
    pageView.emotionSize =emotionSize;
    pageView.emotionSelectedBackgroundExtension = emotionSelectedBackgroundExtension;
    pageView.minimumEmotionHorizontalSpacing = minimumEmotionHorizontalSpacing;
    [pageView setNeedsLayout];
    CGSize size = [pageView verticalSizeThatFits:self.bounds.size emotionVerticalSpacing:emotionVerticalSpacing];
    self.pageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.contentSize = size;
}

- (void)adjustEmotionsAlphaWithFloatingRect:(CGRect)floatingRect {
    CGSize contentSize = CGSizeMake(self.contentSize.width - [self edgeInsetsGetHorizontalValue:self.pageView.padding], self.contentSize.height - [self edgeInsetsGetVerticalValue:self.pageView.padding]);
    NSInteger emotionCountPerRow = (contentSize.width + self.pageView.minimumEmotionHorizontalSpacing) / (self.pageView.emotionSize.width + self.pageView.minimumEmotionHorizontalSpacing);
    CGFloat emotionVerticalSpacing = (contentSize.height - self.pageView.numberOfRows * self.pageView.emotionSize.height) / (self.pageView.numberOfRows - 1);
    //最后算出来的 实际表情之间的水平间距
    CGFloat emotionHorizontalSpacing = (contentSize.width - emotionCountPerRow * self.pageView.emotionSize.width) / (emotionCountPerRow - 1);
    NSInteger columnIndexLeft = ceil((floatingRect.origin.x - self.pageView.padding.left) / (self.pageView.emotionSize.width + emotionHorizontalSpacing)) - 1;
    NSInteger columnIndexRight = emotionCountPerRow - 1;
    CGFloat rowIndexTop = ((floatingRect.origin.y - self.pageView.padding.top) / (self.pageView.emotionSize.height + emotionVerticalSpacing)) - 1;
    for (NSInteger i = 0; i < self.pageView.emotionLayers.count; i++) {
        NSInteger row = (i / emotionCountPerRow);
        NSInteger column = (i % emotionCountPerRow);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (column >= columnIndexLeft && column <= columnIndexRight && row > rowIndexTop) {
            if (row == ceil(rowIndexTop)) {
                CGFloat intersectAreaHeight = floatingRect.origin.y - self.pageView.emotionLayers[i].frame.origin.y;
                CGFloat percent = intersectAreaHeight / self.pageView.emotionSize.height;
                self.pageView.emotionLayers[i].opacity = percent * percent;
            } else {
                self.pageView.emotionLayers[i].opacity = 0;
            }
        } else {
            self.pageView.emotionLayers[i].opacity = 1.0f;
        }
        [CATransaction commit];
    }
}


- (CGFloat)edgeInsetsGetVerticalValue:(UIEdgeInsets )insets {
    return insets.top + insets.bottom;
}

- (CGFloat)edgeInsetsGetHorizontalValue:(UIEdgeInsets )insets {
    return insets.left + insets.right;
}


@end

@interface QEmotionBoardView ()<UIEmotionPageViewDelegate ,UIScrollViewDelegate>
/// 用于展示表情面板的竖向滚动 scrollView，布局撑满整个控件
@property(nonatomic, strong, readonly) UIEmotionVerticalScrollView *verticalScrollView;
@property(nonatomic, strong) NSMutableArray<NSArray<QEmotion *> *> *pagedEmotions;
@property(nonatomic, assign) BOOL debug;
@end

@implementation QEmotionBoardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitializedWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithFrame:CGRectZero];
    }
    return self;
}

- (void)didInitializedWithFrame:(CGRect)frame {
    self.debug = NO;
    
    self.pagedEmotions = [[NSMutableArray alloc] init];
    
    _verticalScrollView = [[UIEmotionVerticalScrollView alloc] init];
    if (@available(iOS 11, *)) {
        self.verticalScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _verticalScrollView.delegate = self;
    [self addSubview:self.verticalScrollView];
    
    _sendButton = [[UIButton alloc] init];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(didSelectSendButton:) forControlEvents:UIControlEventTouchUpInside];
//    self.sendButton.contentEdgeInsets = UIEdgeInsetsMake(5, 17, 5, 17);
    [self addSubview:self.sendButton];

    _deleteButton = [[UIButton alloc] init];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [_deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"q_white_btn" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(didSelectDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
//    _deleteButton.layer.cornerRadius = 6;
//    _deleteButton.layer.masksToBounds = YES;
    [self addSubview:_deleteButton];
    
    
    //输入条的上方添加一行细线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1 / [UIScreen mainScreen].scale)];
    if (@available(iOS 11.0, *)) {
        NSBundle *bundle = [NSBundle bundleForClass:[UIEmotionPageView class]];
        lineView.backgroundColor = [UIColor colorNamed:@"q_border223" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        lineView.backgroundColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1];
    }
    [self addSubview:lineView];
    self.topLineView = lineView;
}

- (void)setEmotions:(NSArray<QEmotion *> *)emotions {
    _emotions = emotions;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.sendButton.frame = CGRectMake(CGRectGetWidth(self.frame) - self.sendButtonMargins.right - UISendButtonWidth, CGRectGetHeight(self.frame) - self.qmui_safeAreaInsets.bottom - self.sendButtonMargins.bottom - UISendButtonHeight, UISendButtonWidth, UISendButtonHeight);

    UIEdgeInsets paddingInPage = self.paddingInPage;
    paddingInPage.bottom = self.paddingInPage.bottom + self.qmui_safeAreaInsets.bottom;
    
    CGRect verticalScrollViewFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsZero);
    self.verticalScrollView.frame = verticalScrollViewFrame;
    [self.verticalScrollView setEmotions:self.emotions
                             emotionSize:self.emotionSize
         minimumEmotionHorizontalSpacing:self.minimumEmotionHorizontalSpacing
                  emotionVerticalSpacing:self.emotionVerticalSpacing
      emotionSelectedBackgroundExtension:self.emotionSelectedBackgroundExtension
                           paddingInPage:paddingInPage];
    self.verticalScrollView.pageView.delegate = self;

    static CGFloat spacingBetweenDeleteButtonAndSendButton = 10.0f;
    
    self.deleteButton.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - spacingBetweenDeleteButtonAndSendButton - self.deleteButtonOffset.x -  UISendButtonWidth, self.sendButton.frame.origin.y, UISendButtonWidth, UISendButtonHeight);
    
    self.topLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1 / [UIScreen mainScreen].scale);
}


- (void)adjustEmotionsAlpha {
    CGFloat x = MIN(self.deleteButton.frame.origin.x, self.sendButton.frame.origin.x);
    CGFloat y = MIN(self.deleteButton.frame.origin.y, self.sendButton.frame.origin.y);
    CGFloat width = CGRectGetMaxX(self.sendButton.frame) - CGRectGetMinX(self.deleteButton.frame);
    CGFloat height = MAX(CGRectGetMaxY(self.deleteButton.frame), CGRectGetMaxY(self.sendButton.frame)) - MIN(CGRectGetMinY(self.deleteButton.frame), CGRectGetMinY(self.sendButton.frame));
    CGRect buttonGruopRect = CGRectMake(x, y, width, height);
    CGRect floatingRect = [self.verticalScrollView convertRect:buttonGruopRect fromView:self];
    [self.verticalScrollView adjustEmotionsAlphaWithFloatingRect:floatingRect];
}

- (UIEdgeInsets)qmui_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (IBAction)didSelectDeleteButton:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(emotionViewDidSelectDeleteButton:)]){
        [_delegate emotionViewDidSelectDeleteButton:self];
    }
}

- (IBAction)didSelectSendButton:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(emotionViewDidSelectSendButton:)]){
        [_delegate emotionViewDidSelectSendButton:self];
    }
}

#pragma mark - UIAppearance Setter

- (void)setSendButtonTitleAttributes:(NSDictionary *)sendButtonTitleAttributes {
    _sendButtonTitleAttributes = sendButtonTitleAttributes;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.sendButton currentTitle] attributes:_sendButtonTitleAttributes] forState:UIControlStateNormal];
}

- (void)setSendButtonBackgroundColor:(UIColor *)sendButtonBackgroundColor {
    _sendButtonBackgroundColor = sendButtonBackgroundColor;
    self.sendButton.backgroundColor = _sendButtonBackgroundColor;
}

- (void)setSendButtonCornerRadius:(CGFloat)sendButtonCornerRadius {
    _sendButtonCornerRadius = sendButtonCornerRadius;
    self.sendButton.layer.cornerRadius = _sendButtonCornerRadius;
    self.sendButton.layer.masksToBounds = YES;
}

- (void)setDeleteButtonBackgroundColor:(UIColor *)deleteButtonBackgroundColor {
    _deleteButtonBackgroundColor = deleteButtonBackgroundColor;
    self.deleteButton.backgroundColor = deleteButtonBackgroundColor;
}

- (void)setDeleteButtonImage:(UIImage *)deleteButtonImage {
    _deleteButtonImage = deleteButtonImage;
    [self.deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
}

- (void)setDeleteButtonCornerRadius:(CGFloat)deleteButtonCornerRadius {
    _deleteButtonCornerRadius = deleteButtonCornerRadius;
    self.deleteButton.layer.cornerRadius = deleteButtonCornerRadius;
    self.deleteButton.layer.masksToBounds = YES;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        [self adjustEmotionsAlpha];
    }
}

#pragma mark - <UIEmotionPageViewDelegate>
- (void)emotionPageView:(UIEmotionPageView *)emotionPageView didSelectEmotion:(QEmotion *)emotion atIndex:(NSInteger)index {
    //再回调给vc，之前QMUI官方demo里这里是用的block，为了兼容swift和代码清晰，我修改成了delegate
    if ([self.delegate respondsToSelector:@selector(emotionView:didSelectEmotion:atIndex:)]){
        NSInteger index = [self.emotions indexOfObject:emotion];
        [self.delegate emotionView:self didSelectEmotion:emotion atIndex:index];
    }
}

- (void)emotionPageViewDidLayoutEmotions:(UIEmotionPageView *)emotionPageView {
    [self adjustEmotionsAlpha];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    return self.verticalScrollView;
}

@end

@interface QEmotionBoardView (UIAppearance)

@end

@implementation QEmotionBoardView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    
    NSBundle *bundle = [NSBundle bundleForClass:[QEmotionBoardView class]];
    
    QEmotionBoardView *appearance = [QEmotionBoardView appearance];
    appearance.backgroundColor = nil;
    appearance.deleteButtonImage = [UIImage imageNamed:@"q_emotion_delete" inBundle:bundle compatibleWithTraitCollection:nil];
    appearance.paddingInPage = UIEdgeInsetsMake(18, 18, 65, 18); //65是滚到底部时候的一大片空白，微信也有
    appearance.emotionSize = CGSizeMake(34, 34);
    appearance.minimumEmotionHorizontalSpacing = 16;
    appearance.sendButtonTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17], NSForegroundColorAttributeName: [UIColor whiteColor]};
    appearance.sendButtonBackgroundColor = [UIColor colorWithRed:32/255.0 green:191/255.0 blue:100/255.0 alpha:1];;
    appearance.sendButtonCornerRadius = 4;
    appearance.sendButtonMargins = UIEdgeInsetsMake(0, 0, 18, 18);//要和上面的paddingInPage一致
    appearance.pageControlMarginBottom = 22;
    appearance.deleteButtonCornerRadius = 4;
    appearance.emotionVerticalSpacing = 16;
    
    UIPageControl *pageControlAppearance = [UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[QEmotionBoardView class]]];
    pageControlAppearance.pageIndicatorTintColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    pageControlAppearance.currentPageIndicatorTintColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1];
}

@end
