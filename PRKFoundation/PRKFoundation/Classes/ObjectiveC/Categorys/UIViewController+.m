//
//  UIViewController+.m
//  Utility
//
//  Created by MingLQ on 2013-12-31.
//
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "UIViewController+.h"
#import "JRSwizzle.h"

@implementation UIViewController (M9Category)

@dynamic topMargin, bottomMargin;

- (CGFloat)topMargin {
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        if (self.edgesForExtendedLayout & UIRectEdgeTop) {
            if (self.topLayoutGuide.length) {
                return self.topLayoutGuide.length;
            }
            else {
                return [self topBarsHeight];
            }
        }
    }
    else {
#if !APP_EXTENSION
        /*
        if (self.wantsFullScreenLayout) {
            return [self topBarsHeight];
        }
         //*/
#endif
    }
    
    return 0;
}

- (CGFloat)bottomMargin {
    if ([self respondsToSelector:@selector(bottomLayoutGuide)]) {
        if (self.bottomLayoutGuide.length) {
            return self.bottomLayoutGuide.length;
        }
        else {
            return [self bottomBarsHeight];
        }
    }
    
    return 0;
}

- (CGFloat)topBarsHeight {
    CGFloat topBarsHeight = 0;
    if (![UIApplication sharedApplication].statusBarHidden || ![self prefersStatusBarHidden]) {
        // topBarsHeight += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        topBarsHeight += 20; // !!!: it maybe 40, but 20 is expected
    }
    if (self.navigationController && (!self.navigationController.navigationBarHidden || ![self prk_prefersNavigationBarHidden])) {
        topBarsHeight += CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    return topBarsHeight;
}

- (CGFloat)bottomBarsHeight {
    CGFloat bottomBarsHeight = 0;
    if (self.tabBarController.tabBar && !self.tabBarController.tabBar.hidden && !self.hidesBottomBarWhenPushed) {
        bottomBarsHeight += CGRectGetHeight(self.tabBarController.tabBar.frame);
    }
    if (self.navigationController.toolbar && !self.navigationController.toolbarHidden) {
        bottomBarsHeight += CGRectGetHeight(self.navigationController.toolbar.frame);
    }
    return bottomBarsHeight;
}

#pragma mark - Public

- (BOOL)isViewAppeared {
    return self.isViewLoaded && self.view.window;
}

- (UIViewController *)topmostViewController {
    UIViewController *topmostViewController = self;
    while (topmostViewController.presentedViewController) {
        topmostViewController = topmostViewController.presentedViewController;
    }
    
    UINavigationController *nav = (UINavigationController *)topmostViewController;
    
    if ([nav isKindOfClass:[UINavigationController class]]) {
        topmostViewController = nav.topViewController;
    }
    
    return topmostViewController;
}

@end

@implementation UIViewController(prk_navBar)

+ (void)load {
    [super load];
    [self jr_swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(swizzled_viewWillAppear:) error:nil];
}

- (void)swizzled_viewWillAppear:(BOOL)animated {
    [self swizzled_viewWillAppear:animated];
    if (self.navigationController) {
        BOOL newNavHidden = [self prk_prefersNavigationBarHidden];
        // 设置navigaitonBar是否隐藏
        [self.navigationController setNavigationBarHidden:newNavHidden
                                                 animated:[self prk_preferredNavigationBarUpdateAnimation]];
    }
}

- (BOOL)prk_prefersNavigationBarHidden {
    return NO;
}

- (BOOL)prk_preferredNavigationBarUpdateAnimation {
    return YES;
}

@end

@implementation UIViewController(prk_childViewController)

- (void)prk_addChildViewController:(UIViewController *)viewController {
    if (viewController) {
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)prk_removeChildViewController:(UIViewController *)viewController {
    if (viewController.parentViewController) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

@end