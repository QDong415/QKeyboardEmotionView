//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by QDong on 2021/7/14.
//

#import "RootViewController.h"
#import "CommonViewController.h"
#import "ChatViewController.h"
#import "ChatSendButtonViewController.h"
#import "SubmitViewController.h"
#import "DiscussViewController.h"
#import "CommonCustomViewController.h"
#import "ChatXibViewController.h"
#import "TextFieldViewController.h"
#import "SendButtonViewController.h"
#import "QKeyboardEmotionView_Example-Swift.h"

@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
}


@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"入口";
    
    self.navigationController.navigationBar.translucent = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    //设置列表数据源
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}



//返回列表分组数，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//返回列表每个分组section拥有cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]
            initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@""];
    cell.textLabel.numberOfLines = 0;
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"《普通界面》";
        }
            break;
        case 1:{
            cell.textLabel.text = @"《普通界面 + 自定义面板》";
        }
            break;
        case 2:{
            cell.textLabel.text = @"《聊天界面》\n 特点1：弹出键盘时候tableview自动滚到底部\n 特点2：输入文字换行时候tableview也会往上移动";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"《聊天界面 + tableview基于约束》";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"《聊天界面 + 右侧发送按钮》";
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"《朋友圈界面》\n 特点1：平时不显示底部输入栏\n 特点2：点击cell后显示输入栏，且当前cell自动滚动到输入栏上方\n 特点3：输入文字换行时候当前cell也会往上移动";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"《朋友圈界面 + 键盘一直在底部》\n别的特点和朋友圈一致";
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"《发动态界面 + 底部是工具栏》\n 特点1：输入栏自定义\n 特点2：输入栏可一直在底部，也可以弹出键盘时候再显示";
        }
            break;
        case 8:
        {
            cell.textLabel.text = @"《TextField界面》";
        }
            break;
        case 9:
        {
            cell.textLabel.text = @"《输入条右边是“发送”按钮》";
        }
            break;
        case 10:
        {
            cell.textLabel.text = @"《Swift聊天界面》";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:{//"普通界面"
            CommonViewController *vc = [CommonViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {//"普通界面（自定义面板）"
            CommonCustomViewController *vc = [CommonCustomViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {//"聊天界面"
            ChatViewController *vc = [ChatViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {//"聊天界面（tableview基于约束）"
            ChatXibViewController *vc = [ChatXibViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {//"聊天界面（右侧发送按钮）"
            ChatSendButtonViewController *vc = [ChatSendButtonViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 5:
        {//"朋友圈界面"
            DiscussViewController *vc = [DiscussViewController new];
            vc.belowViewController = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {//"评论界面（键盘一直在底部）"
            DiscussViewController *vc = [DiscussViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 7:
        {//"发动态界面（底部是工具栏）"
            SubmitViewController *vc = [SubmitViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8:
        {//"TextField"
            TextFieldViewController *vc = [TextFieldViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 9:
        {//"输入条右边是“发送”按钮"
            SendButtonViewController *vc = [SendButtonViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 10:
        {//"Swift聊天界面"
            ChatSwiftViewController *vc = [ChatSwiftViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }

}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 ||indexPath.row == 5 ||indexPath.row == 7 ){
        return 140;
    }
    return 60;
}

@end
