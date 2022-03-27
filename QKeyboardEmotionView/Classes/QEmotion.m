//
//  QEmotion.m
//  QKeyboardEmotionView
//
//  Created by DongJin on 2022/3/26.
//

#import "QEmotion.h"

@implementation QEmotion

+ (instancetype)emotionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName {
    QEmotion *emotion = [[self alloc] init];
    emotion.identifier = identifier;
    emotion.displayName = displayName;
    return emotion;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self.identifier isEqualToString:((QEmotion *)object).identifier];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, identifier: %@, displayName: %@", [super description], self.identifier, self.displayName];
}

@end
