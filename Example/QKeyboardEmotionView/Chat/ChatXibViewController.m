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
    
    self.title = @"èå¤©xibçé¢";

    //self.view.frame.size.width
    
    label = [[QTestLabel alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 600)];
    label.numberOfLines = 0;
    
    label.font = [UIFont systemFontOfSize:28];
    
    
    [self.view addSubview:label];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDate *startTime = [NSDate date];
    NSLog(@"Time1: %f", [startTime timeIntervalSince1970]);
    
    NSString *str = [NSString stringWithFormat:@"%fð[å¾®ç¬][å²ç]ç¿ç»æðå¤ä»æå¤åæåæ¯èè¬[åè§][å¾®ç¬2]çææ³æðæ¦æ³[å¾®ç¬æ¯è´©å¤«å¦][å¤§å°][æð¨ð»â¤ï¸è¸][å¾®ç¬]é¿æ¯é¡¿åæ¯ð¨ð»â¤ï¸nèè¬[å¾®ç¬]http://è¿å­é½æ¯æå¼åç±»[å¾®ç¬]å­é½\næ¯æå¼åç±»å°ðå°å­é½æ¯æå¼åç±»å­é½æ¯<dd>âï¸ðæå¼åç±»[æºæ´][ç¤¾ä¼ç¤¾ä¼][6ð¨ð»â¤ï¸66][]æ¯æåæ¯FFFçèè¬[é¿è¨å¤§å¸ð¨ð»â¤ï¸åæ©æ\nè¥ç¿ç»%fð[å¾®ç¬][å²ç]ç¿ç»æðå¤ä»æå¤åæåæ¯èè¬[åè§][å¾®ç¬2]çææ³æðæ¦æ³[å¾®ç¬æ¯è´©å¤«å¦][å¤§å°][æð¨ð»â¤ï¸è¸][å¾®ç¬]é¿æ¯é¡¿åæ¯ð¨ð»â¤ï¸nèè¬[å¾®ç¬]http://è¿å­é½æ¯æå¼åç±»[å¾®ç¬]å­é½\næ¯æå¼åç±»å°ðå°å­é½æ¯æå¼åç±»å­é½æ¯<dd>âï¸ðæå¼åç±»[æºæ´][ç¤¾ä¼ç¤¾ä¼][6ð¨ð»â¤ï¸66][]æ¯æåæ¯FFFçèè¬[é¿è¨å¤§å¸ð¨ð»â¤ï¸åæ©æ\nè¥ç¿ç»[Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬ð¨ð»â¤ï¸][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬]æð¨ð»â¤ï¸å¤\nä»æå¤åðæåæ¯èè¬å¯¹ç[ç«å»å°±é¿æäºçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­FFFåæ°´ç«æ¹ï¼asï¼çæå¼å¤ï¼äºasäºº][jjiidi]asdfjksajdlfk å¤§æ¯å¤§é ç­[å¾®ç¬]å¤é¿æ¯èè¬  FFF é¿å£«å¤§å¤«çæ¯ð¨ð»â¤ï¸nåå¾æ¶ä»£çè´¹ãð¨ð»â¤ï¸çåè¥ï¼åå¾æ¶ä»£çè´¹å³[å·ç]æ¶çå°åææ¥åç­åï¼çåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­åãçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­å[åé¸­][æ±ªæäºº]ð¶[æ²åæ¯èè¬][å¤§ç¬][]]]][[[[[]asï¼@#ï¼@ï¿¥#%ï¿¥#â¦â¦ï¿¥%&%â¦â¦&[å·ç¬]ãã[ðð»][ä½ å¥½][åè§][Emm][Emm][Emm][Emm][Emm][Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬][å¤§ç¬][å¤§ç¬]é_(:Ð·ãâ )_ð©ð»ð¨ð»[Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬ð¨ð»â¤ï¸][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬]æð¨ð»â¤ï¸å¤\nä»æå¤åðæåæ¯èè¬å¯¹ç[ç«å»å°±é¿æäºçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­FFFåæ°´ç«æ¹ï¼asï¼çæå¼å¤ï¼äºasäºº][jjiidi]asdfjksajdlfk å¤§æ¯å¤§é ç­[å¾®ç¬]å¤é¿æ¯èè¬  FFF é¿å£«å¤§å¤«çæ¯ð¨ð»â¤ï¸nåå¾æ¶ä»£çè´¹ãð¨ð»â¤ï¸çåè¥ï¼åå¾æ¶ä»£çè´¹å³[å·ç]æ¶çå°åææ¥åç­åï¼çåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­åãçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­å[åé¸­][æ±ªæäºº]ð¶[æ²åæ¯èè¬][å¤§ç¬][]]]][[[[[]][Emm][Emm][Emm][Emm][Emm][Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬][å¤§ç¬][å¤§ç¬]é_(:Ð·ãâ )_ð©ð»ð¨ð»[Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬ð¨ð»â¤ï¸][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬]æð¨ð»â¤ï¸å¤\nä»æå¤åðæåæ¯èè¬å¯¹ç[ç«å»å°±é¿æäºçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­FFFåæ°´ç«æ¹ï¼asï¼çæå¼å¤ï¼äºasäºº][jjiidi]asdfjksajdlfk å¤§æ¯å¤§é ç­[å¾®ç¬]å¤é¿æ¯èè¬  FFF é¿å£«å¤§å¤«çæ¯ð¨ð»â¤ï¸nåå¾æ¶ä»£çè´¹ãð¨ð»â¤ï¸çåè¥ï¼åå¾æ¶ä»£çè´¹å³[å·ç]æ¶çå°åææ¥åç­åï¼çåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­åãçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­å[åé¸­][æ±ªæäºº]ð¶[æ²åæ¯èè¬][å¤§ç¬][]]]][[[[[]asï¼@#ï¼@ï¿¥#%ï¿¥#â¦â¦ï¿¥%&%â¦â¦&[å·ç¬]ãã[ðð»][ä½ å¥½][åè§][Emm][Emm][Emm][Emm][Emm][Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬][å¤§ç¬][å¤§ç¬]é_(:Ð·ãâ )_ð©ð»ð¨ð»â¤ï¸[Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬ð¨ð»â¤ï¸][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬]æð¨ð»â¤ï¸å¤\nä»æå¤åðæåæ¯èè¬å¯¹ç[ç«å»å°±é¿æäºçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­FFFåæ°´ç«æ¹ï¼asï¼çæå¼å¤ï¼äºasäºº][jjiidi]asdfjksajdlfk å¤§æ¯å¤§é ç­[å¾®ç¬]å¤é¿æ¯èè¬  FFF é¿å£«å¤§å¤«çæ¯ð¨ð»â¤ï¸nåå¾æ¶ä»£çè´¹ãð¨ð»â¤ï¸çåè¥ï¼åå¾æ¶ä»£çè´¹å³[å·ç]æ¶çå°åææ¥åç­åï¼çåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­åãçåè¥ï¼åå¾æ¶ä»£çè´¹å³æ¶çå°åææ¥åç­å[åé¸­][æ±ªæäºº]ð¶[æ²åæ¯èè¬][å¤§ç¬][]]]][[[[[]asï¼@#ï¼@ï¿¥#%ï¿¥#â¦â¦ï¿¥%&%â¦â¦&[å·ç¬]ãã[ðð»][ä½ å¥½][åè§][Emm][Emm][Emm][Emm][Emm][Emm][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][æ¨ç¬][Emm][Emm][æ¨ç¬][å¤§ç¬][å¤§ç¬]é_(:Ð·ãâ )_ð©ð»ð¨ð»â¤ï¸â¤ï¸[å·ç][å·ç]", [[NSDate date] timeIntervalSince1970],[[NSDate date]  timeIntervalSince1970]];

    NSLog(@"1");
    //1æ¬¡éåï¼åªæ¯setAttributedString ä¸è½¬è¡¨æ: åå­å 24.2ï¼0.0005s;  è½¬è¡¨æ0.006;
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
