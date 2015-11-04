//
//  PRKTableViewSectionObject.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableViewSectionObject.h"

@implementation PRKTableViewSectionObject

// 初始化一发
- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

@end
