//
//  QKEYBOARDEMOTIONVIEWAppDelegate.m
//  QKeyboardEmotionView
//
//  Created by 285275534 on 08/20/2021.
//  Copyright (c) 2021 285275534. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "QEmotionHelper.h"
#import "QEmotion.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc ]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //在这里强烈建议先预加载一下表情
    QEmotionHelper *faceManager = [QEmotionHelper sharedEmotionHelper];
    faceManager.emotionArray = [self createTotalEmotion];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
    self.window.rootViewController = nc;
    
    return YES;
}

//创建表情列表。这段代码耗时约0.02秒，占用内存约0.5M
- (NSMutableArray<QEmotion *> *)createTotalEmotion {
    
    NSMutableArray<QEmotion *> *emotionArray = [[NSMutableArray alloc] init];
    
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_1" displayName:@"[微笑]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_2" displayName:@"[撇嘴]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_3" displayName:@"[色]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_4" displayName:@"[发呆]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_5" displayName:@"[得意]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_6" displayName:@"[流泪]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_7" displayName:@"[害羞]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_8" displayName:@"[闭嘴]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_9" displayName:@"[睡]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_10" displayName:@"[大哭]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_11" displayName:@"[尴尬]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_12" displayName:@"[发怒]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_13" displayName:@"[调皮]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_14" displayName:@"[呲牙]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_15" displayName:@"[惊讶]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_16" displayName:@"[难过]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_18" displayName:@"[冷汗]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_19" displayName:@"[抓狂]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_20" displayName:@"[吐]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_106" displayName:@"[耶]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_107" displayName:@"[红包]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_108" displayName:@"[蜡烛]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_109" displayName:@"[小鸡]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_110" displayName:@"[旺柴]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Watermelon" displayName:@"[吃瓜]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Addoil" displayName:@"[加油]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Sweat" displayName:@"[汗]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Shocked" displayName:@"[天啊]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Cold" displayName:@"[Emm]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Social" displayName:@"[社会]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"NoProb" displayName:@"[好的]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Slap" displayName:@"[打脸]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Boring" displayName:@"[翻白眼]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"KeepFighting" displayName:@"[加油加油]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"666" displayName:@"[666]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"LetMeSee" displayName:@"[我看看]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Sigh" displayName:@"[叹气]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Hurt" displayName:@"[苦涩]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Broken" displayName:@"[裂开]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_21" displayName:@"[偷笑]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_23" displayName:@"[白眼]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_24" displayName:@"[傲慢]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_26" displayName:@"[困]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_27" displayName:@"[惊恐]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_29" displayName:@"[憨笑]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_30" displayName:@"[悠闲]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_32" displayName:@"[咒骂]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_33" displayName:@"[疑问]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_34" displayName:@"[嘘]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_35" displayName:@"[晕]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_37" displayName:@"[衰]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_38" displayName:@"[骷髅]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_39" displayName:@"[敲打]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_40" displayName:@"[再见]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_41" displayName:@"[擦汗]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_42" displayName:@"[抠鼻]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_43" displayName:@"[鼓掌]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_45" displayName:@"[糗大了]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_47" displayName:@"[右哼哼]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_49" displayName:@"[鄙视]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_50" displayName:@"[委屈]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_51" displayName:@"[快哭了]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_52" displayName:@"[阴险]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_53" displayName:@"[亲亲]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_55" displayName:@"[可怜]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_56" displayName:@"[菜刀]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_57" displayName:@"[西瓜]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_58" displayName:@"[啤酒]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_59" displayName:@"[篮球]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_60" displayName:@"[乒乓]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_61" displayName:@"[咖啡]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_62" displayName:@"[饭]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_63" displayName:@"[猪头]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_64" displayName:@"[玫瑰]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_65" displayName:@"[凋谢]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_66" displayName:@"[嘴唇]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_67" displayName:@"[爱心]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_68" displayName:@"[心碎]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_69" displayName:@"[蛋糕]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_70" displayName:@"[闪电]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_71" displayName:@"[炸弹]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_72" displayName:@"[刀]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_73" displayName:@"[足球]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_74" displayName:@"[瓢虫]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_75" displayName:@"[便便]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_76" displayName:@"[月亮]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_77" displayName:@"[太阳]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_78" displayName:@"[礼物]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_79" displayName:@"[拥抱]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_80" displayName:@"[强]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_81" displayName:@"[弱]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_82" displayName:@"[握手]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_83" displayName:@"[胜利]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_84" displayName:@"[抱拳]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_85" displayName:@"[勾引]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_86" displayName:@"[拳头]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_87" displayName:@"[差劲]"]];
    [emotionArray addObject:[QEmotion emotionWithIdentifier:@"Expression_90" displayName:@"[OK]"]];
    
    //这一步初始化image很重要，你可能是bundle，也可能是imageNamed。但是一定要做
    for (QEmotion *e in emotionArray) {
        e.image = [UIImage imageNamed:e.identifier];
    }
    return emotionArray;
}


@end
