//
//  PRKPagingScrollView.m
//  Passerbycrk
//
//  Created by dabing on 15/6/6.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import "PRKPagingScrollView.h"

@interface PRKPagingScrollView ()
@property (nonatomic, readwrite, assign) NSInteger currentPageIndex;
@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, readwrite, assign) BOOL isDragging;
@property (nonatomic, readwrite, assign) BOOL isAnimated;
@end

@implementation PRKPagingScrollView

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_applyDefaultsToSelfDuringInitializationWithFrame:frame pages:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_applyDefaultsToSelfDuringInitializationWithFrame:self.frame pages:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andPages:(NSArray *)pagesArray {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_applyDefaultsToSelfDuringInitializationWithFrame:self.frame pages:pagesArray];
    }
    return self;
}

#pragma mark - Public

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    [self setCurrentPageIndex:currentPageIndex animated:NO];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated {
    if(![self p_pageViewForIndex:currentPageIndex]) {
        NSLog(@"Wrong currentPageIndex received: %ld",(long)currentPageIndex);
        return;
    }
    self.isAnimated = animated;
    if (currentPageIndex != _currentPageIndex) {
        _currentPageIndex = currentPageIndex;
        CGFloat offset = currentPageIndex * self.scrollView.frame.size.width;
        CGRect pageRect = { .origin.x = offset, .origin.y = 0.0, .size.width = self.scrollView.frame.size.width, .size.height = self.scrollView.frame.size.height };
        [self.scrollView scrollRectToVisible:pageRect animated:animated];
    }
}

#pragma mark - Private

- (void)p_applyDefaultsToSelfDuringInitializationWithFrame:(CGRect)frame pages:(NSArray *)pagesArray {
    self.isDragging = NO;
    self.isAnimated = NO;
    self.pages = pagesArray;
}

- (void)p_buildScrollView {
    [self addSubview:self.scrollView];
    CGFloat contentXIndex = 0;
    for (NSInteger idx = 0; idx < _pages.count; idx++) {
        UIView *pageView = _pages[idx];
        pageView.frame = CGRectMake(contentXIndex, .0f, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        contentXIndex += self.scrollView.frame.size.width;
        [self.scrollView addSubview:pageView];
    }
    self.scrollView.contentSize = CGSizeMake(contentXIndex, self.scrollView.frame.size.height);
}

- (void)p_checkIndexForScrollView:(UIScrollView *)scrollView {
    NSInteger newPageIndex = (scrollView.contentOffset.x + scrollView.bounds.size.width/2)/self.scrollView.frame.size.width;
    if(newPageIndex != _currentPageIndex && newPageIndex < _pages.count) {
        _currentPageIndex = newPageIndex;
        
        if (self.currentPageIndex >= (_pages.count)) {
            _currentPageIndex = _pages.count - 1;
        }
        UIView* currentView = _pages[newPageIndex];
        if (currentView && [self.delegate respondsToSelector:@selector(pagingView:pageViewAppeared:withIndex:)]) {
            [self.delegate pagingView:self pageViewAppeared:currentView withIndex:newPageIndex];
        }
    }
}

- (UIView *)p_pageViewForIndex:(NSInteger)idx {
    if(idx >= _pages.count) {
        return nil;
    }
    
    return (UIView *)_pages[idx];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
    if (self.currentPageIndex < [self.pages count]
        && self.delegate
        && [self.delegate respondsToSelector:@selector(pagingView:pageViewStartScrolling:withIndex:)])
    {
        [self.delegate pagingView:self pageViewStartScrolling:_pages[self.currentPageIndex] withIndex:self.currentPageIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self p_checkIndexForScrollView:scrollView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagingView:pageViewEndScrolling:withIndex:)]) {
        [self.delegate pagingView:self pageViewEndScrolling:_pages[self.currentPageIndex] withIndex:self.currentPageIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self p_checkIndexForScrollView:scrollView];
    self.isAnimated = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isAnimated && self.delegate && [self.delegate respondsToSelector:@selector(pagingView:pageViewOffsetPercent:)]) {
        CGFloat offsetPercent = (scrollView.contentOffset.x/(scrollView.contentSize.width-scrollView.frame.size.width));
        if (offsetPercent > 1.f) {
            offsetPercent = 1.f;
        } else if (offsetPercent < .0f) {
            offsetPercent = .0f;
        }
        //NSLog(@"===> %.1f",offsetPercent);
        [self.delegate pagingView:self pageViewOffsetPercent:offsetPercent];
    }
}

#pragma mark - Custom setters

- (void)setPages:(NSArray *)pages {
    _pages = pages;
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self p_buildScrollView];
}

#pragma mark - Properties

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (NSInteger)visiblePageIndex {
    return (NSInteger) ((self.scrollView.contentOffset.x + self.scrollView.bounds.size.width/2) / self.scrollView.frame.size.width);
}

@end
