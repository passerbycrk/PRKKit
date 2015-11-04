//
//  PRKSearchDisplayController.h
//  PRKTableView
//
//  Created by passerbycrk on 15/9/10.
//  Copyright (c) 2015年 prk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PRKSearchDisplayDelegate;
@protocol PRKTableViewController;

@interface PRKSearchDisplayController : NSObject

- (id)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController searchResultsTableViewController:(UIViewController<PRKTableViewController> *)searchResultsViewController;

@property (nonatomic,     weak) id<PRKSearchDisplayDelegate> delegate;

@property (nonatomic, getter=isActive)  BOOL active;
- (void)setActive:(BOOL)visible animated:(BOOL)animated;

@property (nonatomic, readonly, weak) UISearchBar *searchBar;
@property (nonatomic, readonly, weak) UIViewController *searchContentsController;
@property (nonatomic, readonly, weak) UIViewController<PRKTableViewController> *searchResultsViewController;

@end

@protocol PRKSearchDisplayDelegate <NSObject>

@optional

// when we start/end showing the search UI
- (void) searchDisplayControllerWillBeginSearch:(PRKSearchDisplayController *)controller;
- (void) searchDisplayControllerDidBeginSearch:(PRKSearchDisplayController *)controller;
- (void) searchDisplayControllerWillEndSearch:(PRKSearchDisplayController *)controller;
- (void) searchDisplayControllerDidEndSearch:(PRKSearchDisplayController *)controller;

- (void) searchDisplayControllerDidCancel:(PRKSearchDisplayController *)controller;
- (void) searchDisplayControllerDidSearch:(PRKSearchDisplayController *)controller;

- (BOOL)searchDisplayController:(PRKSearchDisplayController *)controller shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(PRKSearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
- (BOOL)searchDisplayController:(PRKSearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption;

@end

@interface UIViewController (SearchDisplayControllerSupport)

@property(nonatomic, readonly, strong) PRKSearchDisplayController *displayController;
@property(nonatomic, readonly, strong) UIViewController *searchResultsViewController;

@end
