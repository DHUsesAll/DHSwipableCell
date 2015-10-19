//
//  DHSwipableCell.h
//  SwipableCell
//
//  Created by DreamHack on 15-10-19.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHSwipableCell;

// 包含了item的样式、点击事件和各种代理事件
@protocol DHSwipableCellDelegate <NSObject>

// item的index是从左往右数的
// 要多少个item
- (NSInteger)numberOfItemsInCell:(DHSwipableCell *)cell;

// 返回图片或者文字（UIImage或者NSString）
- (id)swipableCell:(DHSwipableCell *)cell contentForItemAtIndex:(NSInteger)index;

// 每个item的背景颜色
- (UIColor *)swipableCell:(DHSwipableCell *)cell colorForItemAtIndex:(NSInteger)index;

// 每个item的宽度
- (CGFloat)swipableCell:(DHSwipableCell *)cell widthForItemAtIndex:(NSInteger)index;

// item点击事件
- (void)swipableCell:(DHSwipableCell *)cell didClickOnItemAtIndex:(NSInteger)index;

// item完全展开后
- (void)didBeginEditingCell:(DHSwipableCell *)cell;

// item完全关闭后
- (void)didEndEditingCell:(DHSwipableCell *)cell;


@end



@interface DHSwipableCell : UITableViewCell

@property (nonatomic, weak) id <DHSwipableCellDelegate> delegate;

/**
 *  子类化这个cell，把自定义view加到这个view上面，不要直接用系统的contentView
 */
@property (nonatomic, strong, readonly) UIView * privateContentView;
/**
 *  在tableView中返回cell的方法里面给它赋值。可选
 */
@property (nonatomic, copy) NSIndexPath * indexPath;

/**
 *  关闭items。建议在tableView即将滑动的时候把所有打开的cell全部关闭。详情见demo
 */
- (void)close;

@end
