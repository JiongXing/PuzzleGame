//
//  JXPathSearcher.h
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/13.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 状态协议
@protocol JXPathSearcherStatus <NSObject>

/// 父状态
@property (nonatomic, strong) id<JXPathSearcherStatus> parentStatus;

/// 此状态的唯一标识
- (NSString *)statusIdentifier;

/// 取所有邻近状态(子状态)，排除父状态。每一个状态都需要给parentStatus赋值。
- (NSMutableArray<id<JXPathSearcherStatus>> *)childStatus;

@end

/// 比较器定义
typedef BOOL(^JXPathSearcherEqualComparator)(id<JXPathSearcherStatus> status1, id<JXPathSearcherStatus> status2);

/// 路径搜索
@interface JXPathSearcher : NSObject

/// 开始状态
@property (nonatomic, strong) id<JXPathSearcherStatus> startStatus;

/// 目标状态
@property (nonatomic, strong) id<JXPathSearcherStatus> targetStatus;

/// 比较器
@property (nonatomic, strong) JXPathSearcherEqualComparator equalComparator;

/// 开始搜索，返回搜索结果。无法搜索时返回nil
- (NSMutableArray *)search;

/// 构建路径。isLast表示传入的status是否路径的最后一个元素
- (NSMutableArray *)constructPathWithStatus:(id<JXPathSearcherStatus>)status isLast:(BOOL)isLast;

@end
