//
//  PRKTableViewController.h
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PRKTableViewDataSource;

@protocol PRKTableViewController
@required
@property (nonatomic, strong) UITableView *tableView;
@end

@interface PRKTableViewController : UIViewController
<UITableViewDelegate,PRKTableViewController>
{
    UITableView*  _tableView;
    
    UITableViewStyle        _tableViewStyle;
    
    id<PRKTableViewDataSource> _dataSource;
}
// 由于集成了SVPullToRefresh,并且需要适配iOS7的毛玻璃效果,需要改变contentInset需要用该方法
@property (nonatomic, assign) UIEdgeInsets tableViewContentInsets;

@property (nonatomic, strong) UITableView* tableView;

/**
 * The data source used to populate the table view.
 *
 * Setting dataSource has the side effect of also setting model to the value of the
 * dataSource's model property.
 */
@property (nonatomic, strong) id<PRKTableViewDataSource> dataSource;

/**
 * The style of the table view.
 */
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

/**
 * Initializes and returns a controller having the given style.
 */
- (id)initWithStyle:(UITableViewStyle)style;

/**
 * Tells the controller that the user selected an object in the table.
 *
 * By default, the object's URLValue will be opened in TTNavigator, if it has one. If you don't
 * want this to be happen, be sure to override this method and be sure not to call super.
 */
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * 下拉刷新需要执行的方法
 */
//- (void)pullToRefreshAction;
/**
 * 上拉刷新需要执行得方法
 */
//- (void)infiniteScrollingAction;
/**
 * 停止以上刷新状态
 * [self.tableView.pullToRefreshView stopAnimating];     停止下拉刷新
 * [self.tableView.infiniteScrollingView stopAnimating]; 停止上拉刷新
 */
//- (void)stopRefreshAction;

@end

