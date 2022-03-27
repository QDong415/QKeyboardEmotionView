//
//  ViewController.m
//  QKeyBoardDemo
//
//  Created by DongJin on 2021/7/14.
//


#import "ChatXibViewController.h"
#import "QEmotionHelper.h"
#import "QTestLabel.h"

@interface ChatXibViewController ()
{
    QTestLabel *label;
}

@end

@implementation ChatXibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天xib界面";

    //self.view.frame.size.width
    
    label = [[QTestLabel alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 600)];
    label.numberOfLines = 0;
    
    label.font = [UIFont systemFontOfSize:28];
    
    
    [self.view addSubview:label];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDate *startTime = [NSDate date];
    NSLog(@"Time1: %f", [startTime timeIntervalSince1970]);
    
    NSString *str = [NSString stringWithFormat:@"%f😄[微笑][呲牙]翁绕所😄多付所多啊打发斯蒂芬[再见][微笑2]的打法撒😄旦法[微笑毒贩夫妇][大小][捂👨🏻❤️脸][微笑]阿斯顿发斯👨🏻❤️n蒂芬[微笑]http://连哭都是打开分类[微笑]哭都\n是打开分类到😄到哭都是打开分类哭都是<dd>✔️😄打开分类[旺柴][社会社会][6👨🏻❤️66][]是打发斯FFF的蒂芬[阿萨大师👨🏻❤️傅恩我\n若翁绕%f😄[微笑][呲牙]翁绕所😄多付所多啊打发斯蒂芬[再见][微笑2]的打法撒😄旦法[微笑毒贩夫妇][大小][捂👨🏻❤️脸][微笑]阿斯顿发斯👨🏻❤️n蒂芬[微笑]http://连哭都是打开分类[微笑]哭都\n是打开分类到😄到哭都是打开分类哭都是<dd>✔️😄打开分类[旺柴][社会社会][6👨🏻❤️66][]是打发斯FFF的蒂芬[阿萨大师👨🏻❤️傅恩我\n若翁绕[Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑👨🏻❤️][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑]所👨🏻❤️多\n付所多啊😄打发斯蒂芬对的[立刻就阿杀了的减肥；垃圾收代理费即时看到发文日唉短FFF发水立方；as；的李开复；了as人][jjiidi]asdfjksajdlfk 大是大非 答[微笑]复阿斯蒂芬  FFF 阿士大夫的是👨🏻❤️n垃圾收代理费。👨🏻❤️的减肥；垃圾收代理费即[偷看]时看到发文日唉短发，的减肥；垃圾收代理费即时看到发文日唉短发。的减肥；垃圾收代理费即时看到发文日唉短发[吃鸭][汪星人]🐶[沙发斯蒂芬][大笑][]]]][[[[[]as！@#！@￥#%￥#……￥%&%……&[偷笑]【】[👋🏻][你好][再见][Emm][Emm][Emm][Emm][Emm][Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑][大笑][大笑]隊_(:з」∠)_👩🏻👨🏻[Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑👨🏻❤️][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑]所👨🏻❤️多\n付所多啊😄打发斯蒂芬对的[立刻就阿杀了的减肥；垃圾收代理费即时看到发文日唉短FFF发水立方；as；的李开复；了as人][jjiidi]asdfjksajdlfk 大是大非 答[微笑]复阿斯蒂芬  FFF 阿士大夫的是👨🏻❤️n垃圾收代理费。👨🏻❤️的减肥；垃圾收代理费即[偷看]时看到发文日唉短发，的减肥；垃圾收代理费即时看到发文日唉短发。的减肥；垃圾收代理费即时看到发文日唉短发[吃鸭][汪星人]🐶[沙发斯蒂芬][大笑][]]]][[[[[]][Emm][Emm][Emm][Emm][Emm][Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑][大笑][大笑]隊_(:з」∠)_👩🏻👨🏻[Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑👨🏻❤️][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑]所👨🏻❤️多\n付所多啊😄打发斯蒂芬对的[立刻就阿杀了的减肥；垃圾收代理费即时看到发文日唉短FFF发水立方；as；的李开复；了as人][jjiidi]asdfjksajdlfk 大是大非 答[微笑]复阿斯蒂芬  FFF 阿士大夫的是👨🏻❤️n垃圾收代理费。👨🏻❤️的减肥；垃圾收代理费即[偷看]时看到发文日唉短发，的减肥；垃圾收代理费即时看到发文日唉短发。的减肥；垃圾收代理费即时看到发文日唉短发[吃鸭][汪星人]🐶[沙发斯蒂芬][大笑][]]]][[[[[]as！@#！@￥#%￥#……￥%&%……&[偷笑]【】[👋🏻][你好][再见][Emm][Emm][Emm][Emm][Emm][Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑][大笑][大笑]隊_(:з」∠)_👩🏻👨🏻❤️[Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑👨🏻❤️][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑]所👨🏻❤️多\n付所多啊😄打发斯蒂芬对的[立刻就阿杀了的减肥；垃圾收代理费即时看到发文日唉短FFF发水立方；as；的李开复；了as人][jjiidi]asdfjksajdlfk 大是大非 答[微笑]复阿斯蒂芬  FFF 阿士大夫的是👨🏻❤️n垃圾收代理费。👨🏻❤️的减肥；垃圾收代理费即[偷看]时看到发文日唉短发，的减肥；垃圾收代理费即时看到发文日唉短发。的减肥；垃圾收代理费即时看到发文日唉短发[吃鸭][汪星人]🐶[沙发斯蒂芬][大笑][]]]][[[[[]as！@#！@￥#%￥#……￥%&%……&[偷笑]【】[👋🏻][你好][再见][Emm][Emm][Emm][Emm][Emm][Emm][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][憨笑][Emm][Emm][憨笑][大笑][大笑]隊_(:з」∠)_👩🏻👨🏻❤️❤️[偷看][偷看]", [[NSDate date] timeIntervalSince1970],[[NSDate date]  timeIntervalSince1970]];

    NSLog(@"1");
    //1次遍历，只是setAttributedString 不转表情: 内存占24.2，0.0005s;  转表情0.006;转译表情 = 0.
    for (int i = 0; i < 1; i++){
        str = [NSString stringWithFormat:@"%@%d",str,i];
        label.attributedText = [[QEmotionHelper sharedEmotionHelper] attributedStringByText:str font:label.font];
    }
    NSLog(@"2");
}


#pragma mark - Override
- (void)initBodyView {

}


#pragma mark - Override
- (CGFloat)navigationBarHeight {
    return 0;
}

@end
