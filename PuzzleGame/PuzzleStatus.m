//
//  PuzzleStatus.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "PuzzleStatus.h"

@implementation PuzzleStatus {
    PuzzleStatus *_parentStatus;
}

+ (instancetype)statusWithDimension:(NSInteger)dimension image:(UIImage *)image {
    if (dimension < 3 || !image) {
        return nil;
    }
    
    PuzzleStatus *status = [[PuzzleStatus alloc] init];
    status.dimension = dimension;
    status.pieceArray = [NSMutableArray arrayWithCapacity:dimension * dimension];
    status.emptyIndex = -1;
    
    CGFloat pieceImageWidh = image.size.width / dimension;
    CGFloat pieceImageHeight = image.size.height / dimension;
    
    NSInteger ID = 0;
    for (NSInteger row = 0; row < dimension; row ++) {
        for (NSInteger col = 0; col < dimension; col ++) {
            // 切割图片
            CGRect rect = CGRectMake(col * pieceImageWidh, row * pieceImageHeight, pieceImageWidh, pieceImageHeight);
            CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            PuzzlePiece *piece = [PuzzlePiece pieceWithID:[NSString stringWithFormat:@"%@", @(ID ++)] image:[UIImage imageWithCGImage:imgRef]];
            [status.pieceArray addObject:piece];
        }
    }
    return status;
}

- (instancetype)copyStatus {
    PuzzleStatus *status = [[PuzzleStatus alloc] init];
    status.dimension = self.dimension;
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
    NSLog(@"随机%@步", @(count));
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
    return index / self.dimension;
}

/// 求列号
- (NSInteger)colOfIndex:(NSInteger)index {
    return index % self.dimension;
}

/// 空格是否能移动到某个位置
- (BOOL)canMoveToIndex:(NSInteger)index {
    // 能移动的条件是
    // 1.没有超出边界
    // 2.空格和目标位置处于同一行或同一列
    return ([self rowOfIndex:self.emptyIndex] == [self rowOfIndex:index]) ||
            ([self colOfIndex:self.emptyIndex] == [self colOfIndex:index]);
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
    return self.emptyIndex - self.dimension;
}

- (NSInteger)downIndex {
    if ([self rowOfIndex:self.emptyIndex] == self.dimension - 1) {
        return -1;
    }
    return self.emptyIndex + self.dimension;
}

- (NSInteger)leftIndex {
    if ([self colOfIndex:self.emptyIndex] == 0) {
        return -1;
    }
    return self.emptyIndex - 1;
}

- (NSInteger)rightIndex {
    if ([self colOfIndex:self.emptyIndex] == self.dimension - 1) {
        return -1;
    }
    return self.emptyIndex + 1;
}

#pragma mark - 状态协议
- (NSString *)statusIdentifier {
    NSMutableString *str = [NSMutableString string];
    [self.pieceArray enumerateObjectsUsingBlock:^(PuzzlePiece * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@,", obj.ID];
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

@end
