//
//  GameStauts.h
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/25.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MoveDirection) {
    MoveDirectionNone = 0,
    MoveDirectionUp,
    MoveDirectionLeft,
    MoveDirectionDown,
    MoveDirectionRight,
};

/// 一个实例代表一种状态
@interface GameStauts : NSObject


/// 矩阵维数，初始为3
@property (nonatomic, assign) NSInteger dimension;
/// 元素存储序列。空格的值为@-1
@property (nonatomic, strong) NSMutableArray<NSNumber *> *order;
/// 空格的位置。初始为-1，没有空格。值从0开始
@property (nonatomic, assign) NSInteger emptyIndex;
/// 父状态，上一个状态
@property (nonatomic, strong) GameStauts *parent;

// A*算法专用
@property (nonatomic, assign) NSInteger aStarF;
@property (nonatomic, assign) NSInteger aStarG;
@property (nonatomic, assign) NSInteger aStarH;

/// 创建实例
+ (instancetype)statusWithDimension:(NSInteger)dimension emptyIndex:(NSInteger)emptyIndex;

/// 重置成目标状态
- (void)becomeTargetStatus;

/// 打乱当前状态，变成另一种状态
- (void)shuffle;

/// 空格是否能移动
- (BOOL)canMoveWithDirection:(MoveDirection)direction;

/// 空格移动
- (void)moveWithDirection:(MoveDirection)direction;

/// 取存储序列元素所在的矩阵行。从0开始
- (NSInteger)rowOfIndex:(NSInteger)index;

/// 取存储序列元素所在的矩阵列。从0开始
- (NSInteger)colOfIndex:(NSInteger)index;

/// 用字符串表示本状态。一种状态唯一生成一个字符串。
- (NSString *)idKey;

/// 判断两个实例是否等价
- (BOOL)isEqualTo:(GameStauts *)status;

/// 生成邻居节点，从本状态扩展出新的状态。本方法不检查扩展的状态是否有效
- (instancetype)neighborStatusWithDirection:(MoveDirection)direction;

/// 生成有效的邻居节点集
- (NSMutableArray<GameStauts *> *)effectiveNeighborStatus;

/// 估价函数，估算从本状态到给定目标状态的代价
- (NSInteger)estimateToTarget:(GameStauts *)targetStatus;



@end
