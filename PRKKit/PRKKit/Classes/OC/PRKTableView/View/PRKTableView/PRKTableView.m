//
//  PRKTableView.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIWindow+RscExt.h"

static const CGFloat kShadowHeight        = 20.0;
static const CGFloat kShadowInverseHeight = 10.0;

@implementation PRKTableView
{   
    CGFloat _contentOrigin;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    [super setScrollsToTop:scrollsToTop];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentSize:(CGSize)size {
    if (_contentOrigin) {
        CGFloat minHeight = self.frame.size.height + _contentOrigin;
        if (size.height < minHeight) {
            size.height = self.frame.size.height + _contentOrigin;
        }
    }
    
    CGFloat y = self.contentOffset.y;
    [super setContentSize:size];
    
    if (_contentOrigin) {
        // As described below in setContentOffset, UITableView insists on messing with the
        // content offset sometimes when you change the content size or the height of the table
        self.contentOffset = CGPointMake(0, y);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentOffset:(CGPoint)point {
    // UITableView (and UIScrollView) are really stupid about resetting the content offset
    // when the table view itself is resized.  There are times when I scroll to a point and then
    // disable scrolling, and I don't want the table view scrolling somewhere else just because
    // it was resized.
    if (self.scrollEnabled) {
        if (!(_contentOrigin && self.contentOffset.y == _contentOrigin && point.y == 0)) {
            [super setContentOffset:point];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentInset:(UIEdgeInsets)contentInset{
    [super setContentInset:contentInset];    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
    // -[UITableView reloadData] takes away first responder status if the first responder is a
    // subview, so remember it and then restore it afterward to avoid awkward keyboard disappearance
    UIResponder* firstResponder = [self.window findFirstResponderInView:self];
    
    CGFloat y = self.contentOffset.y;
    [super reloadData];
    
    if (nil != firstResponder) {
        [firstResponder becomeFirstResponder];
    }
    
    if (_contentOrigin) {
        self.contentOffset = CGPointMake(0, y);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
              scrollPosition:(UITableViewScrollPosition)scrollPosition {
    
    [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CAGradientLayer*)shadowAsInverse:(BOOL)inverse {
    CAGradientLayer* newShadow = [[CAGradientLayer alloc] init];
    CGRect newShadowFrame = CGRectMake(0.0, 0.0,
                                       self.frame.size.width,
                                       inverse ? kShadowInverseHeight : kShadowHeight);
    newShadow.frame = newShadowFrame;
    
    CGColorRef darkColor = [UIColor colorWithRed:0.0
                                           green:0.0
                                            blue:0.0
                                           alpha:inverse ?
                            (kShadowInverseHeight / kShadowHeight) * 0.5
                                                : 0.5].CGColor;
    CGColorRef lightColor = [self.backgroundColor
                             colorWithAlphaComponent:0.0].CGColor;
    
    newShadow.colors = [NSArray arrayWithObjects:
                        (__bridge id)(inverse ? lightColor : darkColor),
                        (__bridge id)(inverse ? darkColor : lightColor),
                        nil];
    return newShadow;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];   
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {    
    [super layoutSublayersOfLayer:layer];
}

@end
