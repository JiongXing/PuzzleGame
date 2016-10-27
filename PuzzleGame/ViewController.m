//
//  ViewController.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/10/24.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "ViewController.h"
#import "GameStauts.h"
#import "Algorithm.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

/// 矩阵元素数组
@property (nonatomic, strong) NSMutableArray<UIView *> *viewArray;
/// 挖空的元素
@property (nonatomic, weak) UIView *emptyView;
/// 当前状态
@property (nonatomic, strong) GameStauts *currentStatus;
/// 目标状态
@property (nonatomic, strong) GameStauts *targetStatus;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Puzzle Game";
    
    self.viewArray = [NSMutableArray array];
    self.currentStatus = [GameStauts statusWithDimension:3 emptyIndex:-1];
    self.targetStatus = [GameStauts statusWithDimension:3 emptyIndex:-1];
}

- (IBAction)onSelectButton:(UIButton *)sender {
    UIImage *image = [UIImage imageNamed:@"luffy"];
    
    NSInteger dimension = self.currentStatus.dimension;
    CGFloat viewSize = self.bgView.bounds.size.width / dimension;
    CGFloat imageUnitSize = image.size.width / dimension;
    
    // 清空矩阵视图
    [self.viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.viewArray removeAllObjects];
    // 重置状态
    self.currentStatus = [GameStauts statusWithDimension:3 emptyIndex:-1];;
    
    // 建立视图矩阵
    // 视图序
    NSInteger index = 0;
    for (NSInteger row = 0; row < dimension; row ++) {
        for (NSInteger col = 0; col < dimension; col ++) {
            // 切割图片
            CGRect rect = CGRectMake(col * imageUnitSize, row * imageUnitSize, imageUnitSize, imageUnitSize);
            CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            
            // 元素视图
            UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(col * viewSize, row * viewSize, viewSize, viewSize);
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            [button setBackgroundImage:[UIImage imageWithCGImage:imgRef] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.bgView addSubview:button];
            [self.viewArray addObject:button];
            
            // tag值唯一代表这个button
            button.tag = index ++;
        }
    }
}

- (IBAction)onShuffleButton:(UIButton *)sender {
    if (self.viewArray.count == 0) {
        [self showMessage:@"请选一张图"];
        return;
    }
    if (self.currentStatus.emptyIndex < 0) {
        [self showMessage:@"请挖空一格"];
        return;
    }
    
    [self.currentStatus shuffle];
    [self renderWithGameStatus:self.currentStatus];
}

- (IBAction)onAutoButton:(UIButton *)sender {
    Algorithm *algo = [[Algorithm alloc] init];
    algo.sourceStatus = self.currentStatus;
    algo.targetStatus = self.targetStatus;
    NSMutableArray<GameStauts *> *path = [algo breadthFirstSearch];
    if (path.count > 0) {
        [path removeObjectAtIndex:0];
    }
    NSLog(@"结果路径总步数：%@", @(path.count));
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [path enumerateObjectsUsingBlock:^(GameStauts * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
            NSLog(@"%@", [obj toString]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self renderWithGameStatus:obj];
            });
        }];
        [timer invalidate];
    });
}

- (void)onButton:(UIButton *)button {
    if (!self.emptyView) {
        // 挖空此格
        self.currentStatus.emptyIndex = button.tag;
        [self.currentStatus becomeTargetStatus];
        self.targetStatus.emptyIndex = button.tag;
        [self.targetStatus becomeTargetStatus];
        button.tag = -1;
        
        self.emptyView = button;
        [UIView animateWithDuration:0.5 animations:^{
            button.alpha = 0.0;
        }];
        return;
    }
    
    // 求方向
    MoveDirection direction = MoveDirectionNone;
    NSInteger fromRow = self.currentStatus.rowOfEmpty;
    NSInteger fromCol = self.currentStatus.colOfEmpty;
    NSInteger toRow = button.frame.origin.y / button.frame.size.height;
    NSInteger toCol = button.frame.origin.x / button.frame.size.width;
    if (toRow < fromRow && toCol == fromCol) {
        direction = MoveDirectionUp;
    }
    else if (toRow > fromRow && toCol == fromCol) {
        direction = MoveDirectionDown;
    }
    else if (toCol < fromCol && toRow == fromRow) {
        direction = MoveDirectionLeft;
    }
    else if (toCol > fromCol && toRow == fromRow) {
        direction = MoveDirectionRight;
    }
    // 移动
    if ([self.currentStatus canMoveWithDirection:direction]) {
        [self.currentStatus moveWithDirection:direction];
        [self renderWithGameStatus:self.currentStatus];
    }
    // 游戏完成判断
    if ([self.currentStatus isEqualTo:self.targetStatus]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showMessage:@"完成!"];
        });
    }
}

- (void)renderWithGameStatus:(GameStauts *)status {
    void (^changeFrame)(UIView *, NSUInteger) = ^(UIView *view, NSUInteger index) {
        NSInteger row = index / status.dimension;
        NSInteger col = index % status.dimension;
        CGRect frame = view.frame;
        frame.origin.x = col * frame.size.height;
        frame.origin.y = row * frame.size.width;
        [UIView animateWithDuration:0.25 animations:^{
            view.frame = frame;
        }];
    };
    
    __weak UIView *emptyView = self.emptyView;
    [self.viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        // 搜索本view应处的位置
        [status.order enumerateObjectsUsingBlock:^(NSNumber * _Nonnull num, NSUInteger index, BOOL * _Nonnull stop) {
            if (view == emptyView && num.integerValue == -1) {
                changeFrame(emptyView, index);
                *stop = YES;
            }
            if (num.integerValue == view.tag) {
                changeFrame(view, index);
                *stop = YES;
            }
        }];
    }];
}

- (void)showMessage:(NSString *)message {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"嗯" style:UIAlertActionStyleDefault handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
