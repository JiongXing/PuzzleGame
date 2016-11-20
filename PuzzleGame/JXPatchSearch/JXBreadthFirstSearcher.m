//
//  JXBreadthFirstSearcher.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/13.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "JXBreadthFirstSearcher.h"

@implementation JXBreadthFirstSearcher

- (NSMutableArray *)search {
    NSMutableArray *path = [super search];
    if (!path) {
        return nil;
    }
    
    // 关闭堆，存放已搜索过的状态
    NSMutableDictionary *close = [NSMutableDictionary dictionary];
    // 开放队列，存放由已搜索过的状态所扩展出来的未搜索状态
    NSMutableArray *open = [NSMutableArray array];
    
    [open addObject:self.startStatus];
    
    while (open.count > 0) {
        // 出列
        id status = [open firstObject];
        [open removeObjectAtIndex:0];
        
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
        [open addObjectsFromArray:[status childStatus]];
    }
    NSLog(@"总共搜索: %@个状态", @(close.count));
    return path;
}

@end
