//
//  PRKSearchDisplayController.m
//  PRKTableView
//
//  Created by passerbycrk on 15/9/10.
//  Copyright (c) 2015年 prk. All rights reserved.
//

#import "PRKSearchDisplayController.h"
#import "PRKTableViewController.h"
#import <objc/runtime.h>

static void *const _kPRKDisplayControllerKey = (void *)&_kPRKDisplayControllerKey;
static void *const _kPRKSearchResultsViewControllerKey = (void *)&_kPRKSearchResultsViewControllerKey;

@interface UIViewController(__SearchDisplayControllerSupport)

@property(nonatomic, readwrite, strong) PRKSearchDisplayController *displayController;
@property(nonatomic, readwrite, strong) UIViewController *searchResultsViewController;

@end

@implementation UIViewController (SearchDisplayControllerSupport)

- (PRKSearchDisplayController *)displayController {
    return objc_getAssociatedObject(self, &_kPRKDisplayControllerKey);
}

- (void)setDisplayController:(PRKSearchDisplayController *)displayController {
    [self willChangeValueForKey:@"displayController"];
    objc_setAssociatedObject(self, &_kPRKDisplayControllerKey, displayController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"displayController"];
}

- (UIViewController *)searchResultsViewController {
    return objc_getAssociatedObject(self, &_kPRKSearchResultsViewControllerKey);
}

- (void)setSearchResultsViewController:(UIViewController *)searchResultsViewController {
    [self willChangeValueForKey:@"searchResultsViewController"];
    objc_setAssociatedObject(self, &_kPRKSearchResultsViewControllerKey, searchResultsViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"searchResultsViewController"];
}

@end

@interface PRKSearchDisplayController ()<UISearchBarDelegate>

@property (nonatomic, readwrite,    weak) UISearchBar *searchBar;
@property (nonatomic, readwrite,    weak) UIViewController *searchContentsController;
@property (nonatomic, readwrite,    weak) UIViewController<PRKTableViewController> *searchResultsViewController;

@end

@implementation PRKSearchDisplayController

- (id)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController searchResultsTableViewController:(UIViewController<PRKTableViewController> *)searchResultsViewController {
    self = [super init];
    if (self) {
        NSLog(@"[%@] init",self);
        self.searchBar = searchBar;
        self.searchBar.delegate = self;
        self.searchContentsController = viewController;
        self.searchResultsViewController = searchResultsViewController;
        
        self.searchContentsController.displayController = self;
        self.searchContentsController.searchResultsViewController = searchResultsViewController;
        
        self.searchResultsViewController.displayController = self;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.searchContentsController = nil;
    self.searchResultsViewController = nil;
    NSLog(@"[%@] dealloc",self);
}

- (void)setActive:(BOOL)active {
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    if (_active != visible) {
        _active = visible;
        
        if (_active) {
            if (self.searchBar.window) {
                UINavigationBar *navigationBar = self.searchContentsController.navigationController.navigationBar;
                CGRect frame = [self.searchContentsController.view convertRect:navigationBar.frame fromView:navigationBar.superview];
                
                if (![self.searchResultsViewController isViewLoaded]) {
                    self.searchResultsViewController.view.frame = self.searchContentsController.view.bounds;
                    
                    UIEdgeInsets contentInset = self.searchResultsViewController.tableView.contentInset;
                    contentInset.top += CGRectGetMaxY(frame);
                    self.searchResultsViewController.tableView.contentInset = contentInset;
                    
                    UIEdgeInsets scrollIndicatorInsets = self.searchResultsViewController.tableView.scrollIndicatorInsets;
                    scrollIndicatorInsets.top += CGRectGetMaxY(frame);
                    self.searchResultsViewController.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
                    
                }
                [self.searchContentsController.view addSubview:self.searchResultsViewController.view];
                [self.searchContentsController addChildViewController:self.searchResultsViewController];
            }
        } else {
            [self.searchBar resignFirstResponder];
            [self.searchResultsViewController.view removeFromSuperview];
            [self.searchResultsViewController removeFromParentViewController];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerWillBeginSearch:)]) {
        [self.delegate searchDisplayControllerWillBeginSearch:self];
    }
    //    if (searchBar.text.length == 0) {
    //        searchBar.text = @"  ";
    //    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self setActive:YES animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidBeginSearch:)]) {
        [self.delegate searchDisplayControllerDidBeginSearch:self];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerWillEndSearch:)]) {
        [self.delegate searchDisplayControllerWillEndSearch:self];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidEndSearch:)]) {
        [self.delegate searchDisplayControllerDidEndSearch:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    BOOL shouldReloadTable = YES;
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:shouldReloadTableForSearchString:)]) {
        shouldReloadTable = [self.delegate searchDisplayController:self shouldReloadTableForSearchString:searchBar.text];
    }
    //    if (searchText.length < 2 && ((NSString *)[searchText trimmedString]).length == 0) {
    //        searchBar.text = @"  ";
    //    }
    
    if (shouldReloadTable) {
        [self.searchResultsViewController.tableView reloadData];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        return YES;
    }
    
    NSString * toBeString = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    if (toBeString.length > 40) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate searchDisplayController:self shouldChangeTextInRange:range replacementText:text];
    }
    
    //    if (toBeString.length < 2 && ((NSString *)[toBeString trimmedString]).length == 0) {
    //        searchBar.text = @"  ";
    //        return NO;
    //    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidSearch:)]) {
        [self.delegate searchDisplayControllerDidSearch:self];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidCancel:)]) {
        [self.delegate searchDisplayControllerDidCancel:self];
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    BOOL shouldReloadTable = YES;
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:shouldReloadTableForSearchScope:)]) {
        shouldReloadTable = [self.delegate searchDisplayController:self shouldReloadTableForSearchScope:selectedScope];
    }
    if (shouldReloadTable) {
        [self.searchResultsViewController.tableView reloadData];
    }
}

@end
