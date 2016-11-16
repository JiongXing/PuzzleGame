//
//  JXPathSearcher.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/13.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "JXPathSearcher.h"

@implementation JXPathSearcher

- (NSMutableArray *)search {
    if (!self.startStatus || !self.targetStatus || !self.equalComparator) {
        return nil;
    }
    return [NSMutableArray array];
}

- (NSMutableArray *)constructPathWithStatus:(id<JXPathSearcherStatus>)status isLast:(BOOL)isLast {
    NSMutableArray *path = [NSMutableArray array];
    if (!status) {
        return path;
    }
    
    do {
        if (isLast) {
            [path insertObject:status atIndex:0];
        }
        else {
            [path addObject:status];
        }
        status = [status parentStatus];
    } while (status);
    return path;
}

- (void)setStartStatus:(id<JXPathSearcherStatus>)startStatus {
    // 保证开始状态是没有父状态的。为了保证在构建路径的时候不会超出开始状态。
    [startStatus setParentStatus:nil];
    _startStatus = startStatus;
}

- (void)setTargetStatus:(id<JXPathSearcherStatus>)targetStatus {
    // 保证目标状态是没有父状态的。为了保证在构建路径的时候不会超出目标状态。
    [targetStatus setParentStatus:nil];
    _targetStatus = targetStatus;
}

@end
