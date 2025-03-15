#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QEmotion.h"
#import "QEmotionAttachment.h"
#import "QEmotionBoardView.h"
#import "QEmotionHelper.h"
#import "QExtendBoardView.h"
#import "QInputBarView.h"
#import "QInputBarViewConfiguration.h"
#import "QKeyboardBaseManager.h"
#import "QKeyboardManager.h"
#import "QPlaceHolderTextView.h"
#import "UITextView+QEmotion.h"

FOUNDATION_EXPORT double QKeyboardEmotionViewVersionNumber;
FOUNDATION_EXPORT const unsigned char QKeyboardEmotionViewVersionString[];

