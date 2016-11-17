//
//  PuzzleStatus.h
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuzzlePiece.h"
#import "JXPathSearcher.h"
#import "JXAStarSearcher.h"

/// 表示游戏过程中，某一个时刻，所有方块的排列状态
@interface PuzzleStatus : NSObject <JXPathSearcherStatus, JXAStarSearcherStatus>

/// 矩阵阶数
@property (nonatomic, assign) NSInteger matrixOrder;

/// 方块数组，按从上到下，从左到右，顺序排列
@property (nonatomic, strong) NSMutableArray<PuzzlePiece *> *pieceArray;

/// 空格位置，无空格时为-1
@property (nonatomic, assign) NSInteger emptyIndex;

/// 创建实例，matrixOrder至少为3，image非空
+ (instancetype)statusWithMatrixOrder:(NSInteger)matrixOrder image:(UIImage *)image;

/// 复制本实例
- (instancetype)copyStatus;

/// 判断是否与另一个状态相同
- (BOOL)equalWithStatus:(PuzzleStatus *)status;

/// 打乱，传入随机移动的步数
- (void)shuffleCount:(NSInteger)count;

/// 移除所有方块
- (void)removeAllPieces;

/// 空格是否能移动到某个位置
- (BOOL)canMoveToIndex:(NSInteger)index;

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index;

@end

