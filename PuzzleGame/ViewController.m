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
@property (weak, nonatomic) IBOutlet UIButton *aiButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *autoButton;

/// 矩阵元素数组
@property (nonatomic, strong) NSMutableArray<UIView *> *viewArray;
/// 挖空的元素
@property (nonatomic, weak) UIView *emptyView;
/// 当前状态
@property (nonatomic, strong) GameStauts *currentStatus;
/// 目标状态
@property (nonatomic, strong) GameStauts *targetStatus;

/// 图片
@property (nonatomic, strong) UIImage *image;
/// 当前算法。0：广搜； 1：双向广搜； 2：A*搜索
@property (nonatomic, assign) NSInteger algorithm;
/// 保存的状态
@property (nonatomic, strong) GameStauts *savedStatus;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.algorithm = 1;
    self.viewArray = [NSMutableArray array];
    self.currentStatus = [GameStauts statusWithDimension:3 emptyIndex:-1];
    self.targetStatus = [GameStauts statusWithDimension:3 emptyIndex:-1];
}

/// 重置游戏
- (void)reset {
    UIImage *image = self.image;
    if (!image) {
        image = [UIImage imageNamed:@"luffy"];
    }
    
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

/// 难度选择
- (IBAction)onLevelButton:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择难度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"高" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.currentStatus.dimension = 5;
        [weakSelf reset];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"中" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.currentStatus.dimension = 4;
        [weakSelf reset];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"低" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.currentStatus.dimension = 3;
        [weakSelf reset];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 选图
- (IBAction)onSelectButton:(UIButton *)sender {
    self.image = [UIImage imageNamed:@"luffy"];;
    [self reset];
}

/// 打乱
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
    [self refreshGameStatus];
}

/// 算法切换
- (IBAction)onAIButton:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择AI" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"广搜" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 0;
        [weakSelf.aiButton setTitle:@"AI：广搜" forState:UIControlStateNormal];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"双向广搜" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 1;
        [weakSelf.aiButton setTitle:@"AI：双向广搜" forState:UIControlStateNormal];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"A*搜索" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 2;
        [weakSelf.aiButton setTitle:@"AI：A*搜索" forState:UIControlStateNormal];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 下一步
- (IBAction)onNextButton:(UIButton *)sender {
}

/// 自动
- (IBAction)onAutoButton:(UIButton *)sender {
    if (self.viewArray.count == 0) {
        [self showMessage:@"请选一张图"];
        return;
    }
    if (self.currentStatus.emptyIndex < 0) {
        [self showMessage:@"请挖空一格"];
        return;
    }
    
    // 算法
    NSMutableArray<GameStauts *> *path = nil;
    switch (self.algorithm) {
        case 0:
            path = [Algorithm breadthFirstSearchWithStartStatus:self.currentStatus targetStatus:self.targetStatus];
            break;
        case 1:
            path = [Algorithm doubleBreadthFirstSearchWithStartStatus:self.currentStatus targetStatus:self.targetStatus];
            break;
        case 2:
            path = [Algorithm aStarSearchWithStartStatus:self.currentStatus targetStatus:self.targetStatus];
            break;
        default:
            break;
    }
    NSLog(@"current:%@", [self.currentStatus idKey]);
    NSLog(@"target :%@", [self.targetStatus idKey]);
    if (!path || path.count == 0) {
        return;
    }
    [path removeObjectAtIndex:0];
    NSLog(@"总共需要移动%@步", @(path.count));
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [path enumerateObjectsUsingBlock:^(GameStauts * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentStatus = obj;
                [self refreshGameStatus];
            });
        }];
        [timer invalidate];
    });
}

/// 保存进度
- (IBAction)onSaveButton:(UIButton *)sender {
    self.savedStatus = [self.currentStatus mutableCopy];
    self.savedStatus.emptyIndex = self.currentStatus.emptyIndex;
    [self showMessage:@"已保存当前状态"];
}

/// 读取进度
- (IBAction)onReadButton {
    if (!self.savedStatus) {
        return;
    }
    self.currentStatus = self.savedStatus;
    self.savedStatus = nil;
    [self refreshGameStatus];
}

/// 点中方块
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
    NSInteger fromRow = [self.currentStatus rowOfIndex:self.currentStatus.emptyIndex];
    NSInteger fromCol = [self.currentStatus colOfIndex:self.currentStatus.emptyIndex];
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
        [self refreshGameStatus];
    }
    // 游戏完成判断
    if ([self.currentStatus isEqualTo:self.targetStatus]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showMessage:@"完成!"];
        });
    }
}

/// 刷新UI
- (void)refreshGameStatus {
    GameStauts *status = self.currentStatus;
//    NSLog(@"current:%@", [self.currentStatus idKey]);
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

/// 用户提示
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
