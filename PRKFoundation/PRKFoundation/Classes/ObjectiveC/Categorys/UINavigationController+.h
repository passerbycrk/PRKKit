//
//  UINavigationController+.h
//  iPhoneVideo
//
//  Created by MingLQ on 2011-11-15.
//  Modified by dabing on 2015-6-5
//  Copyright 2015 Passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (StatusBar)
- (UIStatusBarStyle)preferredStatusBarStyle;
@end

@interface UINavigationController (SafeTransition)

@property (nonatomic, assign) BOOL prk_isInPushTransition;

@property (nonatomic, strong) UIPanGestureRecognizer *prk_interactivePopGestureRecognizer;

@property (nonatomic, strong) UIScrollView *prk_horizontalScrollView;

@end

@interface UINavigationController (M9Category)

@property (nonatomic, strong, readonly) UIViewController *rootViewController;

// !!!: the delegate and interactivePopGestureRecognizer.delegate of the returned navigationController is itself
+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController;

@end


@interface PRKNavigationController : UINavigationController

@end

#pragma mark -

@interface UIViewController (UINavigationController)

// !!!: @see - [UINavigationController navigationControllerWithRootViewController:self];
- (UINavigationController *)wrapWithNavigationController; // PRKNavigationController

// !!!: LifeCycle For prk_interactivePopGestureRecognizer
- (void)prk_viewWillExecuteInteractivePopGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;

- (void)prk_viewDidExecuteInteractivePopGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;

@end

