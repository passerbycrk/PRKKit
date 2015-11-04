//
//  PRKTableViewDataSource.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "NSObject+ClassName.h"
#import "PRKTableViewDataSource.h"
#import "PRKTableViewItem.h"
#import "PRKTableViewCell.h"
#import <objc/runtime.h>

@implementation PRKTableViewDataSource

#pragma mark - PRKTableViewDataSource
// @required
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
    if ([object isKindOfClass:[PRKTableViewItem class]]){
        return [PRKTableViewCell class];
    }
    return [PRKTableViewCell class];
}
// @optional
- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object
{
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)tableView:(UITableView *)tableView willUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willRemoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search:(NSString*)text {
}
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    
    Class cellClass = [self tableView:tableView cellClassForObject:object];    
    NSString *className = [NSString stringWithUTF8String:class_getName(cellClass)];
    
    UITableViewCell* cell =
    (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:className];
    if (cell == nil) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:className];
    }
    
    NSAssert([cell conformsToProtocol:@protocol(PRKTableViewCell)], @"cell should @protocol(PRKTableViewCell)]");
    [(UITableViewCell<PRKTableViewCell> *)cell setIndexPath:indexPath];
    [(UITableViewCell<PRKTableViewCell> *)cell setObject:object];
    
    return cell;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView
{
    return nil;
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title
               atIndex:(NSInteger)sectionIndex {
    if (tableView.tableHeaderView) {
        if (sectionIndex == 0)  {
            // This is a hack to get the table header to appear when the user touches the
            // first row in the section index.  By default, it shows the first row, which is
            // not usually what you want.
            [tableView scrollRectToVisible:tableView.tableHeaderView.bounds animated:NO];
            return -1;
        }
    }
    
    NSString* letter = [title substringToIndex:1];
    NSInteger sectionCount = [tableView numberOfSections];
    for (NSInteger i = 0; i < sectionCount; ++i) {
        NSString* section  = [tableView.dataSource tableView:tableView titleForHeaderInSection:i];
        if ([section hasPrefix:letter]) {
            return i;
        }
    }
    if (sectionIndex >= sectionCount) {
        return sectionCount-1;
        
    } else {
        return sectionIndex;
    }
}


@end
