//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021-8-3.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//


#import "ChatViewController.h"
#import "ChatCell.h"
#import "QEmotionHelper.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource>
{

}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray<NSString *> *messageArray;

@property(nonatomic,strong) UINavigationBarAppearance *lastAppearance API_AVAILABLE(ios(13.0));

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天界面";

    //这里你的data肯定是要从本地数据库里获取
    _messageArray = [NSMutableArray new];
    for (int i = 0; i < 20; i++){
        [_messageArray addObject:[NSString stringWithFormat:@"聊天消息----%d[微笑][微笑][微笑]",i]];
    }
    
    [self.tableView registerClass:[ChatCell class] forCellReuseIdentifier:@"ChatCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //因为聊天界面一打开就要滚到底部。在ios15上如果你用系统的导航栏，tableView立即滚到底部会导致导航栏闪现
    //想彻底解决这个问题，目前DQ只想到两个方案：
    //1 在viewDidLoad里用 += 计算Cell的总高度，一旦高于tableView.height，就设置scrollEdgeAppearance，然后滚到底部再把scrollEdgeAppearance设置回去
    //2 用kvo监听tableView的contentSize，如果大于tableView.height，就设置scrollEdgeAppearance。这种方法的前提是需要你去实现estimatedHeightForRowAtIndexPath
    //以上两种方案都需要你自己做好Cell的高度缓存，并解耦Cell高度计算方法。本文就不展示了，毕竟本文只是个键盘类。
    
    //本文只是粗糙的判断一下data是否大于1，这样的话，会出现的问题是：如果cell数量大于2且小于tableView可滚动的数量时导航栏的那根线会显示有个消失动画

    if (@available(iOS 15.0, *)) {
        self.lastAppearance = self.navigationController.navigationBar.scrollEdgeAppearance;
        if (_messageArray.count > 1){
            //移除ios15的导航栏的渐变特性
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        }
    }
    
    //按住说话功能 由你自己实现
//    self.inputView.recordButton addTarget:
}

//注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考ChatXibViewController
#pragma mark - NeedOverride
- (CGFloat)navigationBarHeight {
    return self.navigationController.navigationBar.translucent ? 0 : (UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
}

#pragma mark - Override
- (void)initBodyView {
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithRed:(237)/255.0f green:(237)/255.0f blue:(237)/255.0f alpha:1];
    [self.view addSubview:_tableView];
}

#pragma mark - Override
//整个输入View的高度发生变化（整个View包含bar和表情栏或者键盘，但是不包含底部安全区高度）
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {

    BOOL alreadyAtBottom = self.alreadyAtBottom;
   
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = 0;
    insets.bottom = wholeInputViewHeight + [self navigationBarHeight];
    //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    if (reason == WholeInputViewHeightDidChangeReasonWillAddToSuperView) {
        //聊天界面，tableView要滚到底部
        dispatch_async(dispatch_get_main_queue(), ^{

            [self scrollToBottomAnimated:NO];

            if (@available(iOS 15.0, *)) {
                //复原ios15的系统导航栏的显示效果
                self.navigationController.navigationBar.scrollEdgeAppearance = self.lastAppearance;
                //释放掉
                self.lastAppearance = nil;
            }
        });
        return;
    }
    
    if (reason == WholeInputViewHeightDidChangeReasonTextDidSend) {
        //是点击“发送”按钮清空输入框里的多行文字导致的输入栏高度变化
        return;
    }

    //如果你有更好的处理tableview的滚到底部的动画方法，请告诉我
    if (alreadyAtBottom) {
        //用自己的animations，问题就是会闪屏，尤其是tableview滚在上方时候 闪的越狠；好处是tableview在切换时候很跟手
        
        [UIView animateWithDuration:keyboardManager.inputBarHeightChangeAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self scrollToBottomAnimated:NO];
        } completion:nil];
    } else {
//        用系统的scroll的Animated，不会闪屏，但是问题是tableview在切换时候不那么跟手
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark - Override
/**
 *  点击了系统键盘的发送按钮
 *  @param inputText 目标文本消息
 */
- (void)sendTextMessage:(NSString *)inputText {
    
    [_messageArray addObject:inputText];
    
    //请不要用inputTextView.text = nil来清空文本，具体原因看方法注释
    //@return 0：当前inputText只有一行；非0：动画时长
    NSTimeInterval animationDuration = [self.inputView clearInputTextBySend];

    if (animationDuration == 0){
        //如果textView的文本只有一行，那么清空输入框的时候，不会走onWholeInputViewHeightDidChange回调，也不会重新设置tableView的contentInset。所以就无需延时reloadData
        [self reloadDataAndScrollToBottomAnimated:YES];
    } else {
        
        //textView的文本大于一行，那么清空输入框的时候，会重设tableView的contentInset（并且我还是在0.2秒的动画里重设的），如果这时候reloadData，在低性能设备上会出现tableView来回上下移动的问题
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(),  ^{
            
            [self reloadDataAndScrollToBottomAnimated:YES];
        });
    }
}

#pragma mark - Private
//滚到底部
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

//reloadData并滚到底部
- (void)reloadDataAndScrollToBottomAnimated:(BOOL)animated {
    
    [self.tableView reloadData];
    
    BOOL resultAnimated = animated;
    if (@available(iOS 13.0, *)) {
    } else {
        //在ios12中，滚到底部再animal总是会出现最后一个Cell滚动异常，所以我干脆禁止了ios12的动画
        resultAnimated = NO;
    }
    // ios 13、15都是ok的
    [self scrollToBottomAnimated:resultAnimated];
}

- (BOOL)alreadyAtBottom {
    if (((NSInteger)self.tableView.contentOffset.y) == ((NSInteger)self.tableView.contentSize.height + self.scrollviewContentInset.bottom - CGRectGetHeight(self.tableView.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)scrollviewContentInset {
    if (@available(iOS 11, *)) {
        return self.tableView.adjustedContentInset;
    } else {
        return self.tableView.contentInset;
    }
}

#pragma mark - UITableViewDataSource
//返回列表分组数，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//返回列表每个分组section拥有cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row %2 == 1) {
        cell.avatarImageView.image = [UIImage imageNamed:@"user_photo"];
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"user_photo2"];
    }
     
    QEmotionHelper *faceManager = [QEmotionHelper sharedEmotionHelper];
    
    //这里应该做高度缓存的，我这里只是demo就省略了，你自己做高度缓存
    cell.nameLabel.attributedText = [faceManager attributedStringByText:_messageArray[indexPath.row] font:cell.nameLabel.font];

    [cell resetContentLabelFrame:[cell heightForContent:cell.nameLabel.attributedText]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //这里应该做高度缓存的，我这里只是demo就省略了，你自己做高度缓存
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    QEmotionHelper *faceManager = [QEmotionHelper sharedEmotionHelper];
//    46是头像的高度； + 12 + 12是padding
    return MAX(46, [cell heightForContent:[faceManager attributedStringByText:_messageArray[indexPath.row] font:cell.nameLabel.font]])  + 12 + 12;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //用户手动拖动tableview，隐藏所有面板和键盘
    [self.keyboardManager hideAllBoardView];
}

@end
