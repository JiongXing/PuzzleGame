//
//  JXDoubleBreadthFirstSearcher.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/14.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "JXDoubleBreadthFirstSearcher.h"

@implementation JXDoubleBreadthFirstSearcher

- (NSMutableArray *)search {
    NSMutableArray *path = [super search];
    if (!path) {
        return nil;
    }
    
    // 关闭堆，存放已搜索过的状态
    NSMutableDictionary *positiveClose = [NSMutableDictionary dictionary];
    NSMutableDictionary *negativeClose = [NSMutableDictionary dictionary];
    
    // 开放队列，存放由已搜索过的状态所扩展出来的未搜索状态
    NSMutableArray *positiveOpen = [NSMutableArray array];
    NSMutableArray *negativeOpen = [NSMutableArray array];
    
    [positiveOpen addObject:self.startStatus];
    [negativeOpen addObject:self.targetStatus];
    
    while (positiveOpen.count > 0 || negativeOpen.count > 0) {
        // 较短的那个扩展队列
        NSMutableArray *open;
        // 短队列对应的关闭堆
        NSMutableDictionary *close;
        // 另一个关闭堆
        NSMutableDictionary *otherClose;
        // 找出短队列
        if (positiveOpen.count && (positiveOpen.count < negativeOpen.count)) {
            open = positiveOpen;
            close = positiveClose;
            otherClose = negativeClose;
        }
        else {
            open = negativeOpen;
            close = negativeClose;
            otherClose = positiveClose;
        }
        
        // 出列
        id status = [open firstObject];
        [open removeObjectAtIndex:0];
        
        // 排除已经搜索过的状态
        NSString *statusIdentifier = [status statusIdentifier];
        if (close[statusIdentifier]) {
            continue;
        }
        close[statusIdentifier] = status;
        
        // 如果本状态同时存在于另一个已检查堆，则说明正反两棵搜索树出现交叉，搜索结束
        if (otherClose[statusIdentifier]) {
            NSMutableArray *positivePath = [self constructPathWithStatus:positiveClose[statusIdentifier] isLast:YES];
            NSMutableArray *negativePath = [self constructPathWithStatus:negativeClose[statusIdentifier] isLast:NO];
            // 拼接正反两条路径
            [positivePath addObjectsFromArray:negativePath];
            path = positivePath;
            break;
        }
        
        // 否则，扩展出子状态
        [open addObjectsFromArray:[status childStatus]];
    }
    NSLog(@"总共搜索: %@个状态", @(positiveClose.count + negativeClose.count - 1));
    return path;
}

@end
