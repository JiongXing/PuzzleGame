//
//  ViewController.m
//  PuzzleGame
//
//  Created by JiongXing on 2016/11/11.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "ViewController.h"
#import "PuzzleStatus.h"
#import "JXBreadthFirstSearcher.h"
#import "JXDoubleBreadthFirstSearcher.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *hardButton;
@property (weak, nonatomic) IBOutlet UIButton *aiButton;
@property (weak, nonatomic) IBOutlet UIButton *autoButton;

#pragma mark - 选项
/// 图片
@property (nonatomic, strong) UIImage *image;
/// 矩阵维数
@property (nonatomic, assign) NSInteger dimension;
/// 当前算法。0：广搜； 1：双向广搜； 2：A*算法
@property (nonatomic, assign) NSInteger algorithm;

#pragma mark - 状态
/// 当前游戏状态
@property (nonatomic, strong) PuzzleStatus *currentStatus;
/// 完成时的游戏状态
@property (nonatomic, strong) PuzzleStatus *completedStatus;
/// 保存的游戏状态
@property (nonatomic, strong) PuzzleStatus *savedStatus;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dimension = 3;
    self.algorithm = 1;
}

/// 选择图片
- (IBAction)onSelectPictureButton:(UIButton *)sender {
    self.image = [UIImage imageNamed:@"luffy"];
}

/// 打乱顺序
- (IBAction)onShuffleButton:(UIButton *)sender {
    [self.currentStatus shuffleCount:self.dimension * self.dimension * 5];
    [self reloadWithStatus:self.currentStatus];
}

/// 重置游戏
- (IBAction)onResetButton:(UIButton *)sender {
    if (!self.image) {
        return;
    }
    
    if (self.currentStatus) {
        [self.currentStatus removeAllPieces];
    }
    self.currentStatus = [PuzzleStatus statusWithDimension:self.dimension image:self.image];
    [self.currentStatus.pieceArray enumerateObjectsUsingBlock:^(PuzzlePiece * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addTarget:self action:@selector(onPieceTouch:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    self.completedStatus = [self.currentStatus  copyStatus];
    [self showCurrentStatusOnView:self.bgView];
}

/// 难度切换
- (IBAction)onHardButton:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择难度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"高" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.dimension = 5;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"中" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.dimension = 4;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"低" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.dimension = 3;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 算法切换
- (IBAction)onAiButton:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择AI算法" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"广搜" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 0;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"双向广搜" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 1;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"A*搜索" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.algorithm = 2;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 自动完成
- (IBAction)onAutoButton:(UIButton *)sender {
    JXPathSearcher *searcher = nil;
    switch (self.algorithm) {
        case 0:
            searcher = [[JXBreadthFirstSearcher alloc] init];
            break;
        case 1:
            searcher = [[JXDoubleBreadthFirstSearcher alloc] init];
            break;
        case 2:
            searcher = [[JXBreadthFirstSearcher alloc] init];
            break;
        default:
            break;
    }
    
    searcher.startStatus = self.currentStatus;
    searcher.targetStatus = self.completedStatus;
    [searcher setEqualComparator:^BOOL(PuzzleStatus *status1, PuzzleStatus *status2) {
        return [status1 equalWithStatus:status2];
    }];
    NSMutableArray<PuzzleStatus *> *path = [searcher search];
    NSLog(@"path count:%ld", path.count);
    
    if (!path || path.count == 0) {
        return;
    }
    
    // 展示路径
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_semaphore_signal(sema);
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [path enumerateObjectsUsingBlock:^(PuzzleStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 等待信号
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            // 刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadWithStatus:obj];
                NSLog(@"%@", [obj statusIdentifier]);
            });
        }];
        [timer invalidate];
        self.currentStatus = [path lastObject];
    });
}

/// 保存进度
- (IBAction)onSaveButton:(UIButton *)sender {
    self.savedStatus = [self.currentStatus  copyStatus];
    [self alertTitle:nil message:@"保存成功"];
}

/// 读取进度
- (IBAction)onLoadButton:(UIButton *)sender {
    if (self.currentStatus) {
        [self.currentStatus removeAllPieces];
    }
    self.currentStatus = self.savedStatus;
    
    [self showCurrentStatusOnView:self.bgView];
    [self alertTitle:nil message:@"读取成功"];
}

/// 点击方块
- (void)onPieceTouch:(PuzzlePiece *)piece {
    PuzzleStatus *status = self.currentStatus;
    NSInteger pieceIndex = [status.pieceArray indexOfObject:piece];
    if (status.emptyIndex < 0) {
        // 所选方块成为空格
        [UIView animateWithDuration:0.25 animations:^{
            piece.alpha = 0;
        }];
        status.emptyIndex = pieceIndex;
        return;
    }
    
    NSLog(@"current:%@", [status statusIdentifier]);
    if (![status canMoveToIndex:pieceIndex]) {
        NSLog(@"无法移动，to index:%@",  @(pieceIndex));
        return;
    }
    
    [status moveToIndex:pieceIndex];
    [self reloadWithStatus:self.currentStatus];
    
    // 完成一次移动
    if ([status equalWithStatus:self.completedStatus]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self alertTitle:@"恭喜" message:@"拼图完成！"];
        });
    }
}

- (void)showCurrentStatusOnView:(UIView *)view {
    CGFloat size = CGRectGetWidth(view.bounds) / self.dimension;
    
    NSInteger index = 0;
    for (NSInteger row = 0; row < self.dimension; ++ row) {
        for (NSInteger col = 0; col < self.dimension; ++ col) {
            PuzzlePiece *piece = self.currentStatus.pieceArray[index ++];
            piece.frame = CGRectMake(col * size, row * size, size, size);
            [view addSubview:piece];
        }
    }
}

- (void)reloadWithStatus:(PuzzleStatus *)status {
    [UIView animateWithDuration:0.25 animations:^{
        CGSize size = status.pieceArray.firstObject.frame.size;
        NSInteger index = 0;
        for (NSInteger row = 0; row < self.dimension; ++ row) {
            for (NSInteger col = 0; col < self.dimension; ++ col) {
                PuzzlePiece *piece = status.pieceArray[index ++];
                piece.frame = CGRectMake(col * size.width, row * size.height, size.width, size.height);
            }
        }
    }];
}

- (void)setDimension:(NSInteger)dimension {
    if (dimension < 3 || dimension > 5) {
        return;
    }
    _dimension = dimension;
    NSString *title;
    if (dimension == 3) {
        title = @"难度：低";
    }
    else if (dimension == 4) {
        title = @"难度：中";
    }
    else if (dimension == 5) {
        title = @"难度：高";
    }
    [self.hardButton setTitle:title forState:UIControlStateNormal];
    [self onResetButton:nil];
}

- (void)setAlgorithm:(NSInteger)algorithm {
    if (algorithm < 0 || algorithm > 2) {
        return;
    }
    _algorithm = algorithm;
    NSString *title;
    if (algorithm == 0) {
        title = @"AI：广搜";
    }
    else if (algorithm == 1) {
        title = @"AI：双向广搜";
    }
    else if (algorithm == 2) {
        title = @"AI：A*算法";
    }
    [self.aiButton setTitle:title forState:UIControlStateNormal];
    [self onResetButton:nil];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self onResetButton:nil];
}

/// 用户提示
- (void)alertTitle:(NSString *)title message:(NSString *)message {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
