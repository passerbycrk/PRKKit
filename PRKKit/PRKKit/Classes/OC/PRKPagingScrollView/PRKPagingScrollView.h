//
//  PRKPagingScrollView.h
//  Passerbycrk
//
//  Created by dabing on 15/6/6.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PRKPagingScrollView;

@protocol PRKPagingScrollViewDelegate <NSObject>
@optional
- (void)pagingView:(PRKPagingScrollView *)pagingView pageViewAppeared:(UIView *)pageView withIndex:(NSInteger)pageIndex;
- (void)pagingView:(PRKPagingScrollView *)pagingView pageViewStartScrolling:(UIView *)pageView withIndex:(NSInteger)pageIndex;
- (void)pagingView:(PRKPagingScrollView *)pagingView pageViewEndScrolling:(UIView *)pageView withIndex:(NSInteger)pageIndex;
- (void)pagingView:(PRKPagingScrollView *)pagingView pageViewOffsetPercent:(CGFloat)offsetPercent;
@end


@interface PRKPagingScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic,   weak) id<PRKPagingScrollViewDelegate> delegate;

@property (nonatomic, strong) NSArray *pages;

@property (nonatomic, readonly) NSInteger currentPageIndex;
@property (nonatomic, readonly) NSInteger visiblePageIndex;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) BOOL isDragging;
@property (nonatomic, readonly) BOOL isAnimated;

- (instancetype)initWithFrame:(CGRect)frame andPages:(NSArray *)pagesArray;

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex;
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated;

@end
