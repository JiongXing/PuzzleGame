//
//  Algorithm.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/24.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "Algorithm.h"

@interface Algorithm ()

/// 存放结果路径
@property (nonatomic, strong) NSMutableArray<GameStauts *> *resultPath;
/// 未访问
@property (nonatomic, strong) NSMutableArray<GameStauts *> *openList;
/// 已访问
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *visited;
@property (nonatomic, assign) NSInteger searchedCnt;

@end

@implementation Algorithm

- (NSMutableArray<GameStauts *> *)breadthFirstSearch {
    
    self.searchedCnt = 0;
    [self.openList addObject:self.sourceStatus];
    
    while (self.openList.count > 0) {
        GameStauts *currentStatus = nil;
        
        // 取出未访问过的状态
        do {
            currentStatus = [self.openList firstObject];
            [self.openList removeObjectAtIndex:0];
        } while (self.openList.count > 0 && self.visited[[currentStatus toString]]);
        
        // 无状态可访问
        if (self.openList.count == 0 && self.visited[[currentStatus toString]]) {
            return nil;
        }
        
        ++ self.searchedCnt;
        self.visited[[currentStatus toString]] = [NSNumber numberWithBool:YES];
//        [self printSearchWithCurrentStatus:currentStatus];
        
        // 找到目标状态
        if ([currentStatus isEqualTo:self.targetStatus]) {
            [self constructPathWithEndStatus:currentStatus];
            return self.resultPath;
        }
        
        for (NSInteger direction = 1; direction <= 4; direction ++) {
            if ([currentStatus canMoveWithDirection:direction]) {
                GameStauts *neighbor = [currentStatus neighborStatusWithDirection:direction];
                if (!self.visited[[neighbor toString]]) {
                    neighbor.parent = currentStatus;
                    [self.openList addObject:neighbor];
                }
            }
        }
    }
    return nil;
}

- (NSMutableArray<GameStauts *> *)aStarSearch {
    return nil;
}

/// 构建路径
- (void)constructPathWithEndStatus:(GameStauts *)status {
    if (status.parent) {
        [self constructPathWithEndStatus:status.parent];
    }
    [self.resultPath addObject:status];
}

/// 打印搜索过程
- (void)printSearchWithCurrentStatus:(GameStauts *)status {
    NSLog(@"%@, total:%ld", [status toString], self.searchedCnt);
}

- (NSMutableArray<GameStauts *> *)resultPath {
    if (!_resultPath) {
        _resultPath = [NSMutableArray array];
    }
    return _resultPath;
}

- (NSMutableArray<GameStauts *> *)openList {
    if (!_openList) {
        _openList = [NSMutableArray array];
    }
    return _openList;
}

- (NSMutableDictionary *)visited {
    if (!_visited) {
        _visited = [NSMutableDictionary dictionary];
    }
    return _visited;
}

@end
