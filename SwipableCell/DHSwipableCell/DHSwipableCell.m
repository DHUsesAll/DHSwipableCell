//
//  DHSwipableCell.m
//  SwipableCell
//
//  Created by DreamHack on 15-10-19.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import "DHSwipableCell.h"

enum {
    ButtonTag = 1000
};

@interface DHSwipableCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * privateContentView;
@property (nonatomic, strong) UIView * buttonContainerView;

@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;

@property (nonatomic, assign) CGFloat sumOfWidth;

@end

@implementation DHSwipableCell

- (void)awakeFromNib {
    [self initializeAppearance];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)layoutSubviews
{
    // 一定要调super，否则会出现各种显示的问题
    [super layoutSubviews];
    // 因为self.contentView是在tableView完全初始化出来后才会布局的，所以我们在这个方法里面保证privateContentView和contentView完全重合。当然用约束也是可以的
    self.privateContentView.frame = self.contentView.bounds;
}

#pragma mark - private methods
- (void)initializeAppearance
{
    // 视图层级结构：self.contentView - self.buttonContainerView - self.privateContentView
    // buttonContainerView是开始左滑的时候才加载上去的，使用insertSubview:below...
    [self.contentView addSubview:self.privateContentView];
}

// 当各个item马上需要显示的时候（左滑开始）才加载buttonContainerView以节约内存
- (void)addButtons
{
    // 让buttons只加一次
    if (self.buttonContainerView.superview) {
        return;
    }
    [self.contentView insertSubview:self.buttonContainerView belowSubview:self.privateContentView];
}

// items关闭后将它们移除以节约内存
- (void)removeButtons
{
    if (!self.buttonContainerView.superview) {
        return;
    }
    [self.buttonContainerView removeFromSuperview];
}

// 动画打开items，当手指松开后，如果有打开的趋势，则动画打开
- (void)open
{
    [UIView animateWithDuration:0.28 animations:^{
        self.privateContentView.frame = CGRectOffset(self.contentView.bounds, -self.sumOfWidth, 0);
    } completion:^(BOOL finished) {
        // 打开完成后添加单击手势以单击关闭
        [self addTap];
        // 调用代理方法
        [self.delegate didBeginEditingCell:self];
    }];
}

// 动画关闭，提供给外部。打开后单击这个cell会关闭、手指松开后如果有关闭的趋势则也调用这个方法关闭
- (void)close
{
    [UIView animateWithDuration:0.28 animations:^{
        self.privateContentView.frame = self.contentView.bounds;
    } completion:^(BOOL finished) {
        // 关闭后移除items
        [self removeButtons];
        // 移除单击手势
        [self removeTap];
        // 调用代理方法
        [self.delegate didEndEditingCell:self];
    }];
}

// 添加单击手势，单击以关闭打开的items
- (void)addTap
{
    [self.privateContentView addGestureRecognizer:self.tapGesture];
}

// 移除单击手势
- (void)removeTap
{
    [self.privateContentView removeGestureRecognizer:self.tapGesture];
}

#pragma mark - callback
- (void)onPanGestureRecognizer:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 如果一开始的手指是向右滑的，那么我们不添加items
        if (velocity.x > 0) {
            return;
        }
        // 在手指向左滑开始的时候添加items
        [self addButtons];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:sender.view];
        // 使用translation（位移）能保证：如果一开始的手指向右滑，滑到一半重新向左滑也能处理这样的打开items的操作
        if (translation.x < 0) {
            // 该添加items的时候添加
            [self addButtons];
            // 如果滑动的位移超过了所有items的宽的和，则直接指定privateContentView到达展开items后的状态
            if (fabs(translation.x) > self.sumOfWidth) {
                self.privateContentView.frame = CGRectOffset(self.contentView.bounds, -self.sumOfWidth, 0);
                return;
            }
            // 手指滑了多少，它也移动多少
            self.privateContentView.frame = CGRectOffset(self.contentView.bounds, translation.x, 0);
        }
        
    } else if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded) {
        // 如果有向右滑动的趋势，则关闭
        if (velocity.x > 0) {
            [self close];
        } else {
            // 否则就打开
            [self open];
        }
        
        
    }
}

// 单击手势，关闭items
- (void)onTap:(UITapGestureRecognizer *)sender
{
    [self close];
}

// 每个item的点击事件
- (void)onButton:(UIButton *)sender
{
    // 直接调用代理方法
    [self.delegate swipableCell:self didClickOnItemAtIndex:sender.tag - ButtonTag];
}

#pragma mark - protocol
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 我们只处理self.panGesture的情况
    if (gestureRecognizer != self.panGesture) {
        return YES;
    }
    
    // 如果我们自定义的pan手势的左右滑动的速度太小，则我们不响应它，这样就会响应，否则这次响应由于响应链的关系，tableView无法接收这次响应，也就是滑不动
    CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
    if (fabs(velocity.x) < 5) {
        return NO;
    }
    
    return YES;
}

#pragma mark - getter
- (UIView *)privateContentView
{
    if (!_privateContentView) {
        _privateContentView = [[UIView alloc] init];
        _privateContentView.backgroundColor   = [UIColor whiteColor];
        [_privateContentView addGestureRecognizer:self.panGesture];
    }
    return _privateContentView;
}

- (UIView *)buttonContainerView
{
    if (!_buttonContainerView) {
        _buttonContainerView = ({
        
            UIView * view = [[UIView alloc] initWithFrame:self.contentView.bounds];
            
            NSInteger numberOfItems = [self.delegate numberOfItemsInCell:self];
            for (int i = 0; i < numberOfItems; i++) {
                // 由于正向布局比较麻烦，我们从最后一个item反向向前布局，这样计算x坐标的时候只需要用cell的宽度减去当前已经加载的item的总宽度就行了
                NSInteger index = numberOfItems - i - 1;
                // 用代理获取宽度
                CGFloat width = [self.delegate swipableCell:self widthForItemAtIndex:index];
                // 叠加总宽度
                self.sumOfWidth += width;
                // 用代理获取item显示内容
                id content = [self.delegate swipableCell:self contentForItemAtIndex:index];
                // 用代理获取背景颜色
                UIColor * color = [self.delegate swipableCell:self colorForItemAtIndex:index];
                
                UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(CGRectGetWidth(view.bounds) - self.sumOfWidth, 0, width, CGRectGetHeight(view.bounds));
                button.backgroundColor = color;
                if ([content isKindOfClass:[NSString class]]) {
                    [button setTitle:content forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                } else if ([content isKindOfClass:[UIImage class]]) {
                    [button setImage:content forState:UIControlStateNormal];
                }
                
                button.tag = ButtonTag + index;
                [button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:button];
                
            }
            
            view;
        
        });
    }
    return _buttonContainerView;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizer:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    }
    return _tapGesture;
}

@end
