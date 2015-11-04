//
//  PRKAlertView.h
//  PRKUIComponent
//
//  Created by dabing on 15/4/13.
//  Copyright (c) 2015年 passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PRKAlertViewClickBlock)(NSInteger index, NSString *title);

@interface PRKAlertView : NSObject

// Designated initializer
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

// Public Medthods
- (NSInteger)addButtonWithTitle:(NSString *)title callback:(PRKAlertViewClickBlock)callback;
- (NSInteger)addCancelButtonWithTitle:(NSString *)title callback:(PRKAlertViewClickBlock)callback;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSInteger)addCancelButtonWithTitle:(NSString *)title;

- (void)show;

@end
