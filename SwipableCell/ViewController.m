//
//  ViewController.m
//  SwipableCell
//
//  Created by DreamHack on 15-9-7.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import "ViewController.h"
#import "DHSwipableCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, DHSwipableCellDelegate>

@property (nonatomic, strong) NSMutableArray * objects;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * openedCells;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor purpleColor];
}

#pragma mark - protocol
- (NSInteger)numberOfItemsInCell:(DHSwipableCell *)cell
{
    if (cell.indexPath.row % 3) {
        return 3;
    }
    return 4;
}

- (id)swipableCell:(DHSwipableCell *)cell contentForItemAtIndex:(NSInteger)index
{
    return @"haha";
}

- (UIColor *)swipableCell:(DHSwipableCell *)cell colorForItemAtIndex:(NSInteger)index
{
    return [UIColor colorWithRed:arc4random()%256/255.f green:arc4random()%256/255.f blue:arc4random()%256/255.f alpha:1];
}

- (CGFloat)swipableCell:(DHSwipableCell *)cell widthForItemAtIndex:(NSInteger)index
{
    return 80;
}

- (void)swipableCell:(DHSwipableCell *)cell didClickOnItemAtIndex:(NSInteger)index
{
    NSLog(@"%ld",index);
}

- (void)didBeginEditingCell:(DHSwipableCell *)cell
{
    [self.openedCells addObject:cell];
}

- (void)didEndEditingCell:(DHSwipableCell *)cell
{
    [self.openedCells removeObject:cell];
}

#pragma mark - table view protocol
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.openedCells makeObjectsPerformSelector:@selector(close)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DHSwipableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdf" forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter

- (NSMutableArray *)objects
{
    if (!_objects) {
        _objects = ({
        
            NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
            
            for (int i = 0; i < 30; i++) {
                [array addObject:[NSString stringWithFormat:@"item #%d",i]];
            }
            
            array;
        
        });
    }
    return _objects;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
        
            UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
            tableView.tableFooterView = [[UIView alloc] init];
            [tableView registerClass:[DHSwipableCell class] forCellReuseIdentifier:@"cellIdf"];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView;
        
        });
    }
    return _tableView;
}

- (NSMutableArray *)openedCells
{
    if (!_openedCells) {
        _openedCells = [NSMutableArray arrayWithCapacity:0];
    }
    return _openedCells;
}

@end
