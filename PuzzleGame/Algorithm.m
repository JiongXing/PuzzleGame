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
    if (!startStatus || !targetStatus) {
        return nil;
    }
    startStatus = [startStatus mutableCopy];
    startStatus.parent = nil;
    
    // 待检查集合，队列结构，使用数组实现。扩展出的新状态将存放于此
    NSMutableArray<GameStauts *> *waitForReview = [NSMutableArray array];
    // 已检查集合，堆结构，使用字典实现
    NSMutableDictionary<NSString *, GameStauts *> *reviewed = [NSMutableDictionary dictionary];
    
    // 把开始状态放入待检查队列
    [waitForReview addObject:startStatus];
    
    // 搜索，直到路径已构建
    NSMutableArray<GameStauts *> *path = nil;
    while (YES) {
        // 取出一个未检查过的状态
        GameStauts *status = [self popStatusFromWaitForReview:waitForReview reviewed:reviewed];
        
        // 取不到，无法继续搜索，退出循环
        if (!status) {
            break;
        }
        
        // 记录此状态为已检查
        reviewed[[status idKey]] = status;
        
        // 如果成功搜索到目标状态
        if ([status isEqualTo:targetStatus]) {
            // 构建搜索路径。循环将会结束
            path = [self pathWithPositiveStatus:status];
            break;
        }
        
        // 扩展出邻居状态，添加到待检查队列中。继续新一轮循环
        [waitForReview addObjectsFromArray:[status effectiveNeighborStatus]];
    }
    NSLog(@"review堆大小：%@", @(reviewed.count));
    return path;
}

/// 双向广搜
+ (NSMutableArray<GameStauts *> *)doubleBreadthFirstSearchWithStartStatus:(GameStauts *)startStatus targetStatus:(GameStauts *)targetStatus {
    if (!startStatus || !targetStatus) {
        return nil;
    }
    startStatus = [startStatus mutableCopy];
    targetStatus = [targetStatus mutableCopy];
    startStatus.parent = nil;
    targetStatus.parent = nil;
    
    // 正向扩展的序列和堆
    NSMutableArray<GameStauts *> *positiveWaitForReview = [NSMutableArray array];
    [positiveWaitForReview addObject:startStatus];
    NSMutableDictionary<NSString *, GameStauts *> *positiveReviewed = [NSMutableDictionary dictionary];
    
    // 反向扩展的序列和堆
    NSMutableArray<GameStauts *> *negativeWaitForReview = [NSMutableArray array];
    [negativeWaitForReview addObject:targetStatus];
    NSMutableDictionary<NSString *, GameStauts *> *negativeReviewed = [NSMutableDictionary dictionary];

    // 搜索，直到路径已构建
    NSMutableArray<GameStauts *> *path = nil;
    while (YES) {
        if (positiveWaitForReview.count == 0 && negativeWaitForReview.count == 0) {
            // 无可继续搜索的状态
            break;
        }
        
        // 优先搜索和扩展短序列
        NSMutableArray<GameStauts *> *waitForReview = positiveWaitForReview;
        NSMutableDictionary<NSString *, GameStauts *> *reviewed = positiveReviewed;
        NSMutableDictionary<NSString *, GameStauts *> *otherReviewed = negativeReviewed;
        if (positiveWaitForReview.count == 0 || positiveWaitForReview.count > negativeWaitForReview.count) {
            waitForReview = negativeWaitForReview;
            reviewed = negativeReviewed;
            otherReviewed = positiveReviewed;
        }
        
        // 从扩展序列取出一个未检查过的状态
        GameStauts *status = [self popStatusFromWaitForReview:waitForReview reviewed:reviewed];
        
        // 从当前序列取不到，再来一遍循环，将会从另一个序列取
        if (!status) {
            continue;
        }
        
        // 记录本状态为已检查
        NSString *idKey = [status idKey];
        reviewed[idKey] = status;
        
        // 如果本状态同时存在于另一个已检查堆，则说明正反两棵搜索树出现交叉，搜索结束
        if (otherReviewed[idKey]) {
            // 构建路径
            NSMutableArray<GameStauts *> *positivePath = nil;
            NSMutableArray<GameStauts *> *negativePath = nil;
            if (reviewed == positiveReviewed) {
                positivePath = [self pathWithPositiveStatus:status.parent];
                negativePath = [self pathWithNegativeStatus:otherReviewed[idKey]];
            }
            else {
                positivePath = [self pathWithPositiveStatus:otherReviewed[idKey]];
                negativePath = [self pathWithNegativeStatus:status.parent];
            }
            // 拼接正反两条路径
            [positivePath addObjectsFromArray:negativePath];
            path = positivePath;
            break;
        }
        
        // 扩展出邻居状态，添加到待检查队列中。继续新一轮循环
        [waitForReview addObjectsFromArray:[status effectiveNeighborStatus]];
    }
    NSLog(@"review堆大小：%@", @(positiveReviewed.count + negativeReviewed.count));
    return path;
}

+ (GameStauts *)popStatusFromWaitForReview:(NSMutableArray<GameStauts *> *)waitForReview reviewed:(NSMutableDictionary<NSString *, GameStauts *> *)reviewed {
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
    return status;
}


/// A*搜索
- (NSMutableArray<GameStauts *> *)aStarSearch {
    // 待写
    return nil;
}

/// 从末尾回溯路径
+ (NSMutableArray<GameStauts *> *)pathWithPositiveStatus:(GameStauts *)status {
    NSMutableArray<GameStauts *> *path = [NSMutableArray array];
    while (status) {
        [path insertObject:status atIndex:0];
        status = status.parent;
    }
    return path;
}

/// 从开头构建路径
+ (NSMutableArray<GameStauts *> *)pathWithNegativeStatus:(GameStauts *)status {
    NSMutableArray<GameStauts *> *path = [NSMutableArray array];
    while (status) {
        [path addObject:status];
        status = status.parent;
    }
    return path;
}

@end
