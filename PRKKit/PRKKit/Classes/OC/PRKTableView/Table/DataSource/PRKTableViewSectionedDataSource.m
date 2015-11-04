//
//  PRKTableViewSectionedDataSource.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableViewSectionedDataSource.h"
#import "PRKTableViewSectionObject.h"

@implementation PRKTableViewSectionedDataSource

- (void)dealloc {}

#pragma mark - PRKTableViewDataSource
// should be overrided
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
    return [super tableView:tableView cellClassForObject:object];
}

- (BOOL)empty
{
    BOOL ret = YES;
    for (PRKTableViewSectionObject *sectionObj in self.sections) {
        if (sectionObj.items.count > 0) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_sections.count > 0)
    {
		PRKTableViewSectionObject *aSectionObject = [_sections objectAtIndex:indexPath.section];
        
		if ([aSectionObject.items count] > indexPath.row)
        {
			return [aSectionObject.items objectAtIndex:indexPath.row];
		}
	}
    
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object
{
	if (_sections) {
		for (NSInteger i = 0; i < _sections.count; ++i)
        {
			PRKTableViewSectionObject	*aSectionObject = [_sections objectAtIndex:i];
			NSUInteger					objectIndex		= [aSectionObject.items indexOfObject:object];
            
			if (objectIndex != NSNotFound) {
				return [NSIndexPath indexPathForRow:objectIndex inSection:i];
			}
		}
	}    
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)tableView:(UITableView *)tableView willUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(object != nil, @"tableview updateObject is nil !!!");
    if (_sections.count > indexPath.section)
    {
        PRKTableViewSectionObject *sectionObject = [_sections objectAtIndex:indexPath.section];
        if (sectionObject.items.count > indexPath.row)
        {
            [sectionObject.items replaceObjectAtIndex:indexPath.row withObject:object];
        }
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(object != nil, @"tableview insertObject is nil !!!");
    PRKTableViewSectionObject *sectionObject = nil;
    if (_sections.count <= indexPath.section)
    {
        // ADD section
        sectionObject = [[PRKTableViewSectionObject alloc] init];
        sectionObject.items = [NSMutableArray arrayWithObject:object];
        [_sections insertObject:sectionObject atIndex:indexPath.section];
    }
    else
    {
        NSAssert(indexPath != nil , @"indexPath is nil !!!");
        sectionObject = [_sections objectAtIndex:indexPath.section];
        [sectionObject.items insertObject:object atIndex:indexPath.row];
        [_sections replaceObjectAtIndex:indexPath.section withObject:sectionObject];
    }
    
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willRemoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath != nil)
    {
        [self removeItemAtIndexPath:indexPath andSectionIfEmpty:YES];
    }
    else if(object != nil)
    {
        indexPath = [self tableView:tableView indexPathForObject:object];
        if (indexPath != nil)
        {
            [self removeItemAtIndexPath:indexPath andSectionIfEmpty:YES];
        }
    }
    else
    {
        NSAssert(indexPath == nil && object == nil, @"object and indexPath are nil !!!");
    }
    // If Object Not Founded ==> return nil
    return indexPath;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _sections ? _sections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_sections && _sections.count > section)
    {
		PRKTableViewSectionObject *sectionObject = [_sections objectAtIndex:section];
		return sectionObject.items.count;
	}
    
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (_sections.count)
    {
		PRKTableViewSectionObject *sectionObject = [_sections objectAtIndex:section];
		return sectionObject.headerTitle;
	}
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (_sections.count)
    {
		PRKTableViewSectionObject *sectionObject = [_sections objectAtIndex:section];
        if (sectionObject != nil && sectionObject.footerTitle != nil && ![sectionObject.footerTitle isEqualToString:@""])
        {
            return sectionObject.footerTitle;
        }
        
	}
    
    return nil;
}
#pragma mark - Private
- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [self removeItemAtIndexPath:indexPath andSectionIfEmpty:NO];
}

- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath andSectionIfEmpty:(BOOL)andSection
{
	if (_sections.count > 0)
    {
		PRKTableViewSectionObject *sectionObject = [_sections objectAtIndex:indexPath.section];
        if (sectionObject.items.count > indexPath.row) {
            [sectionObject.items removeObjectAtIndex:indexPath.row];
        }
        
		if (andSection && sectionObject.items.count == 0)
        {
			[_sections removeObjectAtIndex:indexPath.section];
			return YES;
		}
	}
    
	return NO;
}

#pragma mark - Propertys
- (NSMutableArray *)sections
{
    if (_sections == nil) {
        _sections = [[NSMutableArray alloc] init];
    }
    
    return _sections;
}

- (NSMutableArray *)firstSectionItems
{
	if ((_sections == nil) || (_sections.count <= 0)) {
		return nil;
	}
    
	PRKTableViewSectionObject *firstObj = [_sections objectAtIndex:0];
	return firstObj.items;
}

- (void)setFirstSectionItems:(NSMutableArray *)itemArray
{
    if (!self.sections || self.sections.count <= 0) {
        PRKTableViewSectionObject *firstObj = [[PRKTableViewSectionObject alloc] init];
        self.sections = [NSMutableArray arrayWithObject:firstObj];
    }
    [[self.sections objectAtIndex:0] setItems:itemArray];
}

@end
