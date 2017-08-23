//
//  PuzzleStatus.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "PuzzleStatus.h"

@interface PuzzleStatus ()

@end

@implementation PuzzleStatus {
    id<JXPathSearcherStatus> _parentStatus;
    NSInteger _gValue;
    NSInteger _hValue;
    NSInteger _fValue;
}

+ (instancetype)statusWithMatrixOrder:(NSInteger)matrixOrder image:(UIImage *)image {
    if (matrixOrder < 3 || !image) {
        return nil;
    }
    
    PuzzleStatus *status = [[PuzzleStatus alloc] init];
    status.matrixOrder = matrixOrder;
    status.pieceArray = [NSMutableArray arrayWithCapacity:matrixOrder * matrixOrder];
    status.emptyIndex = -1;
    
    CGFloat pieceImageWidh = image.size.width / matrixOrder;
    CGFloat pieceImageHeight = image.size.height / matrixOrder;
    
    NSInteger ID = 0;
    for (NSInteger row = 0; row < matrixOrder; row ++) {
        for (NSInteger col = 0; col < matrixOrder; col ++) {
            // 切割图片
            CGRect rect = CGRectMake(col * pieceImageWidh, row * pieceImageHeight, pieceImageWidh, pieceImageHeight);
            CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            PuzzlePiece *piece = [PuzzlePiece pieceWithID:ID ++ image:[UIImage imageWithCGImage:imgRef]];
            [status.pieceArray addObject:piece];
        }
    }
    return status;
}

- (instancetype)copyStatus {
    PuzzleStatus *status = [[PuzzleStatus alloc] init];
    status.matrixOrder = self.matrixOrder;
    status.pieceArray = [self.pieceArray mutableCopy];
    status.emptyIndex = self.emptyIndex;
    return status;
}

- (BOOL)equalWithStatus:(PuzzleStatus *)status {
    return [self.pieceArray isEqualToArray:status.pieceArray];
}

- (void)removeAllPieces {
    [self.pieceArray enumerateObjectsUsingBlock:^(PuzzlePiece * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)shuffleCount:(NSInteger)count {
    // 记录前置状态，避免来回移动
    // 前两个状态的空格位置
    NSInteger ancestorIndex = -1;
    // 前一个状态的空格位置
    NSInteger parentIndex = -1;
    while (count > 0) {
        NSInteger targetIndex = -1;
        switch (arc4random() % 4) {
            case 0:
                targetIndex = [self upIndex];
                break;
            case 1:
                targetIndex = [self downIndex];
                break;
            case 2:
                targetIndex = [self leftIndex];
                break;
            case 3:
                targetIndex = [self rightIndex];
                break;
            default:
                break;
        }
        
        if (targetIndex != -1 && targetIndex != ancestorIndex) {
            [self moveToIndex:targetIndex];
            ancestorIndex = parentIndex;
            parentIndex = targetIndex;
            count --;
        }
    }
}

/// 求行号
- (NSInteger)rowOfIndex:(NSInteger)index {
    return index / self.matrixOrder;
}

/// 求列号
- (NSInteger)colOfIndex:(NSInteger)index {
    return index % self.matrixOrder;
}

/// 空格是否能移动到某个位置
- (BOOL)canMoveToIndex:(NSInteger)index {
    // 能移动的条件是
    // 1.没有超出边界
    // 2.空格和目标位置处于同一行或同一列 且相邻
    BOOL canRow = ([self rowOfIndex:self.emptyIndex] == [self rowOfIndex:index]) && (labs([self colOfIndex:self.emptyIndex] - [self colOfIndex:index]) == 1);
    BOOL canCol = ([self colOfIndex:self.emptyIndex] == [self colOfIndex:index]) && (labs([self rowOfIndex:self.emptyIndex] - [self rowOfIndex:index]) == 1);
    
    return (canRow || canCol);
}

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index {
    PuzzlePiece *temp = self.pieceArray[self.emptyIndex];
    self.pieceArray[self.emptyIndex] = self.pieceArray[index];
    self.pieceArray[index] = temp;
    
    self.emptyIndex = index;
}

- (NSInteger)upIndex {
    if ([self rowOfIndex:self.emptyIndex] == 0) {
        return -1;
    }
    return self.emptyIndex - self.matrixOrder;
}

- (NSInteger)downIndex {
    if ([self rowOfIndex:self.emptyIndex] == self.matrixOrder - 1) {
        return -1;
    }
    return self.emptyIndex + self.matrixOrder;
}

- (NSInteger)leftIndex {
    if ([self colOfIndex:self.emptyIndex] == 0) {
        return -1;
    }
    return self.emptyIndex - 1;
}

- (NSInteger)rightIndex {
    if ([self colOfIndex:self.emptyIndex] == self.matrixOrder - 1) {
        return -1;
    }
    return self.emptyIndex + 1;
}

#pragma mark - 状态(结点)协议
- (NSString *)statusIdentifier {
    NSMutableString *str = [NSMutableString string];
    [self.pieceArray enumerateObjectsUsingBlock:^(PuzzlePiece * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%ld,", obj.ID];
    }];
    return str;
}

- (void)setParentStatus:(id<JXPathSearcherStatus>)parentStatus {
    _parentStatus = parentStatus;
}

- (id<JXPathSearcherStatus>)parentStatus {
    return _parentStatus;
}

- (NSMutableArray<id<JXPathSearcherStatus>> *)childStatus {
    NSMutableArray *array = [NSMutableArray array];
    NSInteger targetIndex = -1;
    if ((targetIndex = [self upIndex]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self downIndex]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self leftIndex]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self rightIndex]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    return array;
}

- (void)addChildStatusIndex:(NSInteger)index toArray:(NSMutableArray *)array {
    // 排除父状态
    if ([self parentStatus] && [(PuzzleStatus *)[self parentStatus] emptyIndex] == index) {
        return;
    }
    if (![self canMoveToIndex:index]) {
        return;
    }
    PuzzleStatus *status = [self copyStatus];
    [status moveToIndex:index];
    [array addObject:status];
    status.parentStatus = self;
}

#pragma mark - A*搜索状态(结点)协议
- (NSInteger)gValue {
    return _gValue;
}

- (void)setGValue:(NSInteger)gValue {
    _gValue = gValue;
}

- (NSInteger)hValue {
    return _hValue;
}

- (void)setHValue:(NSInteger)hValue {
    _hValue = hValue;
}

- (NSInteger)fValue {
    return _fValue;
}

- (void)setFValue:(NSInteger)fValue {
    _fValue = fValue;
}

/// 估算从当前状态到目标状态的代价
- (NSInteger)estimateToTargetStatus:(id<JXPathSearcherStatus>)targetStatus {
    PuzzleStatus *target = (PuzzleStatus *)targetStatus;
    
    // 计算每一个方块距离它正确位置的距离
    // 曼哈顿距离
    NSInteger manhattanDistance = 0;
    for (NSInteger index = 0; index < self.pieceArray.count; ++ index) {
        // 略过空格
        if (index == self.emptyIndex) {
            continue;
        }
        
        PuzzlePiece *currentPiece = self.pieceArray[index];
        PuzzlePiece *targetPiece = target.pieceArray[index];
        
        manhattanDistance +=
        ABS([self rowOfIndex:currentPiece.ID] - [target rowOfIndex:targetPiece.ID]) +
        ABS([self colOfIndex:currentPiece.ID] - [target colOfIndex:targetPiece.ID]);
    }
    
    // 增大权重
    return 5 * manhattanDistance;
}

@end
