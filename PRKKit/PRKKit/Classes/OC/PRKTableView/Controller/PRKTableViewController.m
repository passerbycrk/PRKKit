//
//  PRKTableViewController.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableViewController.h"
#import "SVPullToRefresh.h"
#import "NSObject+ClassName.h"
#import "UIWindow+RscExt.h"
#import "UIViewAdditions.h"
#import "UITableViewAdditions.h"
#import "PRKTableViewUtil.h"
#import "PRKTableView.h"
#import "PRKTableViewItem.h"
#import "PRKTableViewCell.h"
#import "PRKTableViewSectionedDataSource.h"
#import "PRKTableViewSectionObject.h"

@interface PRKTableViewController ()
@property (nonatomic, strong) UIView* tableOverlayView;
@property (nonatomic, strong) UIView* tableWatermarkView;
@end

@implementation PRKTableViewController

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView = nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super init]) {
		_tableViewStyle = style;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.automaticallyAdjustsScrollViewInsets = NO; // default: YES
    }
    return self;
}

-(void)setTableViewContentInsets:(UIEdgeInsets)tableViewContentInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_tableViewContentInsets, tableViewContentInsets)
        || !UIEdgeInsetsEqualToEdgeInsets(_tableView.contentInset, tableViewContentInsets)
        || !UIEdgeInsetsEqualToEdgeInsets(_tableView.scrollIndicatorInsets, tableViewContentInsets)) {
        _tableViewContentInsets = tableViewContentInsets;
        _tableView.contentInset = tableViewContentInsets;
        _tableView.scrollIndicatorInsets = tableViewContentInsets;
//        _tableView.pullToRefreshView.originalTopInset = tableViewContentInsets.top;
//        _tableView.pullToRefreshView.originalBottomInset = tableViewContentInsets.bottom;
//        _tableView.infiniteScrollingView.originalBottomInset = tableViewContentInsets.bottom;
    }
}

#pragma mark - Private

- (void)addToOverlayView:(UIView *)view
{
	if (!_tableOverlayView) {
		CGRect frame = [self rectForOverlayView];
		_tableOverlayView = [[UIView alloc] initWithFrame:frame];
	}
    NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];
    
    if (tableIndex != NSNotFound) {
        [_tableView.superview addSubview:_tableOverlayView];
    }
	[_tableOverlayView addSubview:view];
}

- (void)addToWatermarkView:(UIView *)view
{
	if (!_tableWatermarkView) {
		CGRect frame = [self rectForWatermarkView];
		_tableWatermarkView = [[UIView alloc] initWithFrame:frame];
	}
    // 水印
    /*
     NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];
     
     if (tableIndex != NSNotFound) {
     [_tableView.superview insertSubview:_tableWatermarkView belowSubview:_tableView];
     }
     //*/
    // 在tableview上
    [_tableView addSubview:_tableWatermarkView];
    [_tableView bringSubviewToFront:_tableWatermarkView];
	[_tableWatermarkView addSubview:view];
}

- (void)resetOverlayView
{
	if (_tableOverlayView && !_tableOverlayView.subviews.count) {
		[_tableOverlayView removeFromSuperview];
	}
}

- (void)resetWatermarkView
{
    if (_tableWatermarkView && !_tableWatermarkView.subviews.count) {
		[_tableWatermarkView removeFromSuperview];
	}
}

- (void)addSubviewOverTableView:(UIView *)view
{
	NSInteger tableIndex = [_tableView.superview.subviews
							indexOfObject:_tableView];
    
	if (NSNotFound != tableIndex) {
		[_tableView.superview addSubview:view];
	}
}

- (void)layoutOverlayView
{
	if (_tableOverlayView) {
		_tableOverlayView.frame = [self rectForOverlayView];
	}
}

- (void)layoutWatermarkView
{
    if (_tableWatermarkView) {
        _tableWatermarkView.frame = [self rectForWatermarkView];
    }
}

- (void)fadeOutView:(UIView *)view
{
	[UIView beginAnimations:nil context:(__bridge void*)view];
	[UIView setAnimationDuration:.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadingOutViewDidStop:finished:context:)];
	view.alpha = 0;
	[UIView commitAnimations];
}

- (void)fadingOutViewDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	UIView *view = (__bridge UIView *)context;
    
	[view removeFromSuperview];
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
//    // 在iOS7下,Push出来的self,会因为automaticallyAdjustsScrollViewInsets属性,自动偏移,所以做了该操作
//    if (IS_IOS7_LATER && self.navigationController.viewControllers.count > 1 && self.navigationController.viewControllers.lastObject == self) {
//        self.automaticallyAdjustsScrollViewInsets = NO; // default: YES
//    }
    [self tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self.dataSource;

//    __weak PRKTableViewController *tableViewController = self;
//    // 添加下拉刷新功能
//    [_tableView addPullToRefreshWithActionHandler:^{
//        [tableViewController pullToRefreshAction];
//    }];
//    // 添加无限下翻功能
//    [_tableView addInfiniteScrollingWithActionHandler:^{
//        [tableViewController infiniteScrollingAction];
//    }];
//    
//    _tableView.showsPullToRefresh = NO;     // default is NO
//    _tableView.showsInfiniteScrolling = NO; // default is NO
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];
}

#pragma mark - Public

- (UITableView*)tableView {
    if (nil == _tableView && [self isViewLoaded]) {
        _tableView = [[PRKTableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
        _tableViewContentInsets = _tableView.contentInset;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self.dataSource;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (void)setTableView:(UITableView*)tableView {
    if (tableView != _tableView) {
        
		if (_tableView) {
			[_tableView removeFromSuperview];
		}
        
        if (tableView == nil) {
            _tableView.delegate = nil;
            _tableView.dataSource = nil;
            _tableView = nil;
            self.tableOverlayView = nil;
        }else {
            _tableView = tableView;
            _tableView.delegate = nil;
            _tableView.delegate = self;
            _tableView.dataSource = self.dataSource;
            
			if (!_tableView.superview) {
				[self.view addSubview:_tableView];
			}
        }
        self.tableViewContentInsets = tableView.contentInset;
    }
}

- (void)setTableOverlayView:(UIView*)tableOverlayView animated:(BOOL)animated {
    if (tableOverlayView != _tableOverlayView) {
        if (_tableOverlayView) {
            if (animated) {
                [self fadeOutView:_tableOverlayView];
                
            } else {
                [_tableOverlayView removeFromSuperview];
            }
        }
        
        _tableOverlayView = tableOverlayView;
        
        if (_tableOverlayView) {
            _tableOverlayView.frame = [self rectForOverlayView];
            [self addToOverlayView:_tableOverlayView];
        }
        
        // XXXjoe There seem to be cases where this gets left disable - must investigate
        //_tableView.scrollEnabled = !_tableOverlayView;
    }
}

- (void)setTableWatermarkView:(UIView *)tableWatermarkView animated:(BOOL)animated{
    if (tableWatermarkView != _tableWatermarkView) {
        if (_tableWatermarkView) {
            if (animated) {
                [self fadeOutView:_tableWatermarkView];
                
            } else {
                [_tableWatermarkView removeFromSuperview];
            }
        }
        
        _tableWatermarkView = tableWatermarkView;
        
        if (_tableWatermarkView) {
            _tableWatermarkView.frame = [self rectForWatermarkView];
            [self addToWatermarkView:_tableWatermarkView];
        }
        
        // XXXjoe There seem to be cases where this gets left disable - must investigate
        //_tableView.scrollEnabled = !_tableOverlayView;
    }
}

- (void)setDataSource:(id<PRKTableViewDataSource>)dataSource {
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        _tableView.dataSource = _dataSource;
    }
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {}

- (CGRect)rectForOverlayView {
    return CGRectMake(0.0f,
                      0.0f,
                      _tableView.width-self.tableViewContentInsets.left-self.tableViewContentInsets.right,
                      _tableView.height-self.tableViewContentInsets.bottom-self.tableViewContentInsets.top) ;
}
- (CGRect)rectForWatermarkView {
    return [self rectForOverlayView];
}

//- (void)pullToRefreshAction{}
//
//- (void)infiniteScrollingAction{}
//
//- (void)stopRefreshAction{
//    [_tableView.pullToRefreshView stopAnimating];
//    [_tableView.infiniteScrollingView stopAnimating];
//}

@end

@implementation PRKTableViewController (delegate)

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    id<PRKTableViewDataSource> dataSource = (id<PRKTableViewDataSource>)tableView.dataSource;
    
    id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    Class cls = [dataSource tableView:tableView cellClassForObject:object];
    
    return [cls tableView:tableView rowHeightForObject:object];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *title = [tableView.dataSource tableView:tableView
                                  titleForHeaderInSection:section];
        if (!title.length) {
            return 0;
        }
        return 22.0;
    }
    return 0;
}

// 自定义sectionView在继承的controller中自己实现
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return nil;
//}

/**
 * When the user taps a cell item, we check whether the tapped item has an attached URL and, if
 * it has one, we navigate to it. This also handles the logic for "Load more" buttons.
 */
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    id<PRKTableViewDataSource> dataSource = (id<PRKTableViewDataSource>)tableView.dataSource;
    id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    [self didSelectObject:object atIndexPath:indexPath];
}

/**
 * Similar logic to the above. If the user taps an accessory item and there is an associated URL,
 * we navigate to that URL.
 */
- (void)tableView:(UITableView*)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
    NSLog(@" object:%@",[(id<PRKTableViewDataSource>)tableView.dataSource tableView:tableView objectForRowAtIndexPath:indexPath]);
}

@end
