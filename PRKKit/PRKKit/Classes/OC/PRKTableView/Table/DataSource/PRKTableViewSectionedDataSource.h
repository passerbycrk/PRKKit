//
//  PRKTableViewSectionedDataSource.h
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableViewDataSource.h"
#import "PRKTableViewSectionObject.h"

@interface PRKTableViewSectionedDataSource : PRKTableViewDataSource

// RSSectionObject对象数组
@property (nonatomic, strong) NSMutableArray *sections;
// 返回第一个section的items数组
@property (nonatomic,   weak) NSMutableArray *firstSectionItems;

@end
