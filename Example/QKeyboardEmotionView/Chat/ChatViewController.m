//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//


#import "ChatViewController.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource>
{

}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray<NSString *> *messageArray;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天界面";

    _messageArray = [NSMutableArray new];

    for (int i = 0; i < 20; i++){
        [_messageArray addObject:[NSString stringWithFormat:@"聊天消息------%d",i]];
    }

    //按住说话功能 由你自己实现
//    self.inputView.recordButton addTarget:
}

//注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考ChatXibViewController
#pragma mark - NeedOverride
- (CGFloat)tableViewBottomEdgeInsets {
    return self.navigationController.navigationBar.translucent ? 0 : (UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
}


#pragma mark - Override
- (void)initBodyView {
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithRed:(248)/255.0f green:(248)/255.0f blue:(246)/255.0f alpha:1];
    [self.view addSubview:_tableView];
}

#pragma mark - Override
//整个输入View的高度发生变化（整个View包含bar和表情栏或者键盘）
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {

    BOOL alreadyAtBottom = self.alreadyAtBottom;
   
    //注意：如果tableview布局添加了约束，那么ios系统会自己处理tableview高度与导航栏是否透明之间的关系。所以这里的insets.bottom的值需要你的布局不同，做出相对应的改动。我这里演示的是非约束的情况下的处理方式，如果你用约束，请参考DiscussViewController
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = 0;
    insets.bottom = wholeInputViewHeight + [self tableViewBottomEdgeInsets];
    //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    if (reason == WholeInputViewHeightDidChangeReasonWillAddToSuperView) {
        //聊天界面，初始化array后，要滚到底部
        //我是这样实现的滚到底部的，你可以自己更改
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
        });
        return;
    }
    
    //如果你有更好的处理tableview的滚到底部的动画方法，请告诉我
    if (alreadyAtBottom) {
        //用自己的animations，问题就是会闪屏，尤其是tableview滚在上方时候 闪的越狠；好处是tableview在切换时候很跟手
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self scrollToBottomAnimated:NO];
        } completion:nil];
    } else {
        //用系统的scroll的Animated，不会闪屏，但是问题是tableview在切换时候不那么跟手
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
    
    self.inputView.inputTextView.text = nil;
    
    [self.tableView reloadData];
    
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Private
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}

- (void)resetUIEdgeInsets:(CGFloat)wholeInputViewHeight {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = 0;
    insets.bottom = wholeInputViewHeight;
    //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
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
    
    UITableViewCell *cell = [[UITableViewCell alloc]
            initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row %2 == 1) {
//        cell.contentView.backgroundColor = [UIColor colorWithRed:(184)/255.0f green:(212)/255.0f blue:(235)/255.0f alpha:1];
           cell.imageView.image = [UIImage imageNamed:@"user_photo"];
        
       }else{
//           cell.contentView.backgroundColor = [UIColor colorWithRed:(254)/255.0f green:(183)/255.0f blue:(89)/255.0f alpha:1];
           cell.imageView.image = [UIImage imageNamed:@"user_photo2"];
       }
     
    cell.textLabel.text = _messageArray[indexPath.row];

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //用户手动拖动tableview，隐藏所有面板和键盘
    [self.keyboardManager hideAllBoardView];
}

@end
