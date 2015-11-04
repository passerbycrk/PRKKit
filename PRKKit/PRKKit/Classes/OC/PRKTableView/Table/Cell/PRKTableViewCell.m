//
//  PRKTableViewCell.m
//  PRKTableView
//
//  Created by passerbycrk on 13-4-16.
//  Copyright (c) 2013年 prk. All rights reserved.
//

#import "PRKTableViewCell.h"

@implementation PRKTableViewCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    return 44;
}

- (void)dealloc {
    [self finishObserveObjectProperty];
    _object = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setObject:(id)object {
    if (object != _object) {
        if (_object != nil) {
            [self finishObserveObjectProperty];
        }
        
        _object = object;
        if (_object != nil)
            [self startObserveObjectProperty];
    }
}

#pragma mark Object Property Observer

- (void)addObservedProperty:(NSString *)property {
    [_object addObserver:self forKeyPath:property
                 options:NSKeyValueObservingOptionNew
                 context:nil];
}

- (void)removeObservedProperty:(NSString *)property {
    [_object removeObserver:self forKeyPath:property context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != _object) {
        [object removeObserver:self forKeyPath:keyPath];
    }
    else {
        [self objectPropertyChanged:keyPath];
    }
}

@end

@implementation PRKTableViewCell (KVOLifeCycle)

- (void)startObserveObjectProperty {
    
}

- (void)finishObserveObjectProperty {
    
}

- (void)objectPropertyChanged:(NSString *)property {
    
}

@end
