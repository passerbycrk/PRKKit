//
//  PRKProgressView.h
//  PRKUIComponent
//
//  Created by dabing on 15/5/26.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRKProgressView : UIView

@property(nonatomic, assign) CGFloat progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.
@property(nonatomic, strong) UIColor* progressTintColor;
@property(nonatomic, strong) UIColor* trackTintColor;
@property(nonatomic, strong) UIImage* progressImage;
@property(nonatomic, strong) UIImage* trackImage;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated completion:(dispatch_block_t)completion;

@end
