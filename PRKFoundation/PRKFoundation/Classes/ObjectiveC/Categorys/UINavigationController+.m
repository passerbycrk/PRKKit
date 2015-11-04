//
//  UINavigationController+.m
//  iPhoneVideo
//
//  Created by MingLQ on 2011-11-15.
//  Modified by dabing on 2015-6-5
//  Copyright 2015 Passerbycrk. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#define PRK_KEY_WINDOW  [[UIApplication sharedApplication] keyWindow]
#define PRK_NAV_TOP_VIEW    (PRK_KEY_WINDOW.rootViewController.topmostViewController.view)
#define PRK_NAV_POP_GESTURE_SHADOW_COLOR [UIColor blackColor]

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UINavigationController+.h"
#import "NSArray+.h"
#import "UIImage+.h"
#import "UIViewController+.h"
#import "JRSwizzle.h"

static void *const _kPKUINavigationControllerIsInPushTransition = (void *)&_kPKUINavigationControllerIsInPushTransition;

static void *const _kPRKUINavigationController_prk_interactivePopGestureRecognizer = (void *)&_kPRKUINavigationController_prk_interactivePopGestureRecognizer;

static void *const _kPRKUINavigationController_prk_horizontalScrollView = (void *)&_kPRKUINavigationController_prk_horizontalScrollView;

@implementation UINavigationController (StatusBar)
- (BOOL)prefersStatusBarHidden {
    return [[self topViewController] prefersStatusBarHidden];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[self topViewController] preferredStatusBarStyle];
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [[self topViewController] preferredStatusBarUpdateAnimation];
}
@end

@implementation UINavigationController (SafeTransition)

- (void)setPrk_isInPushTransition:(BOOL)prk_isInPushTransition {
    [self willChangeValueForKey:@"prk_isInPushTransition"];
    objc_setAssociatedObject(self, _kPKUINavigationControllerIsInPushTransition, @(prk_isInPushTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"prk_isInPushTransition"];
    
}

- (BOOL)prk_isInPushTransition {
    NSNumber *ret = (NSNumber *)objc_getAssociatedObject(self, _kPKUINavigationControllerIsInPushTransition);
    return [ret boolValue];
}

- (void)setPrk_interactivePopGestureRecognizer:(UIPanGestureRecognizer *)prk_interactivePopGestureRecognizer {
    [self willChangeValueForKey:@"prk_interactivePopGestureRecognizer"];
    objc_setAssociatedObject(self, _kPRKUINavigationController_prk_interactivePopGestureRecognizer, prk_interactivePopGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"prk_interactivePopGestureRecognizer"];
}

- (UIPanGestureRecognizer *)prk_interactivePopGestureRecognizer {
    UIPanGestureRecognizer *ret = (UIPanGestureRecognizer *)objc_getAssociatedObject(self, _kPRKUINavigationController_prk_interactivePopGestureRecognizer);
    return ret;
}

- (void)setPrk_horizontalScrollView:(UIScrollView *)prk_horizontalScrollView {
    [self willChangeValueForKey:@"prk_horizontalScrollView"];
    objc_setAssociatedObject(self, _kPRKUINavigationController_prk_horizontalScrollView, prk_horizontalScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"prk_horizontalScrollView"];
}

- (UIScrollView *)prk_horizontalScrollView {
    UIScrollView *ret = (UIScrollView *)objc_getAssociatedObject(self, _kPRKUINavigationController_prk_horizontalScrollView);
    return ret;
}

@end

/**
 *  为 interactivePopGestureRecognizer-BUG 而生：解决自定义 NavBar、backBarButtonItem 导致的返回手势、动画相关的问题
 */
@interface PRKNavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

// for push/pop animation to fix interactivePopGestureRecognizer bug
@property (nonatomic, strong) UIPanGestureRecognizer *prk_popGestureRecognizer;
@property (nonatomic, strong) NSMutableArray *snapshotStack;
@property (nonatomic, strong) UIView *snapshotPopImageView;
@property (nonatomic, strong) UIView *snapshotCurrImageView;
@property (nonatomic, assign) CGFloat lastTouchX;
@property (nonatomic, assign) BOOL shouldHandleSpanGesture;

// for push/pop safe stack
@property (nonatomic, strong) NSMutableArray *peddingBlocks;

// for delegate
@property (nonatomic,   weak) id<UINavigationControllerDelegate> realDelegate;

@end

@implementation PRKNavigationController

- (void)dealloc {
    self.delegate = nil;
    self.prk_popGestureRecognizer.delegate = nil;
    [self.view removeGestureRecognizer:self.prk_popGestureRecognizer];
    self.snapshotStack = nil;
    self.peddingBlocks = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.prk_isInPushTransition = NO;
        self.peddingBlocks = [NSMutableArray arrayWithCapacity:2];
        self.shouldHandleSpanGesture = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* !!!: 解决 interactivePopGestureRecognizer-BUG
     * 使用自定义手势pop
     */
    self.interactivePopGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handlePanGesture:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.prk_popGestureRecognizer = panGestureRecognizer;
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.realDelegate != self && self.realDelegate && [self.realDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.realDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.realDelegate != self && self.realDelegate && [self.realDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.realDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

/*
- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    NSUInteger ret = 0;
    return ret;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    
}
*/

#pragma mark UIGestureRecognizerDelegate

/* !!!: 解决 interactivePopGestureRecognizer-BUG
 *  原因：
 *      XXViewController 定制了返回按钮或隐藏了导航栏，导致从屏幕左侧的返回手势失效；
 *      清除默认 navigationController.interactivePopGestureRecognizer.delegate 可解决问题；
 *      @see http://stuartkhall.com/posts/ios-7-development-tips-tricks-hacks
 *  BUG：
 *      当 self.viewControllers 只有一个 rootViewController，此时从屏幕左侧滑入，然后快速点击控件 push 进新的 XXViewController；
 *      此时 rootViewController 页面不响应点击、拖动时间，再次从屏幕左侧滑入后显示新的 viewController，但点击返回按钮无响应、并可能发生崩溃；
 *  解决：
 *      navigationController.interactivePopGestureRecognizer.delegate 需实现此方法
 *          UIGestureRecognizerDelegate - gestureRecognizerShouldBegin:
 *      当 gestureRecognizer 是 navigationController.interactivePopGestureRecognizer、并且 [navigationController.viewControllers count] 小于等于 1 时返回 NO；
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && (gestureRecognizer == self.interactivePopGestureRecognizer
        || gestureRecognizer == self.prk_interactivePopGestureRecognizer))
    {
        UIView *otherView = [otherGestureRecognizer view];
        BOOL isEditting = NO; // 处理tableView编辑状态下手势逻辑
        if ([otherView isKindOfClass:[UITableView class]]) {
            isEditting = [(UITableView *)otherView isEditing];
        }
        UIView *view = [gestureRecognizer view];
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:[view superview]];
        if (translation.x >= 0) { // 只处理右滑pop
            return !isEditting && translation.x > ABS(translation.y) && !self.prk_isInPushTransition && [self.viewControllers count] > 1;
        } else {
            // do nothing
        }
    }
    return YES;
}

#pragma mark - Override

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (delegate) {
        [super setDelegate:self];
        if (delegate == self) {
            self.realDelegate = nil;
        } else {
            self.realDelegate = delegate;
        }
    } else {
        [super setDelegate:nil];
        self.realDelegate = nil;
    }
}

- (UIPanGestureRecognizer *)prk_interactivePopGestureRecognizer {
    UIPanGestureRecognizer *ret = [super prk_interactivePopGestureRecognizer];
    if (ret != self.prk_popGestureRecognizer) {
        ret = self.prk_popGestureRecognizer;
    }
    return ret;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self p_addTransitionBlock:^{
        if (!self.snapshotStack) {
            self.snapshotStack = [[NSMutableArray alloc] initWithCapacity:5];
        }
        UIView *snapshot = [self p_takeSnapshotWithView:PRK_NAV_TOP_VIEW];
        [self.snapshotStack addObjectOrNil:snapshot];
        [super pushViewController:viewController animated:animated];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    __block UIViewController *poppedViewController = nil;
    __weak PRKNavigationController *weakSelf = self;
    [self p_addTransitionBlock:^{
        [self.snapshotStack removeLastObject];
        poppedViewController = [super popViewControllerAnimated:animated];
        if (poppedViewController == nil) {
            weakSelf.prk_isInPushTransition = NO;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    __block NSArray *poppedViewControllers = nil;
    __weak PRKNavigationController *weakSelf = self;
    [self p_addTransitionBlock:^{
        if ([weakSelf.viewControllers containsObject:viewController]) {
            NSUInteger index = [weakSelf.viewControllers indexOfObject:viewController];
            NSUInteger arrayCount = weakSelf.viewControllers.count;
            if (NSNotFound != index && index < arrayCount) {
                [self.snapshotStack removeObjectsInRange:NSMakeRange(index, arrayCount-1-index)];
            }
            poppedViewControllers = [super popToViewController:viewController animated:animated];
            if (poppedViewControllers.count == 0) {
                weakSelf.prk_isInPushTransition = NO;
            }
        } else {
            weakSelf.prk_isInPushTransition = NO;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    __block NSArray *poppedViewControllers = nil;
    __weak PRKNavigationController *weakSelf = self;
    [self p_addTransitionBlock:^{
        [self.snapshotStack removeAllObjects];
        poppedViewControllers = [super popToRootViewControllerAnimated:animated];
        if (poppedViewControllers.count == 0) {
            weakSelf.prk_isInPushTransition = NO;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    return poppedViewControllers;
}

#pragma mark - Private

#pragma mark - Push/Pop Stack
- (void)p_addTransitionBlock:(void (^)(void))block {
    @synchronized(self.peddingBlocks) {
        if (!self.prk_isInPushTransition) {
            self.prk_isInPushTransition = YES;
            block();
        } else {
            [self.peddingBlocks addObject:[block copy]];
        }
    }
}

- (void)p_runNextTransition {
    @synchronized(self.peddingBlocks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.peddingBlocks.count > 0) {
                dispatch_block_t block = self.peddingBlocks.firstObject; // FIFO
                if (block) {
                    block();
                    [self.peddingBlocks removeObject:block];
                }
            } else {
                self.prk_isInPushTransition = NO;
            }
        });
    }
}

#pragma mark - Push/Pop Animation

- (void)p_handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (self.viewControllers.count <= 1) return ;
    
    CGPoint point = [panGestureRecognizer locationInView:PRK_KEY_WINDOW];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGestureRecognizer translationInView:[[panGestureRecognizer view] superview]];
        if (translation.x > 0) {
            // LifeCycle Callback
            [[self topViewController] prk_viewWillExecuteInteractivePopGestureRecognizer:panGestureRecognizer];
            
            self.shouldHandleSpanGesture = YES;
            self.snapshotPopImageView = [self.snapshotStack lastObject];
            [self p_initSnapshot];// 初始化位置
            self.snapshotPopImageView.hidden = NO;
            self.snapshotCurrImageView = [self p_takeSnapshotWithView:PRK_NAV_TOP_VIEW];
            [self p_addShadowForView:self.snapshotCurrImageView]; // 添加阴影
            [[PRK_NAV_TOP_VIEW window] addSubview:self.snapshotPopImageView];
            [[PRK_NAV_TOP_VIEW window] addSubview:self.snapshotCurrImageView];
            self.lastTouchX = point.x;
        } else {
            self.shouldHandleSpanGesture = NO;
        }
    } else if (self.shouldHandleSpanGesture) {
        if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if (self.prk_horizontalScrollView && self.prk_horizontalScrollView.contentOffset.x > 50) {
                self.shouldHandleSpanGesture = NO;
                self.snapshotPopImageView.hidden = YES;
                self.snapshotCurrImageView.hidden = YES;
            } else {
                CGRect frame = PRK_NAV_TOP_VIEW.frame;
                CGFloat newX = (point.x - self.lastTouchX) + frame.origin.x;
                if (newX <= .0f) {
                    newX = .0f;
                }
                if (PRK_NAV_TOP_VIEW.frame.origin.x == newX) {
                    return;
                }
                frame.origin.x = newX;
                PRK_NAV_TOP_VIEW.frame = frame;
                self.snapshotCurrImageView.frame = frame;
                // 阴影渐变
                CGFloat shadowAlpha = (1.f-(newX+30.f)/frame.size.width)*.5f;
                self.snapshotCurrImageView.layer.shadowColor = [PRK_NAV_POP_GESTURE_SHADOW_COLOR colorWithAlphaComponent:(shadowAlpha>=.0f?shadowAlpha:.0f)].CGColor;
                self.lastTouchX = point.x;
                [self p_offsetImageViewForX:newX];
            }
        } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self p_judgeToPushOrPop];
            self.shouldHandleSpanGesture = NO;
            // LifeCycle Callback
            [[self topViewController] prk_viewDidExecuteInteractivePopGestureRecognizer:panGestureRecognizer];
        }
    }
}

- (UIView *)p_takeSnapshotWithView:(UIView *)fromView {
    UIView * ret = [[fromView window] resizableSnapshotViewFromRect:fromView.bounds
                                                 afterScreenUpdates:NO
                                                      withCapInsets:UIEdgeInsetsZero];
    return ret;
}


- (void)p_initSnapshot {
    if (!self.snapshotPopImageView) {
        self.snapshotPopImageView = [[UIView alloc] initWithFrame:PRK_NAV_TOP_VIEW.bounds];
        self.snapshotPopImageView.backgroundColor = [UIColor clearColor];
    }
    CGRect imageViewFrame = PRK_NAV_TOP_VIEW.bounds;
    imageViewFrame.origin.x = -PRK_NAV_TOP_VIEW.bounds.size.width / 3 * 2;
    self.snapshotPopImageView.frame = imageViewFrame;
}

- (void)p_judgeToPushOrPop {
    __block CGRect frame = PRK_NAV_TOP_VIEW.frame;
    if (frame.origin.x > (frame.size.width / 3)) {
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.x = frame.size.width;
            PRK_NAV_TOP_VIEW.frame = frame;
            self.snapshotCurrImageView.frame = frame;
            [self p_offsetImageViewForX:frame.origin.x];
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:NO];
            self.snapshotPopImageView.hidden = YES;
            self.snapshotCurrImageView.hidden = YES;
            frame.origin.x = 0;
            PRK_NAV_TOP_VIEW.frame = frame;
            self.snapshotCurrImageView.frame = frame;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.x = 0;
            PRK_NAV_TOP_VIEW.frame = frame;
            self.snapshotCurrImageView.frame = frame;
            [self p_offsetImageViewForX:frame.origin.x];
        } completion:^(BOOL finished) {
            self.snapshotPopImageView.hidden = YES;
            self.snapshotCurrImageView.hidden = YES;
        }];
    }
}

- (void)p_offsetImageViewForX:(CGFloat)x {
    CGFloat imageViewX = x / 3 * 2  -PRK_NAV_TOP_VIEW.bounds.size.width / 3 * 2;
    CGRect imageViewFrame = self.snapshotPopImageView.frame;
    imageViewFrame.origin.x = imageViewX;
    self.snapshotPopImageView.frame = imageViewFrame;
}

- (void)p_addShadowForView:(UIView *)view {
    UIView *shadowedView = view;
    UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:shadowedView.bounds];
    shadowedView.layer.masksToBounds = NO;
    shadowedView.layer.shadowRadius = 6;
    shadowedView.layer.shadowOpacity = 1;
    shadowedView.layer.shadowColor = [[PRK_NAV_POP_GESTURE_SHADOW_COLOR colorWithAlphaComponent:.5f] CGColor];
    shadowedView.layer.shadowOffset = CGSizeZero;
    shadowedView.layer.shadowPath = [newShadowPath CGPath];
}

#pragma mark - Propertys

- (void)setPrk_isInPushTransition:(BOOL)prk_isInPushTransition {
    [super setPrk_isInPushTransition:prk_isInPushTransition];
    if (!prk_isInPushTransition && self.peddingBlocks.count > 0) {
        [self setPrk_isInPushTransition:YES];
        [self p_runNextTransition];
    }
}

@end

#pragma mark -

@implementation UINavigationController (M9Category)

@dynamic rootViewController;

- (UIViewController *)rootViewController {
    return [self.viewControllers objectOrNilAtIndex:0];
}

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController {
    return [[PRKNavigationController alloc] initWithRootViewController:rootViewController];
}

@end

#pragma mark -

@implementation UIViewController (UINavigationController)

- (UINavigationController *)wrapWithNavigationController {
    return [UINavigationController navigationControllerWithRootViewController:self];
}

+ (void)load {
    [super load];
    [self jr_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(swizzled_viewDidAppear:) error:nil];
}

- (void)swizzled_viewDidAppear:(BOOL)animated {
    [self swizzled_viewDidAppear:animated];
    if (self.navigationController) {
        /*!!! 防止连续push pop操作导致bug */
        [self.navigationController setPrk_isInPushTransition:NO];
    }
}

- (void)prk_viewWillExecuteInteractivePopGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {}

- (void)prk_viewDidExecuteInteractivePopGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {}


@end

