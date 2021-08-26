//
//  FaceManager.m
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FaceManager.h"


@implementation FaceManager

+ (id)sharedFaceManager{
    static FaceManager *_sharedFaceManager=nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedFaceManager = [[FaceManager alloc] init];
        
        NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"emoji" ofType:@"plist"];
        _sharedFaceManager.emojiDictionary = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
       
    });
    return _sharedFaceManager;
}

- (NSString *)findKeyByValue:(NSString *)value{
    
    __block NSString *objectKey = @"abc";
    [self.emojiDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:value]) {
            objectKey = key;
        }
    }];
    return objectKey;
}

//本方法执行效率较低，因为我这里只是demo演示；实际开发中，请改为你自己的获取表情列表的写法
- (NSArray<QEmotion *> *)emotionArray
{
    if (!_emotionArray) {
      
        NSDate *startTime = [NSDate date];
        NSMutableArray<QEmotion *> *emotions = [[NSMutableArray alloc] init];
        for (int i = 1; i < 21; i ++) {
            NSString *identifier = [NSString stringWithFormat:@"Expression_%d", i];
            QEmotion *emotion = [QEmotion emotionWithIdentifier:identifier displayName:[self findKeyByValue:identifier]];
            [emotions addObject:emotion];
        }
        
        for (int i = 101; i < 111; i ++) {
            NSString *identifier = [NSString stringWithFormat:@"Expression_%d", i];
            QEmotion *emotion = [QEmotion emotionWithIdentifier:identifier displayName:[self findKeyByValue:identifier]];
            [emotions addObject:emotion];
        }
        QEmotion *emotion = [QEmotion emotionWithIdentifier:@"Watermelon" displayName:[self findKeyByValue:@"Watermelon"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Addoil" displayName:[self findKeyByValue:@"Addoil"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Sweat" displayName:[self findKeyByValue:@"Sweat"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Shocked" displayName:[self findKeyByValue:@"Shocked"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Cold" displayName:[self findKeyByValue:@"Cold"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Social" displayName:[self findKeyByValue:@"Social"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"NoProb" displayName:[self findKeyByValue:@"NoProb"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Slap" displayName:[self findKeyByValue:@"Slap"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"KeepFighting" displayName:[self findKeyByValue:@"KeepFighting"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Boring" displayName:[self findKeyByValue:@"Boring"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"666" displayName:[self findKeyByValue:@"666"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"LetMeSee" displayName:[self findKeyByValue:@"LetMeSee"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Sigh" displayName:[self findKeyByValue:@"Sigh"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Hurt" displayName:[self findKeyByValue:@"Hurt"]];
        [emotions addObject:emotion];
        emotion = [QEmotion emotionWithIdentifier:@"Broken" displayName:[self findKeyByValue:@"Broken"]];
        [emotions addObject:emotion];
        
        for (int i = 21; i < 92; i ++) {
            NSString *identifier = [NSString stringWithFormat:@"Expression_%d", i];
            QEmotion *emotion = [QEmotion emotionWithIdentifier:identifier displayName:[self findKeyByValue:identifier]];
            [emotions addObject:emotion];
        }
        NSLog(@"Time1: %f", -[startTime timeIntervalSinceNow]);
        
        for (QEmotion *e in emotions) {
            e.image = [UIImage imageNamed:e.identifier];
        }
        NSLog(@"Time2: %f", -[startTime timeIntervalSinceNow]);
        
        _emotionArray = emotions;
    }
    return _emotionArray;
}

@end
