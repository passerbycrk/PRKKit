//
//  PRKAlertView.m
//  PRKUIComponent
//
//  Created by dabing on 15/4/13.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import "PRKAlertView.h"
#import "UIViewController+.h"
#import "PRKCoreUtil.h"
#import "UIDevice+Core.h"

static NSMutableArray *prk_alertViewStack = nil;

#define PRK_TOP_MOST_VC [[[[UIApplication sharedApplication] keyWindow] rootViewController] topmostViewController]

@interface PRKAlertView() <UIAlertViewDelegate>
@property(nonatomic,  strong) NSMutableArray *btnTitles;
@property(nonatomic,  strong) NSMutableArray *callbacks;
@property(nonatomic,    copy) NSString *title;
@property(nonatomic,    copy) NSString *message;

@property(nonatomic,  assign) NSInteger cancelButtonIndex;
@end

@implementation PRKAlertView

- (void)dealloc {

}

+ (void)load {
    [super load];
    prk_alertViewStack = [NSMutableArray array];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callbacks = [NSMutableArray array];
        self.btnTitles = [NSMutableArray array];
        self.cancelButtonIndex = -1;
        [prk_alertViewStack addObject:self];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [self init];
    if (self) {
        self.title = title;
        self.message = message;
    }
    return self;
}

#pragma mark - Public

- (void)show {
    @synchronized(prk_alertViewStack) {
        if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"8"]) {
            [self p_UIAlertControllerShow];
        } else {
            [self p_UIAlertViewShow];
        }
    }
}

- (NSInteger)addButtonWithTitle:(NSString *)title callback:(PRKAlertViewClickBlock)callback {
    if (!title || title.length <= 0) {
        return - 1;
    }
    
    if (!callback) {
        callback = ^(NSInteger index, NSString *title) {
        };
    }
    [self.callbacks addObject:[callback copy]];
    [self.btnTitles addObject:title];
    return (self.btnTitles.count-1);
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title callback:(PRKAlertViewClickBlock)callback {
    NSInteger index = [self addButtonWithTitle:title callback:callback];
    if (index >= 0) {
        self.cancelButtonIndex = index;
    }
    return index;
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
    return [self addButtonWithTitle:title callback:nil];
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title {
    return [self addCancelButtonWithTitle:title callback:nil];
}

#pragma mark - Private

- (void)p_UIAlertViewShow {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    for (NSInteger index = 0; index < self.callbacks.count; ++index) {
        NSString *title = self.btnTitles[index];
        if (self.cancelButtonIndex >= 0 && self.cancelButtonIndex == index) {
            alertView.cancelButtonIndex = self.cancelButtonIndex;
        }
        [alertView addButtonWithTitle:title];
    }
    [alertView show];
}

- (void)p_UIAlertControllerShow {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:self.title
                                                                        message:self.message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    for (NSInteger index = 0; index < self.callbacks.count; ++index) {
        NSString *title = self.btnTitles[index];
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:title
                                 style:(self.cancelButtonIndex == index?UIAlertActionStyleCancel:UIAlertActionStyleDefault)
                                 handler:^(UIAlertAction *action) {
                                     PRKAlertViewClickBlock aCallback = self.callbacks[index];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         aCallback(index,title);
                                     });
                                     [self p_cleanup];
                                 }];
        [controller addAction:action];
    }
    [PRK_TOP_MOST_VC presentViewController:controller animated:YES completion:nil];
}

- (void)p_cleanup {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(prk_alertViewStack) {
            [prk_alertViewStack removeObject:self];
        }
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isKindOfClass:[UIAlertView class]]) {
        PRKAlertViewClickBlock aCallback = self.callbacks[buttonIndex];
        NSString *title = self.btnTitles[buttonIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            aCallback(buttonIndex,title);
        });
        [self p_cleanup];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    [self alertView:alertView clickedButtonAtIndex:self.cancelButtonIndex];
}

@end
