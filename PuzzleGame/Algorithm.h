//
//  Algorithm.h
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/24.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStauts.h"

@interface Algorithm : NSObject

/// 起始状态
@property (nonatomic, strong) GameStauts *sourceStatus;
/// 目标状态
@property (nonatomic, strong) GameStauts *targetStatus;

/// BFS广度优先搜索
- (NSMutableArray<GameStauts *> *)breadthFirstSearch;

/// A*搜索
- (NSMutableArray<GameStauts *> *)aStarSearch;

@end
