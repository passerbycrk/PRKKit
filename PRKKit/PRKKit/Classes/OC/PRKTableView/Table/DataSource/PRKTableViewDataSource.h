//
//  PRKTableViewDataSource.h
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PRKTableViewDataSource <UITableViewDataSource>

@required
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object;
///////////////////////////////////////////////////////////////////////////////////
@optional
- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object;
- (BOOL)empty;
///////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)tableView:(UITableView *)tableView willUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willRemoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
///////////////////////////////////////////////////////////////////////////////////

@end

@interface PRKTableViewDataSource : NSObject <PRKTableViewDataSource>

@end
