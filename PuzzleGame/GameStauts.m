//
//  GameStauts.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/25.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "GameStauts.h"

@implementation GameStauts

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dimension = 3;
        self.emptyIndex = -1;
    }
    return self;
}

+ (instancetype)statusWithDimension:(NSInteger)dimension emptyIndex:(NSInteger)emptyIndex {
    GameStauts *status = [[GameStauts alloc] init];
    status.dimension = dimension;
    status.emptyIndex = emptyIndex;
    return status;
}

- (void)becomeTargetStatus {
    [self.order removeAllObjects];
    
    NSInteger size = self.dimension * self.dimension;
    for (NSInteger index = 0; index < size; index ++) {
        NSNumber *value = (index == self.emptyIndex) ? @-1 : @(index);
        [self.order addObject:value];
    }
    [self printSelf:@"重置完成"];
}

- (void)shuffle {
    if (self.order.count == 0) {
        return;
    }
    for (NSInteger index = 0; index < 30; index ++) {
        MoveDirection direction = 1 + arc4random_uniform(4);
        if ([self canMoveWithDirection:direction]) {
            [self moveWithDirection:direction];
        }
    }
    [self printSelf:@"洗牌完成"];
}

- (BOOL)canMoveWithDirection:(MoveDirection)direction {
//    NSLog(@"期望移动方向：%@", @(direction));
    switch (direction) {
        case MoveDirectionUp:
            return self.rowOfEmpty != 0;
        case MoveDirectionLeft:
            return self.colOfEmpty != 0;
        case MoveDirectionDown:
            return self.rowOfEmpty != (self.dimension - 1);
        case MoveDirectionRight:
            return self.colOfEmpty != (self.dimension - 1);
        case MoveDirectionNone:
        default:
            return NO;
    }
}

- (void)moveWithDirection:(MoveDirection)direction {
    NSInteger oldPosition = self.emptyIndex;
    switch (direction) {
        case MoveDirectionLeft:
            self.emptyIndex --;
            break;
        case MoveDirectionRight:
            self.emptyIndex ++;
            break;
        case MoveDirectionUp:
            self.emptyIndex -= self.dimension;
            break;
        case MoveDirectionDown:
            self.emptyIndex += self.dimension;
            break;
        default:
            break;
    }
    NSNumber *emptyValue = self.order[oldPosition];
    self.order[oldPosition] = self.order[self.emptyIndex];
    self.order[self.emptyIndex ] = emptyValue;
//    [self printSelf:@"移动完成"];
}

- (NSInteger)rowOfEmpty {
    return self.emptyIndex / self.dimension;
}

- (NSInteger)colOfEmpty {
    return self.emptyIndex % self.dimension;
}

- (NSMutableArray<NSNumber *> *)order {
    if (!_order) {
        _order = [NSMutableArray array];
    }
    return _order;
}

- (void)printSelf:(NSString *)message {
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@:emptyIndex:%@, order:", message, @(self.emptyIndex)];
    [self.order enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@ ", obj];
    }];
    NSLog(@"%@", str);
}

- (NSString *)toString {
    return [self.order componentsJoinedByString:@","];
}

- (BOOL)isEqualTo:(GameStauts *)status {
    return [[self toString] isEqualToString:[status toString]];
}

- (instancetype)neighborStatusWithDirection:(MoveDirection)direction {
    GameStauts *status = [self mutableCopy];
    [status moveWithDirection:direction];
    return status;
}

- (id)mutableCopy {
    GameStauts *status = [GameStauts statusWithDimension:self.dimension emptyIndex:self.emptyIndex];
    status.order = [self.order mutableCopy];
    return status;
}


@end
