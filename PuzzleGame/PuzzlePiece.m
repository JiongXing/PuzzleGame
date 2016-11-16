//
//  PuzzlePiece.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "PuzzlePiece.h"

@implementation PuzzlePiece

+ (instancetype)pieceWithID:(NSInteger)ID image:(UIImage *)image {
    PuzzlePiece *piece = [[PuzzlePiece alloc] init];
    piece.ID = ID;
    piece.layer.borderWidth = 1;
    piece.layer.borderColor = [UIColor whiteColor].CGColor;
    [piece setBackgroundImage:image forState:UIControlStateNormal];
    return piece;
}

@end
