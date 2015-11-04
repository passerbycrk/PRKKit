//
//  UIViewController+.h
//  Utility
//
//  Created by MingLQ on 2013-12-31.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (M9Category)

@property(nonatomic, readonly, assign) CGFloat topMargin, bottomMargin;
@property(nonatomic, readonly, assign) CGFloat topBarsHeight, bottomBarsHeight;

- (BOOL)isViewAppeared;

- (UIViewController *)topmostViewController;

@end

@interface UIViewController (prk_navBar)

- (BOOL)prk_prefersNavigationBarHidden; // 是否隐藏navigationBar: Default NO

- (BOOL)prk_preferredNavigationBarUpdateAnimation;  // 是否隐藏navigationBar动画: Default YES

@end

@interface UIViewController (prk_childViewController)

- (void)prk_addChildViewController:(UIViewController *)viewController;

- (void)prk_removeChildViewController:(UIViewController *)viewController;

@end
