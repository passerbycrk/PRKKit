//
//  PRKProgressView.m
//  PRKUIComponent
//
//  Created by dabing on 15/5/26.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import "PRKProgressView.h"

@interface PRKProgressView ()
@property (nonatomic, strong) UIImageView *trackImageView;
@property (nonatomic, strong) UIImageView *progressImageView;
@end

@implementation PRKProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.trackImageView.frame = self.bounds;
        self.progressImageView.frame = CGRectZero;
        [self addSubview:self.trackImageView];
        [self addSubview:self.progressImageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectIsNull(frame) || CGRectIsEmpty(frame) || CGRectIsInfinite(frame)) {
        return;
    }
    self.trackImageView.frame = self.bounds;
    [self setProgress:self.progress];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated completion:(dispatch_block_t)completion {
    [UIView animateWithDuration:(animated?.2f:.0f)
                     animations:^{
                         self.progress = progress;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self setProgress:progress animated:animated completion:nil];
}

- (void)setProgress:(CGFloat)progress {
    if (progress < .0f) {
        progress = .0f;
    }
    if (!isnan(progress)) {
        _progress = progress;
        CGRect progressFrame = self.bounds;
        progressFrame.size.width *= _progress;
        self.progressImageView.frame = progressFrame;
        [self.progressImageView setNeedsDisplay];
    }
}

- (void)setProgressImage:(UIImage *)progressImage {
    if (progressImage != _progressImage) {
        _progressImage = progressImage;
        if (progressImage) {
            self.progressImageView.image = progressImage;
        }
    }
}

- (void)setTrackImage:(UIImage *)trackImage {
    if (trackImage != _trackImage) {
        _trackImage = trackImage;
        if (trackImage) {
            self.trackImageView.image = trackImage;
        }
    }
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    if (progressTintColor != _progressTintColor) {
        _progressTintColor = progressTintColor;
        
        self.progressImageView.backgroundColor = progressTintColor;
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    if (trackTintColor != _trackTintColor) {
        _trackTintColor = trackTintColor;
        
        self.trackImageView.backgroundColor = trackTintColor;
    }
}

#pragma mark - Propertys

- (UIImageView *)trackImageView {
    if (!_trackImageView) {
        _trackImageView = [[UIImageView alloc] init];
        _trackImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _trackImageView;
}

- (UIImageView *)progressImageView {
    if (!_progressImageView) {
        _progressImageView = [[UIImageView alloc] init];
        _progressImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _progressImageView;
}

@end
