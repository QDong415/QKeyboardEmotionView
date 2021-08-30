//
//  FaceManager.h
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QEmotionBoardView.h"
#import <UIKit/UIKit.h>

//表情管理类，你也可以自定义，本类只做demo展示
#define FACEMANAGER [FaceManager sharedFaceManager]
@interface FaceManager : NSObject
{
}

+ (id)sharedFaceManager;

@property (strong, nonatomic)NSArray<QEmotion *> *emotionArray;

@end
