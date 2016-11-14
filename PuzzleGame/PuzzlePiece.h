//
//  PuzzlePiece.h
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PuzzlePiece : UIButton

/// 本方块在原图上的位置，从0开始编号
@property (nonatomic, copy) NSString *ID;

+ (instancetype)pieceWithID:(NSString *)ID image:(UIImage *)image;

@end
