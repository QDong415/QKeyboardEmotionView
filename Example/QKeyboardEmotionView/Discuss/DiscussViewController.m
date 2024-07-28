//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//


#import "DiscussViewController.h"

@interface DiscussViewController ()<UITableViewDelegate,UITableViewDataSource>
{

}

@property(nonatomic,strong) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSMutableArray<NSString *> *messageArray;

//最后一次点击选中的cell的indexPath
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;


@end

@implementation DiscussViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"朋友圈界面";

    _messageArray = [NSMutableArray new];
    //击一条Cell时再弹出键盘，且
    for (int i = 0; i < 20; i++){
        [_messageArray addObject:[NSString stringWithFormat:@"点键盘锁定当前Cell----%d",i]];
    }

}

#pragma mark - Override
- (BOOL)belowViewController {
    //输入条平时是否在vc下面（NO=平时也显示，YES=平时不显示)
    return _belowViewController;
}

- (QInputBarViewConfiguration *)inputBarViewConfiguration {
    //输入条配置，子类可以重写
    QInputBarViewConfiguration *inputBarViewConfiguration = [QInputBarViewConfiguration defaultInputBarViewConfiguration];
    inputBarViewConfiguration.voiceButtonHidden = YES;//隐藏语音按钮
    inputBarViewConfiguration.extendButtonHidden = YES;//隐藏拓展按钮
    return inputBarViewConfiguration;
}

//整个输入View的高度发生变化（整个View包含bar和表情栏或者键盘，但是不包含底部安全区高度）
- (void)keyboardManager:(QKeyboardManager *)keyboardManager onWholeInputViewHeightDidChange:(CGFloat)wholeInputViewHeight reason:(WholeInputViewHeightDidChangeReason)reason {

    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = 0;
    insets.bottom = wholeInputViewHeight + 0;//如果你的tableview不是用约束，而是用frame，那么就把0改成： (self.navigationController.navigationBar.translucent ? 0 : (UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height));
    
    //对应聊天界面，随着底部输入框的frame.y的变化，为了保持tableview一直都在输入条的上方，修改tableview的contentInset
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;

    if (self.lastSelectedIndexPath && reason != WholeInputViewHeightDidChangeReasonBoardDidHide && reason != WholeInputViewHeightDidChangeReasonTextDidSend ) {
        [self scrollToRowAtIndexPath:self.lastSelectedIndexPath];
    }
}

/**
 *  点击了系统键盘的发送按钮
 *  @param inputText 目标文本消息
 */
- (void)sendTextMessage:(NSString *)inputText {
    
    //只是演示
    [_messageArray addObject:inputText];
    
    //清空输入框，如果是聊天界面就不要用这句
    self.inputBarView.inputTextView.text = nil;
    
    //隐藏键盘
    [self.keyboardManager hideAllBoardView];
    
    [self.tableView reloadData];
    
}

#pragma mark - Private
//通过setContentOffset的方式，让tableview滚动到指定的indexpath
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //方式1：采用scrollToRowAtIndexPath的方式。这个方式是最好的，非常粘合inputView的frameY
    [UIView animateWithDuration:self.keyboardManager.inputBarHeightChangeAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    } completion:nil];
    
    //方式2：采用setContentOffset的方式。效果不是特别好，inputView.frameY已经动画结束了，他才动
//    CGRect rectInTableview = [self.tableView rectForRowAtIndexPath:indexPath];
//
//    CGFloat kTopNavHeight = UIApplication.sharedApplication.statusBarFrame.size.height + 44;
//    if (CGRectGetMaxY(rectInTableview) < CGRectGetMinY(self.inputBarView.frame) - kTopNavHeight){
//        return;
//    }
//
//    float resultY = rectInTableview.origin.y-self.tableView.contentOffset.y - kTopNavHeight + self.tableView.contentOffset.y - (CGRectGetMinY(self.inputBarView.frame) - rectInTableview.size.height - kTopNavHeight);
//    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, resultY) animated:YES];

    //无脑把indexPath这个cell滚到导航栏下的第一个
//    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, rectintableview.origin.y-self.tableView.contentOffset.y - kTopNavHeight + self.tableView.contentOffset.y) animated:YES];
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
 
        cell.imageView.image = [UIImage imageNamed:@"user_photo"];
        
    } else {
        cell.imageView.image = [UIImage imageNamed:@"user_photo2"];
    }
    
    cell.textLabel.text = _messageArray[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.lastSelectedIndexPath = indexPath;
    [self.inputBarView.inputTextView becomeFirstResponder];
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastSelectedIndexPath = nil;
    [self.keyboardManager hideAllBoardView];
}

@end
