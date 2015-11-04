//
//  PRKTableViewSectionObject.h
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRKTableViewSectionObject : NSObject
@property (nonatomic, strong) id userInfo;
@property (nonatomic, copy) NSString *letter;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;
@property (nonatomic, strong) NSMutableArray *items;
@end
