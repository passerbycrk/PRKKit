//
//  PRKTableViewItem.h
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PRKTableViewItem : NSObject

@property (nonatomic, assign) CGFloat cellHeight;	// 缓存cell的高度,主要用于高度可变的cell

@property (nonatomic, strong) id userInfo;		// 用户数据

@end
