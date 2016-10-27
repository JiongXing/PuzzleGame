//
//  Algorithm.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/24.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "Algorithm.h"

@interface Algorithm ()

@end

@implementation Algorithm

/// 广度优先搜索
+ (NSMutableArray<GameStauts *> *)breadthFirstSearchWithStartStatus:(GameStauts *)startStatus targetStatus:(GameStauts *)targetStatus {
    return [[[Algorithm alloc] init] breadthFirstSearchWithStartStatus:startStatus targetStatus:targetStatus];
}

- (NSMutableArray<GameStauts *> *)breadthFirstSearchWithStartStatus:(GameStauts *)startStatus targetStatus:(GameStauts *)targetStatus {
    if (!startStatus || !targetStatus) {
        return nil;
    }
    
    // 判断是否有解
    // 待写...
    
    // 待检查集合，队列结构，使用数组实现
    NSMutableArray<GameStauts *> *waitForReview = [NSMutableArray array];
    // 已检查集合，堆结构，使用字典实现
    NSMutableDictionary<NSString *, NSNumber *> *reviewed = [NSMutableDictionary dictionary];
    
    // 把开始状态放入待检查队列
    [waitForReview addObject:startStatus];
    
    // 搜索，直到路径已构建
    NSMutableArray<GameStauts *> *path = nil;
    while (!path) {
        
        // 取一个未检查过的状态
        GameStauts *status = nil;
        while (!status) {
            if (waitForReview.count == 0) {
                break;
            }
            status = [waitForReview firstObject];
            [waitForReview removeObjectAtIndex:0];
            
            // 如果取出来的状态是已检查过的，则此状态无效，丢弃。进行新一轮循环，再取一值
            if (reviewed[[status idKey]]) {
                status = nil;
            }
        }
        
        // 无法取到一个未检查过的状态。无法继续搜索，退出循环
        if (!status) {
            break;
        }
        
        // 记录此状态为已检查
        reviewed[[status idKey]] = @YES;
        
        // 如果成功搜索到目标状态
        if ([status isEqualTo:targetStatus]) {
            // 构建搜索路径。循环将会结束
            path = [self pathWithEndStatus:status];
        }
        else {
            // 扩展出邻接状态，添加到待检查队列中。继续新一轮循环
            [waitForReview addObjectsFromArray:[status effectiveNeighborStatus]];
        }
    }
    NSLog(@"review堆数量：%@", @(reviewed.count));
    return path;
}


/// A*搜索
- (NSMutableArray<GameStauts *> *)aStarSearch {
    
    return nil;
}

/// 构建路径
- (NSMutableArray<GameStauts *> *)pathWithEndStatus:(GameStauts *)endStatus {
    NSMutableArray<GameStauts *> *path = [NSMutableArray array];
    do {
        [path insertObject:endStatus atIndex:0];
        endStatus = endStatus.parent;
    } while (endStatus);
    return path;
}

@end
