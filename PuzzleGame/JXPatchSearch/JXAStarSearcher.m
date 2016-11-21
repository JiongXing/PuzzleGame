//
//  JXAStarSearcher.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/15.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "JXAStarSearcher.h"
#import "JXPriorityQueue.h"

@implementation JXAStarSearcher

- (NSMutableArray *)search {
    NSMutableArray *path = [super search];
    if (!path) {
        return nil;
    }
    [(id<JXAStarSearcherStatus>)[self startStatus] setGValue:0];
    
    // 关闭堆，存放已搜索过的状态
    NSMutableDictionary *close = [NSMutableDictionary dictionary];
    // 开放队列，存放由已搜索过的状态所扩展出来的未搜索状态
    // 使用优先队列
    JXPriorityQueue *open = [JXPriorityQueue queueWithComparator:^NSComparisonResult(id<JXAStarSearcherStatus> obj1, id<JXAStarSearcherStatus> obj2) {
        if ([obj1 fValue] == [obj2 fValue]) {
            return NSOrderedSame;
        }
        // f值越小，优先级越高
        return [obj1 fValue] < [obj2 fValue] ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    [open enQueue:self.startStatus];
    
    while (open.count > 0) {
        // 出列
        id status = [open deQueue];
        
        // 排除已经搜索过的状态
        NSString *statusIdentifier = [status statusIdentifier];
        if (close[statusIdentifier]) {
            continue;
        }
        close[statusIdentifier] = status;
        
        // 如果找到目标状态
        if (self.equalComparator(self.targetStatus, status)) {
            path = [self constructPathWithStatus:status isLast:YES];
            break;
        }
        
        // 否则，扩展出子状态
        NSMutableArray *childStatus = [status childStatus];
        // 对各个子状进行代价估算
        [childStatus enumerateObjectsUsingBlock:^(id<JXAStarSearcherStatus>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 子状态的实际代价比本状态大1
            [obj setGValue:[status gValue] + 1];
            // 估算到目标状态的代价
            [obj setHValue:[obj estimateToTargetStatus:self.targetStatus]];
            // 总价=已知代价+未知估算代价
            [obj setFValue:[obj gValue] + [obj hValue]];
            
            // 入列
            [open enQueue:obj];
        }];
    }
    NSLog(@"总共搜索: %@个状态", @(close.count));
    return path;
}

@end
